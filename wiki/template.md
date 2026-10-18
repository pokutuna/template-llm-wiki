---
# このテンプレートをコピーして使う: cp wiki/template.md wiki/<references|sources|research|findings|notes|ideas>/<slug>.md
# 書き方: sources/ は wiki-ingest skill、それ以外は wiki-write skill / ファイル名は小文字ケバブ / notes のみ日付を入れる
type: Template # コピー後に書き換える: Reference (references/) | Source (sources/) | Research (research/) | Finding (findings/) | Note (notes/) | Idea (ideas/)
title: # ページタイトル
description: # 1 文の要約。ページを開かず内容を判断するために使う
tags: [] # 小文字ケバブ。既存のタグは rg '^tags:' wiki/ で確認する
generated: { by: , at: } # 最後に内容を変えた主体と日時 (書式だけの修正では変えない)。by: <ツール名>/<モデル名> (例: claude-code/claude-opus-5-5) または human:<id> / at: ISO 8601 オフセット付き (例: 2026-10-18T15:00:00+09:00)
# resource:  # このページが説明する対象。URL またはこのページからの相対パス。sources/ では必須 (資料のルート URL)
# sources:   # 実際に読んだ出典。references/ sources/ research/ では必須、findings/ では推奨
#   - resource: # URL またはこのページからの相対パス
#     title:
# progress:  # Idea のみ必須: open | doing | done | dropped
---

# タイトル

<!-- 本文。外部情報に基づく主張には出典を添える -->

## 関連

<!-- 関連ページへの相対リンク。未執筆のページへのリンクも可 -->
