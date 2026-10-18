# template-llm-wiki

コーディングエージェントが育てる知識ベース `wiki/` を持つリポジトリのテンプレート。
調べたこと、試した結果、ハマったこと、設計判断を、会話で終わらせずに `wiki/` に貯めて、セッションを跨いで再利用する。
`wiki/` は [OKF (Open Knowledge Format) v0.2](https://github.com/GoogleCloudPlatform/knowledge-catalog/blob/main/okf/SPEC.md) に適合する。

## 使い方

| やりたいこと | 頼み方の例 |
| --- | --- |
| 調べる | 「wiki に foo について何か書いてある?」 |
| 資料を取り込む | 「この URL を wiki に取り込んで」 |
| 結果を残す | 「今の調査結果を wiki に残して」 |
| 点検する | `/wiki-lint`、`/wiki-lint wiki/research` |

## セットアップ

### テンプレートから新しいリポジトリを作る

1. このリポジトリをテンプレートにして新しいリポジトリを作る
2. `CLAUDE.md` の「リポジトリ構成」をプロジェクトに合わせて書き換える
3. `wiki/index.md` の見出しをプロジェクト名に置き換える
4. この README をプロジェクトの README に書き換える

### 既存のリポジトリに導入する

1. `.claude/rules/`、`.claude/skills/`、`wiki/` をコピーする
2. `CLAUDE.md` の「wiki」の節の内容を、既存の `CLAUDE.md` に統合する
3. Claude Code 以外のエージェントも使うなら、`AGENTS.md` を `CLAUDE.md` への symlink にする
