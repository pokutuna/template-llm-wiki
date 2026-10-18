---
name: wiki-lint
description: wiki/ を点検し、書式の崩れ、リンク切れ、矛盾、古い記述を報告する。直すのはユーザーが選んだものだけ
disable-model-invocation: true
argument-hint: "[対象のディレクトリまたはファイル]"
---

# wiki の点検

対象: $ARGUMENTS (指定が無ければ `wiki/` 全体)

報告と修正は対象のページについて行う。リンク、タグ、記述の矛盾は、対象外のページと照らし合わせて確かめる。

書式の規約は `wiki-write` skill (`.claude/skills/wiki-write/SKILL.md`)、Source ページの書式は `wiki-ingest` skill
(`.claude/skills/wiki-ingest/SKILL.md`) にある。点検の前に読む。
点検の間はファイルを書き換えない。報告してユーザーが選んだものだけを、最後に直す。

## 1. 機械的な点検

次のコマンドは `wiki/` 全体を調べ、問題の候補を出力する。対象のページの候補を開いて確かめてから報告に載せる。

```sh
# frontmatter または type が無いページ
rg --files-without-match '^type: *[^ #]' wiki/ -g '*.md' -g '!index.md'
# type: Template のまま残ったページ
rg -l '^type: Template' wiki/ -g '!template.md'
# type とディレクトリの対応 (一覧を見て照合する)
rg --no-heading --no-line-number '^type:' wiki/ -g '!index.md' -g '!template.md'
# title / description が無いページ
rg --files-without-match '^title: *[^ #]' wiki/ -g '*.md' -g '!index.md' -g '!template.md'
rg --files-without-match '^description: *[^ #]' wiki/ -g '*.md' -g '!index.md' -g '!template.md'
# ディレクトリごとの必須フィールドが無いページ
rg --files-without-match '^sources:' wiki/references wiki/sources wiki/research -g '*.md'
rg --files-without-match '^resource: *[^ #]' wiki/sources -g '*.md'
rg --files-without-match '^progress: *(open|doing|done|dropped)\b' wiki/ideas -g '*.md'
# notes/ の命名 (yyyymmdd-<slug>.md) に合わないファイル
rg --files wiki/notes -g '*.md' | rg -v '/[0-9]{8}-[a-z0-9-]+\.md$'
# generated.at にオフセットが無いページ
rg --no-heading '^generated:' wiki/ -g '!template.md' | rg -v 'at: *[0-9T:.-]+([+-][0-9]{2}:[0-9]{2}|Z)'
# 300 行を超えるページ
rg -c '' wiki/ -g '*.md' | awk -F: '$2 > 300'
# リンク先が存在しない相対リンク (未執筆のページへの意図したリンクと、HTML コメント内の例も出る)
rg -o --no-heading --no-line-number '\]\(([^)#: ]+)(#[^)]*)?\)' -r '$1' wiki/ -g '*.md' -g '!template.md' |
  while IFS=: read -r file link; do [ -e "$(dirname "$file")/$link" ] || echo "$file -> $link"; done
# 他のページからリンクされていないページ (ファイル名で照合するので、同名のページがあると見逃す)
rg --files wiki/ -g '*.md' -g '!index.md' -g '!template.md' |
  while IFS= read -r f; do b=$(basename "$f" .md); rg -q "[(/]$b\\.md[)#]" wiki/ -g '*.md' || echo "$f"; done
# タグと使用数 (表記ゆれを探す)
rg --no-heading --no-filename '^tags:' wiki/ -g '!template.md' | sed 's/^tags://' | tr -d '[] ' | tr ',' '\n' |
  rg -v '^$' | sort | uniq -c | sort -rn
```

## 2. 判断が要る点検

ページを読んで確かめる。対象のページを全部は読めないときは、`list-pages.sh` と `description` で関係しそうなページの組を選んでから読む。

- ページ間で記述が矛盾していないか
- 新しいページや資料で古くなったのに、更新注記も `status: deprecated` も無い記述が無いか
- `status: deprecated` のページの冒頭に、後継ページへのリンクがあるか
- 同じテーマのページが複数に分かれていないか (統合の候補)。逆に、1 ページに複数のテーマが混ざっていないか (分割の候補)
- 関連するのに相互にリンクしていないページが無いか
- 複数のページで言及されているのに、専用のページが無い概念が無いか
- `research/` の主張が、`sources` に挙げた資料や Source ページの記述に裏付けられているか (数値・日付・引用を中心に抜き取りで確かめる)
- `sources/` のページで、読んだ日が古く、資料が更新されていそうなものが無いか
- `ideas/` で `progress: doing` のまま長く更新されていないページが無いか

## 3. 報告

候補をそのまま並べず、確かめた結果だけを報告する。各項目にはファイルパス、問題、直し方の案を書く。
ユーザーは、そのまま直せるものはまとめて直させ、判断が要るものは 1 つずつ決める。このため次の 2 つに分ける。

- **そのまま直せるもの**: 直し方が 1 つに決まり、直してもページの内容 (事実、出典、ページ間の関係、進捗) が変わらないもの (例: `type` の誤り、移動先が 1 つのリンク切れ、タグの表記ゆれ)
- **判断が要るもの**: それ以外 (例: 矛盾、古い記述、出典の無い主張、後継ページの指定、統合の候補)

問題が無かった点検も、何を点検したかを 1 行で書く。

## 4. 修正

ユーザーが選んだ項目だけを、`wiki-write` skill (Source ページは `wiki-ingest` skill) の規約に従って直す。

- ページを消さない。現行でなくなったページには `status: deprecated` を付ける
- 事実に関わる記述は、資料や成果物で確かめ直してから直す。確かめられないときは直さず、未確認であることを書き添える
- ページを統合・移動したら、そのページへのリンクをすべて新しいパスに直す
