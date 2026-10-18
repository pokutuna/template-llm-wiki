---
paths:
  - "wiki/**"
---

# wiki/ 運用ルール

`wiki/` は [OKF (Open Knowledge Format) v0.2](https://github.com/GoogleCloudPlatform/knowledge-catalog/blob/main/okf/SPEC.md)
の簡易プロファイルで運用する知識バンドル。このプロジェクトの調査・学び・アイデアを蓄積する。
OKF のどの仕様を採用したかと理由は `docs/okf-profile.md` にある。

このファイルには wiki を読むときに必要なことを書く。書くときは、書き始める前に次の skill の手順と規約に従う
(Claude Code 以外のエージェントは `.claude/skills/<name>/SKILL.md` を読む)。

- 外部資料を取り込んで `sources/` に記録するとき → `wiki-ingest`
- それ以外のページを作成・更新するとき → `wiki-write`

## 構成

| 場所 | type | 内容 |
| --- | --- | --- |
| `wiki/references/` | `Reference` | 従う手順・制約・前提知識 |
| `wiki/sources/` | `Source` | 外部資料のどこに何が書いてあるか。資料 (ドキュメントサイト、リポジトリ、論文など) ごとに 1 ページ |
| `wiki/research/` | `Research` | 読んだ資料に基づく、テーマごとの調査結果 |
| `wiki/findings/` | `Finding` | 経験から得た理解・因果・教訓 |
| `wiki/notes/` | `Note` | wiki に残す特定の作業・調査・障害の時点記録 |
| `wiki/ideas/` | `Idea` | これから試す案 |

`wiki/index.md` は入口で、全作業の前提になる重要ページと各ディレクトリへのリンクを持つ。全ページの一覧ではない。

## 探し方

1. `wiki/index.md` を読む
2. 対象のディレクトリを絞り、各ページ frontmatter の `description` で読むべきページの見当を付ける
3. 必要なページだけを開く。wiki 全体を読み込まない

```sh
wiki/scripts/list-pages.sh DIR=wiki/research                    # title と description の一覧
wiki/scripts/list-pages.sh DIR=wiki/research WORDS='foo|bar'    # 語 (正規表現) で絞る
rg -l 'foo' wiki/                                                # 本文の全文検索
rg '^resource: https://docs.example.com' wiki/sources            # 資料の Source ページがあるか
```

## 読み方

- `status: deprecated` のページは現行ではない。冒頭のリンクから後継ページを読む
- 本文中の次の形の印は、直前の記述が古くなったことを示す。印の内容を現行として扱う

  ```markdown
  > [!NOTE]
  > 2026-10-18 更新: v2 からデフォルトで有効になった。[Example ドキュメント](../sources/example-docs.md)
  ```

- `sources/` のページは資料の要約と抜粋で、資料そのものではない。正確な値や最新の内容が必要なときは、ページのリンクから元の資料を開いて確かめる
- `verified` の無いページは、人が内容を確認していない
- 未執筆のページへのリンクは、書くべき知識の印として意図的に置かれている

## 質問に答えるとき

- wiki を読んで質問に答えるだけのときは、wiki のファイルを書き換えない
- wiki に書かれていることと、それ以外 (一般的な知識や推測) を分けて答え、参照したページのパスを示す
- wiki に情報が無いと答える前に、`index.md`、`list-pages.sh`、同義語を含めた `rg` の全文検索で探す
- 残す価値のある答え (比較、分析、複数ページをまたぐまとめ) ができたら、wiki に書くことを提案する。書くのはユーザーが同意してから
