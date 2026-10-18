# template-llm-wiki

コーディングエージェントと一緒に育てる知識ベース `wiki/` を持つリポジトリのテンプレート。
調べたこと、試した結果、ハマったこと、設計判断を、会話で終わらせずに `wiki/` に貯めて、セッションを跨いで再利用する。

`wiki/` は [OKF (Open Knowledge Format) v0.2](https://github.com/GoogleCloudPlatform/knowledge-catalog/blob/main/okf/SPEC.md)
に適合する Markdown + YAML frontmatter のファイル群で、OKF の任意仕様のうち必要なものだけを採用している。

エージェントへの指示は、読むときと書くときで分けている。

- 読むときのルールは `.claude/rules/wiki.md` にあり、Claude Code は `wiki/` のファイルを扱うときだけ自動で読み込む
- 書くときの手順と規約は `.claude/skills/wiki-ingest/` (資料の取り込み) と `.claude/skills/wiki-write/` (それ以外) にあり、Claude Code は wiki に書く場面でだけ読み込む
- 普段のコンテキストに常に入るのは、`CLAUDE.md` の数行と、`wiki-ingest`・`wiki-write` skill の 1 行の説明だけ。点検の `wiki-lint` skill は、ユーザーが呼び出すまで読み込まれない

`AGENTS.md` を読むエージェント (Codex CLI など) は、`AGENTS.md` の表を見て、場面に応じたファイルを読む。

## wiki の構成

ページは `references/`、`sources/`、`research/`、`findings/`、`notes/`、`ideas/` に分けて置く。それぞれに何を置くかは `.claude/rules/wiki.md` にある。ページの frontmatter はこうなる:

```yaml
---
type: Finding
title: キャッシュは起動直後に温める
description: 初回リクエストでキャッシュを作ると最初の数件がタイムアウトするので、起動時に作っておく。
tags: [cache, performance]
generated: { by: claude-code/claude-opus-5-5, at: 2026-10-18T15:00:00+09:00 }
resource: ../../src/cache.ts
---
```

## wiki の使い方

| やりたいこと | 頼み方の例 | エージェントの動き |
| --- | --- | --- |
| 調べる | 「wiki に foo について何か書いてある?」 | 読むときのルールに従って必要なページだけを読み、参照したページを示して答える。wiki は書き換えない |
| 資料を取り込む | 「この URL を wiki に取り込んで」(複数の URL でもよい) | `wiki-ingest` に従い、資料ごとに Source ページを作るか追記する。`research/` などに反映する価値がありそうな内容を報告する |
| 資料の内容を反映する | 「`sources/` の新しいページを `research/` に反映して」 | `wiki-write` に従い、Source ページから分かったことを既存ページに追記するか、新しいページを作る |
| 結果を残す | 「今の調査結果を wiki に残して」 | `wiki-write` に従い、置き場所を判断して既存ページに追記するか、新しいページを作る |
| 点検する | `/wiki-lint`、`/wiki-lint wiki/research` | 書式の崩れ、リンク切れ、矛盾、古い記述を報告する。直すのはユーザーが選んだものだけ |

大きな取り込みの後や定期的 (週 1 回など) に `/wiki-lint` を実行すると、リンク切れや記述の矛盾が溜まる前に見つけられる。

## セットアップ

### テンプレートから新しいリポジトリを作る

1. このリポジトリをテンプレートにして新しいリポジトリを作る (GitHub の "Use this template"、または `gh repo create <name> --template <owner>/template-llm-wiki`)
2. `CLAUDE.md` の冒頭にプロジェクト名と目的を書く
3. 下の「ディレクトリ構成の例」からドメインに合うものを選び、作業ディレクトリを作って `CLAUDE.md` の「リポジトリ構成」に書く
4. `wiki/index.md` の見出しをプロジェクト名に置き換える
5. この README をプロジェクトの README に書き換える

### 既存のリポジトリに導入する

1. `.claude/rules/wiki.md`、`.claude/skills/wiki-ingest/`、`.claude/skills/wiki-write/`、`.claude/skills/wiki-lint/`、`wiki/`、`docs/okf-profile.md` をコピーする
2. `CLAUDE.md` の「wiki — 知識ベース」の節を、既存の `CLAUDE.md` (無ければ新規) に書き写す
3. Claude Code 以外のエージェントも使うなら `AGENTS.md` をコピーする。既存の `AGENTS.md` があれば「ルールと手順」の節を書き写す

## ルールを足すとき

1. `.claude/rules/<name>.md` を作り、frontmatter の `paths` に対象のパスを書く (Claude Code の自動読み込み用)

   ```markdown
   ---
   paths:
     - "experiments/**"
   ---

   # experiments/ 運用ルール
   ```

2. `AGENTS.md` の「ルールと手順」の表に、場面 (例: `experiments/**` を読み書きする前) とルールファイルの行を足す

## ディレクトリ構成の例

wiki の 6 分類はドメインによらず共通で使う。ドメインに合わせて変えるのは、wiki の外の作業ディレクトリと、wiki から作業ディレクトリへの参照の仕方、タグの語彙。

### 実験・研究 (機械学習、コンペ)

```
experiments/NNN-<slug>/   実験ごとの学習コード・設定。作業メモは NOTE.md に自由に書く (wiki のルールの対象外)
src/<package>/            実験横断で import する共通実装
scripts/                  実験に紐付かない環境構築・運用のスクリプト
data/                     データセット (大きいものは gitignore)
outputs/                  評価結果など軽量で残したいもの
wiki/
docs/
```

- 流れ: `ideas/` に案 → `experiments/NNN-<slug>/` で実装・実行し `NOTE.md` に記録 → 残す価値があれば `notes/` と `findings/` に整理 → idea の `progress` を更新
- 実験に紐付くページは `resource: ../../experiments/NNN-<slug>` で示す
- 出力の置き場所 (実験固有か共有か、git に入れるか) は `.claude/rules/experiments.md` に書く
- 評価仕様・提出手順・計算環境の操作など、毎回守る制約は `references/` に置き、`index.md` の「重要」に載せる
- 読んだ論文や公式実装は `sources/` に 1 資料 1 ページで記録する

### 技術検証・プロトタイプ (グラフィクス、創作ツール)

```
experiments/NNN-<slug>/   1 検証 1 ディレクトリ。README.md と動く成果物 (index.html など)
tools/                    検証横断のスクリプト (外部 API の呼び出し、データ変換など)
assets/                   入力素材 (大きいものは gitignore)
wiki/
docs/
```

- 検証の結論は `findings/`、既存手法・ライブラリの調査は `research/` に書く。ライブラリのドキュメントやリポジトリは `sources/` に記録する
- 着手前の計画書は `docs/` に置き、未検証の前提を含むことを明記する。確かめた結果や変わった方針は wiki に書く

### プロダクト開発 (アプリ、サービス)

```
src/
tests/
docs/                     設計書・仕様書 (人がレビューするもの)
wiki/
```

- ライブラリ・API のドキュメントは `sources/`、それを踏まえた調査は `research/`、ハマりどころは `findings/`、障害の経緯は `notes/`、運用手順は `references/`
- 設計判断を 1 判断 1 ページの記録 (ADR: Architecture Decision Record) として残したいなら、`wiki/decisions/` (`type: Decision`) を足してよい。足すときは下の「wiki のディレクトリを足すとき」に従う

### 調査・リサーチ (コードを書かない)

```
wiki/                     sources/ と research/ が中心
docs/                     最終成果物 (レポート、発表資料)
```

- 読んだ資料は `sources/` に 1 資料 1 ページで記録し、テーマごとの調査結果を `research/` に書く
- 調査の進め方や対象範囲の決めごとは `references/` に置く
- 調査で出た問いや次に調べることは `ideas/` に置く

## wiki のディレクトリを足すとき

6 分類で足りないときだけ足す。足すときは次の 5 か所を揃える。

1. `.claude/rules/wiki.md` の「構成」の表
2. `.claude/skills/wiki-write/SKILL.md` の「置き場所の判断」と、frontmatter 規約の `type` (ディレクトリ固有の必須フィールドがあればそれも)
3. `.claude/skills/wiki-lint/SKILL.md` の機械的な点検 (ディレクトリ固有の必須フィールドがあるとき)
4. `wiki/template.md` の `type` と `cp` のコメント (ディレクトリと `type` の対応)
5. `wiki/index.md` の「分類」

## wiki が大きくなったら

次の機能は、必要になってから足す。

- **全文検索ツール**: ページが数百を超えて `rg` と `list-pages.sh` で探しにくくなったら、Markdown 向けの検索ツール
  ([qmd](https://github.com/tobi/qmd) など) を入れ、`.claude/rules/wiki.md` の「探し方」に使い方を書く
- **点検の自動化**: frontmatter の崩れやリンク切れが頻繁に起きるようになったら、`wiki-lint` の機械的な点検をスクリプトにし、
  Claude Code の hook (`PostToolUse`) で `wiki/` の編集のたびに実行する
- **取り込みを別のコンテキストで行う**: 一度に多数の資料を取り込んでメインの会話のコンテキストが埋まるようになったら、
  `wiki-ingest` を `context: fork` にしてサブエージェントで実行し、報告だけを受け取る
- **読み取り専用の検索 skill**: wiki を調べる途中経過でメインの会話のコンテキストが埋まるようになったら、
  サブエージェントで検索して答えと参照ページだけを返す skill (`context: fork`) を足す
