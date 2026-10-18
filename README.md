# template-llm-wiki

コーディングエージェントと一緒に育てる知識ベース `wiki/` を持つリポジトリのテンプレート。
調べたこと、試した結果、ハマったこと、設計判断を、会話で終わらせずに `wiki/` に貯めて、セッションを跨いで再利用する。

`wiki/` は [OKF (Open Knowledge Format) v0.2](https://github.com/GoogleCloudPlatform/knowledge-catalog/blob/main/okf/SPEC.md)
に適合する Markdown + YAML frontmatter のファイル群で、OKF の任意仕様のうち必要なものだけを採用している。

エージェントへの指示は、読むときと書くときで分けている。

- 読むときのルールは `.claude/rules/wiki.md` にあり、Claude Code は `wiki/` のファイルを扱うときだけ自動で読み込む
- 書くときの手順と規約は `.claude/skills/wiki-write/` にあり、Claude Code は wiki に書く場面でだけ読み込む
- 普段のコンテキストに常に入るのは、`CLAUDE.md` の数行と `wiki-write` skill の 1 行の説明だけ。点検の `wiki-lint` skill は、ユーザーが呼び出すまで読み込まれない

`AGENTS.md` を読むエージェント (Codex CLI など) は、`AGENTS.md` の表を見て、場面に応じたファイルを読む。

## 主要なファイル

| パス | 役割 |
| --- | --- |
| `CLAUDE.md` | エージェント向けの指示の本体。プロジェクトの説明、リポジトリ構成、wiki の使い方 |
| `AGENTS.md` | Claude Code 以外のエージェント向け。`CLAUDE.md` を読むよう指示し、どの場面でどのファイルを読むかの表を持つ |
| `.claude/rules/wiki.md` | wiki の構成と読み方。ページの探し方、古い記述の見分け方、質問に答えるときの決まり。frontmatter の `paths` により、`wiki/` を扱うときに自動で読み込まれる |
| `.claude/skills/wiki-write/SKILL.md` | wiki の書き方。置き場所の判断、外部資料の取り込み、frontmatter と本文の規約、書いた後の確認 |
| `.claude/skills/wiki-lint/SKILL.md` | wiki の点検手順。ユーザーが `/wiki-lint` で呼び出したときだけ実行される |
| `wiki/index.md` | wiki の入口。`okf_version` の宣言、重要ページ、各ディレクトリへのリンク |
| `wiki/{references,sources,research,findings,notes,ideas}/` | ページの置き場所。ディレクトリと frontmatter の `type` が 1 対 1 で対応する |
| `wiki/template.md` | 新規ページの雛形。コピーして `type: Template` をディレクトリに対応する値に書き換える |
| `wiki/scripts/list-pages.sh` | ページの `title` と `description` を一覧する。ディレクトリや語で絞れる |
| `docs/` | 人が読む設計書・レポート・発表資料。wiki のルールの対象外 |
| `docs/okf-profile.md` | OKF のどの仕様を採用・不採用にしたかと、その理由 |

## wiki の構成

| 場所 | type | 内容 |
| --- | --- | --- |
| `wiki/references/` | `Reference` | 従う手順・制約・前提知識 |
| `wiki/sources/` | `Source` | 外部資料のどこに何が書いてあるか。資料 (ドキュメントサイト、リポジトリ、論文など) ごとに 1 ページ |
| `wiki/research/` | `Research` | 読んだ資料に基づく、テーマごとの調査結果 |
| `wiki/findings/` | `Finding` | 経験から得た理解・因果・教訓 |
| `wiki/notes/` | `Note` | 特定の作業・調査・障害の時点記録 (`yyyymmdd-<slug>.md`) |
| `wiki/ideas/` | `Idea` | これから試す案。`progress` で進捗を持つ |

`sources/` には外部資料の本文をコピーせず、リンク、含まれている内容、要約、短い抜粋を残す。
同じサイトの複数のページは 1 つの Source ページにまとめるので、次に調べるときは Source ページを見れば、どのページを開けばよいかが分かる。
`research/` は資料をまたいでテーマごとに分かったことを書き、出典として Source ページか資料の URL を `sources` に載せる。

`research/`、`findings/`、`sources/` は既存のページに追記して育て、`notes/` は日付付きで作って完了後は固定する。
アイデアは `ideas/` に書き、試した経緯を `notes/`、そこから得た教訓を `findings/` に残す。
重要なページはファイルの場所ではなく `wiki/index.md` の「重要」セクションで示す。

ページの frontmatter はこうなる:

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

詳しい規約は `.claude/skills/wiki-write/SKILL.md`、OKF との対応は `docs/okf-profile.md` を参照。

## wiki の使い方

| やりたいこと | 頼み方の例 | エージェントの動き |
| --- | --- | --- |
| 調べる | 「wiki に foo について何か書いてある?」 | 読むときのルールに従って必要なページだけを読み、参照したページを示して答える。wiki は書き換えない |
| 資料を取り込む | 「この URL を wiki に取り込んで」 | `wiki-write` に従い、Source ページを作るか追記して、資料から分かったことを `research/` などに反映する |
| 結果を残す | 「今の調査結果を wiki に残して」 | `wiki-write` に従い、置き場所を判断して既存ページに追記するか、新しいページを作る |
| 点検する | `/wiki-lint`、`/wiki-lint wiki/research` | 書式の崩れ、リンク切れ、矛盾、古い記述を報告する。直すのはユーザーが選んだものだけ |

大きな取り込みの後や定期的 (週 1 回など) に `/wiki-lint` を実行すると、リンク切れや記述の矛盾が溜まる前に見つけられる。

## セットアップ

### テンプレートから新しいリポジトリを作る

1. このリポジトリをテンプレートにして新しいリポジトリを作る (GitHub の "Use this template"、または `gh repo create <name> --template <owner>/template-llm-wiki`)
2. `CLAUDE.md` の冒頭にプロジェクト名と目的を書く
3. 下の「ディレクトリ構成の例」からドメインに合うものを選び、作業ディレクトリを作って `CLAUDE.md` の「リポジトリ構成」に書く
4. `wiki/index.md` の見出しをプロジェクト名に置き換える
5. タグの語彙が決まっているなら `.claude/skills/wiki-write/SKILL.md` の frontmatter 規約に例を書く (例: モデル名と主題を組み合わせる)
6. この README をプロジェクトの README に書き換える

### 既存のリポジトリに導入する

1. `.claude/rules/wiki.md`、`.claude/skills/wiki-write/`、`.claude/skills/wiki-lint/`、`wiki/`、`docs/okf-profile.md` をコピーする
2. `CLAUDE.md` の「wiki — 知識ベース」の節を、既存の `CLAUDE.md` (無ければ新規) に書き写す
3. Claude Code 以外のエージェントも使うなら `AGENTS.md` をコピーする。既存の `AGENTS.md` があれば「ルールと手順」の節を書き写す

### AGENTS.md を読まないエージェント

`AGENTS.md` も `CLAUDE.md` も読まないツールでは、そのツールの指示ファイルから `AGENTS.md` を参照させる
(設定で読み込むファイル名を `AGENTS.md` に変えられるツールもある)。
`.claude/rules/` と `.claude/skills/` のファイルは普通の Markdown なので、どのツールからでも読める。

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

`paths` を書かないルールは、Claude Code では常に読み込まれる。`.claude/rules/` の下にはルール以外の `.md` を置かない。
特定の作業でだけ必要な長い手順は、ルールではなく `.claude/skills/<name>/SKILL.md` に置くと、普段のコンテキストを圧迫しない。

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
- **読み取り専用の検索 skill**: wiki を調べる途中経過でメインの会話のコンテキストが埋まるようになったら、
  サブエージェントで検索して答えと参照ページだけを返す skill (`context: fork`) を足す
