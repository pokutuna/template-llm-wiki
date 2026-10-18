---
name: wiki-ingest
description: URL や外部資料を wiki に取り込むときに使う。資料ごとの Source ページ (wiki/sources/) を作成・更新する。複数の資料をまとめて渡されたときも使う
argument-hint: "<URL...>"
---

# 外部資料の取り込み

対象: $ARGUMENTS

Source ページは資料の索引である。読み手は Source ページを見て、元の資料のどのページを開けばよいかを判断し、
正確な内容は元の資料で確かめる。このため、資料の本文や値を写して資料の代わりにはしない。
この skill で書くのは `wiki/sources/` の Source ページだけで、資料から分かったことを `research/` などに反映するのは、
ユーザーに頼まれたときに `wiki-write` skill で行う。

## 手順

資料が複数あるときは、1 件ずつ順に次を行う。

1. 資料の単位を決める。単位は人が名前で呼ぶまとまり (ドキュメントサイト、リポジトリ、仕様書、論文、記事、動画) とし、
   同じサイトの別のページは同じ Source ページにまとめる
2. その資料の Source ページが既にあるか探す: `rg '^resource: <資料のルート URL>' wiki/sources`
3. 資料の原文を読む。読めない資料は推測で書かずに飛ばし、最後に報告する
4. Source ページが無ければ `cp wiki/template.md wiki/sources/<slug>.md` で作り、本文を下の書式に置き換える。あれば追記する。
   frontmatter は本文に合わせて更新する (`sources` には実際に読んだページだけを足す)

数値、日付、バージョン、引用は、資料の中で該当箇所を見つけてから書き、資料の表記のまま写す
(資料が `42K` なら `42,000` と書き換えない)。資料の中に見つからない値は書かない。

## Source ページの書式

- ファイル名は資料名の小文字ケバブ (例: `example-docs.md`)
- `resource` に資料のルート URL、`sources` に実際に読んだページを書く (どちらも必須)
- frontmatter の書き方は `wiki/template.md` のコメントにある
- 本文には資料に書いてあることだけを書き、解釈や評価を加えない
- 内容と要約は、そのページを開くべきかを判断できる程度に書く
- 抜粋は、言い回しそのものに意味がある文 (定義、制約、注意書き) だけを短く引用し、そのページの見出しの下に置く
- Source ページが 300 行 (目安) を超えたら、資料のセクションごとに別の Source ページに分ける (例: `example-docs-api.md`)

```markdown
---
type: Source
title: Example ドキュメント
description: Example の公式ドキュメント。設定項目、プラグインの作り方、移行ガイドがある。API リファレンスは無い
tags: [example]
generated: { by: claude-code/claude-opus-5-5, at: 2026-10-18T15:00:00+09:00 }
resource: https://docs.example.com/
sources:
  - resource: https://docs.example.com/config/
    title: Configuration
---

# Example ドキュメント

## 概要

<!-- 発行者、対象のバージョン、公式かどうか、資料全体の構成。読んだ範囲で分かることだけ -->

## ページ

### [Configuration](https://docs.example.com/config/)

- 読んだ日: 2026-10-18
- 内容: <!-- このページで扱っている話題の列挙 -->
- 要約: <!-- 2〜3 文 -->
- 抜粋:
  > <!-- 資料の文をそのまま引用する -->

## 無いもの

<!-- 探したが見つからなかった情報。同じ探し物を繰り返さないために書く。探し物が無ければ節ごと省く -->
```

## 報告

取り込みが終わったら、次を報告する。

- 作成・追記した Source ページのパスと、それぞれに足した内容の要点
- 読めずに飛ばした資料
- 既存の wiki の記述と食い違う内容や、`research/` などに反映する価値がありそうな内容。
  該当しそうな既存ページを `list-pages.sh` と `rg` で探してパスを添える。反映はユーザーが頼んでから行う
