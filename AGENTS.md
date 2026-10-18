# AGENTS.md

このリポジトリの指示は `CLAUDE.md` に書いてある。作業の前に `CLAUDE.md` を読むこと。

## ルールと手順

運用ルールは `.claude/rules/`、作業の手順は `.claude/skills/` にある。Claude Code は必要な場面で自動で読み込むが、
それ以外のエージェントは次の場面で、対応するファイルを自分で読むこと。

| 場面 | 読むファイル |
| --- | --- |
| `wiki/**` を読み書きする前 | `.claude/rules/wiki.md` |
| `wiki/**` のページを作成・更新する前 | `.claude/skills/wiki-write/SKILL.md` |
| wiki の点検を頼まれたとき | `.claude/skills/wiki-lint/SKILL.md` |
