---
name: wiki-write
description: wiki/ のページを作成・更新するときに使う。書く場所の決め方と、ページの書き方を定める。外部資料の取り込みは wiki-ingest の手順で行う
---

# wiki への書き込み

wiki のページを作成・更新するときの手順と、ページの書き方を定める。
外部資料を `sources/` に取り込むときは `wiki-ingest` skill の手順で行い、ページはこの skill の「ページの書き方」に従って書く。

## 手順

1. 書く内容を扱っている既存ページを、`wiki-search` skill の手順で探す
2. 同じ事柄を扱うページがあれば、そのページを更新する (「既存のページを更新する」)。無ければ新しいページを作る。
   1 つの作業で複数の事柄が分かったときは、事柄ごとにこれを決める
3. 新しいページは、`wiki/index.md` から内容に合うディレクトリを選んで置く。`sources/` には `wiki-ingest` 以外で書かない
4. 「ページの書き方」に従って書く。新しいページは、関連する既存ページからリンクする
5. 全作業の前提になるページは、`wiki/index.md` の「重要」に載せる

wiki への書き込みは 1 つのエージェントが順に行う。複数のエージェントが同時に書くと、同じページへの変更が食い違う。

## 既存のページを更新する

- 同じ内容は 1 か所にまとめる
- 誤りだと確かめた記述は、直すか消す
- ページ全体が現行でなくなったときは、`status: deprecated` を付け、本文の冒頭に後継ページへのリンクを書く

## ページの書き方

### ファイル名

ページが扱う事柄を表す kebab-case の語にする (例: `example-cache.md`)。
`notes/` では作業を始めた日を前に付ける (例: `20261018-initial-setup.md`)。

### frontmatter

```yaml
---
type: Research
title: Example のキャッシュ設定
description: Example のキャッシュが有効になる条件と、設定項目の調査
tags: [example, cache]
sources:
  - id: example-config
    resource: ../sources/example-docs-configuration.md
    title: Example ドキュメント Configuration
  - resource: https://github.com/example/example/issues/123
    title: キャッシュが効かない issue
---
```

- `type` (必須): ディレクトリ名の単数形を先頭だけ大文字にした値 (例: `guides/` は `Guide`)
- `title` (必須): ページの題名
- `description` (必須): ページを開くかどうかを判断するための 1 文の説明
- `tags`: ディレクトリをまたいで関連するページを集めるための分類。`[a, b]` の 1 行の形式で kebab-case の語を書く。
  `wiki/scripts/list-tags.sh` で使われているタグを確かめて選び、合うものが無いときだけ新しいタグを作る
- `resource`: ページが説明する対象 (URL やファイル)
- `sources`: ページの内容の出典。取り込み済みの資料は `sources/` のページを、それ以外は資料の URL を挙げる。
  本文で脚注に使う出典には `id` を付ける
- `status`: `deprecated` だけを使う (「既存のページを更新する」)

### 本文

- 外部の情報に基づく記述には、`sources` の `id` をラベルにした脚注で出典を示す (例: `v2 からデフォルトで有効になった。[^example-config]`)。
  数値、日付、引用は、出典に書かれたとおりに書く
- 出典や結果が食い違い、どちらが正しいか確かめられないときは、両方をそれぞれの出典や条件と共に書く
- 推測や未確認の内容は、そうと分かるように書く
- 本文で触れる事柄に wiki のページがあれば、そのページへリンクする。リンクはページからの相対パスで書く
