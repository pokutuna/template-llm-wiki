# CLAUDE.md

## リポジトリ構成

- `wiki/` — 調査・実験・判断の記録 (知識ベース)
- `docs/` — 人が読む設計書・レポート・発表資料。wiki のルールの対象外
- `.claude/rules/` — 運用ルール。frontmatter の `paths` に該当するファイルを扱うと自動で読み込まれる
- `.claude/skills/` — 作業の手順。wiki の書き込み (`wiki-write`) と点検 (`wiki-lint`)

## wiki — 知識ベース

調べたこと、試した結果、ハマったこと、設計判断は `wiki/` に貯める。会話で終わらせず、
セッションを跨いで再利用したい知識ができたら wiki に書く。

- 入口は `wiki/index.md`。構成と読み方のルールは `.claude/rules/wiki.md` (paths: `wiki/**`) にあり、
  `wiki/` 配下を扱うと自動で読み込まれる
- 必要なページだけを読む。wiki 全体を読み込まない
- ページの作成・更新は `wiki-write` skill の手順に従う。URL や資料の取り込みを頼まれたときも同じ
- 点検はユーザーが `/wiki-lint` で行う
