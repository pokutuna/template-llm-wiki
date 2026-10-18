# wiki の OKF プロファイル

`wiki/` は [OKF (Open Knowledge Format) v0.2](https://github.com/GoogleCloudPlatform/knowledge-catalog/blob/main/okf/SPEC.md)
に適合する形で運用する。OKF の任意仕様はすべては採用せず、エージェントが日常的に読み書きする小さな wiki に必要なものだけを選んでいる。
この文書は、何を採用し何を見送ったかと、その理由を残す。運用ルールそのものは `.claude/rules/wiki.md` (読み方) と
`.claude/skills/wiki-write/SKILL.md` (書き方) にある。

準拠する仕様: `okf/SPEC.md` (Version 0.2、2026-08-21 時点)

## 適合条件

OKF v0.2 の適合条件は次の 3 つだけで、このプロファイルはすべて満たす。

1. `index.md` と `log.md` 以外のすべての `.md` ファイルに、パースできる YAML frontmatter がある
2. すべての frontmatter に空でない `type` がある
3. `index.md` (と `log.md`) が仕様の構造に従う

このため `wiki/` には frontmatter の無い `.md` を置かない。雛形の `wiki/template.md` も条件 2 を満たすように `type: Template` を持つ。
OKF の読み手は知らない `type` を一般的な concept として扱うので、`Template` という値で問題は起きない。
コピー後に書き換え忘れたページは `rg '^type: Template' wiki/` で見つけられる。

## frontmatter

| OKF の仕様 | このプロファイル | 理由 |
| --- | --- | --- |
| `type` (必須) | 必須。ディレクトリと 1 対 1 に対応させる | 置き場所を決めれば `type` も決まるので、分類を 2 回判断しなくて済む |
| `title` / `description` (推奨) | 必須 | エージェントは `list-pages.sh` の出力と `index.md` を見て、ページを開く前に読むべきかを判断する |
| `tags` (推奨) | 推奨 | |
| `resource` (推奨) | `sources/` では必須、他は任意 | 抽象的な知見のページが多く、対象の無いページが普通にある。Source ページは資料そのものを説明するので、資料のルート URL を必ず持つ |
| `sources` (任意) | `references/` `sources/` `research/` では必須、`findings/` では推奨 | 出典の記載を必須にして、実際に読んでいない資料に基づく調査ページを作らせない。Source ページでは、資料のうち実際に読んだページの一覧になる |
| `sources[].id` と脚注 | 個別の主張に出典を付けるときだけ | 位置ではなく id で引くので、エージェントがリストを並べ替えても出典がずれない |
| `sources[]` の `author` / `usage_count` / `last_modified`、`usage_window` | 不採用 | 組織横断のカタログ向けの信頼度シグナルで、個人・小規模の wiki では記録する手間に見合わない |
| `generated: { by, at }` | 推奨 | 更新日時に加えて、誰 (人かエージェントか) が書いたかも残る |
| `verified` | 任意。人が確認したときだけ | エージェントが書いたページと人が確かめたページを区別できる。機械検証の記録までは求めない |
| `status` (`draft` / `stable` / `deprecated`) | `deprecated` だけ使う | 現行でなくなったページを、消さずに区別するために使う。`draft` と `stable` の境界は書き手ごとに判断が分かれるので使わない |
| `stale_after` | 不採用 | 期限を事前に決められるページが少ない |
| Attested Computation (`type` と計算系のキー) | 不採用 | 数値の算出手順を検証する仕組みで、この wiki の用途に無い |
| (独自) `progress` | `Idea` で必須 | アイデアの進捗 (`open` / `doing` / `done` / `dropped`)。OKF の `status` はページが現行かどうかを表すので、進捗には別のキーを使う |

日時は OKF の要求どおり、オフセット付きの ISO 8601 で書く (例: `2026-10-18T15:00:00+09:00`)。
actor は OKF の規約どおり、エージェントは `<ツール名>/<モデル名>`、人は `human:<id>` とする。

## リンクとパス

- OKF はバンドルルートからの絶対パス (`/references/foo.md`) を推奨しているが、このプロファイルでは**相対パス**を使う。
  `wiki/` はリポジトリのサブディレクトリなので、`/` 始まりのリンクは GitHub やエディタのプレビューではリポジトリルート基準で解決され、リンクが切れる。
  相対パスも OKF で認められている
- frontmatter のパス (`resource`、`sources[].resource`) も、リポジトリ内を指すときはページからの相対パスにする (例: `../../src/foo.ts`)。
  OKF では `/` 始まりでない相対パスはそのページ基準で解釈されるため、`src/foo.ts` と書くと `wiki/<dir>/src/foo.ts` を指すことになる
- `sources[].resource` には、外部資料の URL の代わりに Source ページ (`../sources/<slug>.md`) を書いてよい。
  OKF では `resource` が別の concept を指すと、それが派生元のつながり (lineage) になり、読み手はその先の `sources` を辿れる (§5.1)
- 本文中でファイルに言及するだけのとき (コードスパン) は、読みやすさを優先してリポジトリルートからのパスで書く

## index.md と log.md

- `index.md` はバンドルルートにだけ置き、`okf_version: "0.2"` を宣言する。中身は全ページの一覧ではなく、重要ページと各ディレクトリへの入口とする
- 各ディレクトリの `index.md` は作らない。OKF では任意で、一覧は `wiki/scripts/list-pages.sh` で frontmatter から合成できる
- `log.md` は作らない。OKF では任意である。作業の経緯は `notes/` に 1 件 1 ページで残す。
  1 ファイルに追記し続ける `log.md` と違い、ページごとの `description` で探せる

## references/ の名前

OKF には「`references/` に外部資料や実行手順をバンドル内の concept として置く」という命名の慣習がある (必須ではない)。
このプロファイルの `references/` は「従う手順・制約・前提知識」を置く場所で、手順を置く点では慣習と重なる。
外部資料は `references/` ではなく `sources/` で扱う。`sources/` には資料の写しを置かず、リンク、含まれている内容、要約、短い抜粋を
資料ごとに 1 ページで残す。写しを持たないので、資料の著作権やサイズを気にせずに記録できる。資料が更新されても、Source ページのリンクから最新の内容を開いて確かめられる。
