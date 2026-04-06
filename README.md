# cc_dev_team

Claude Code で Web アプリを開発するための **エージェントチーム** 一式です。  
20 の専門エージェント、4 つのワークフローコマンド、自動適用ルールを提供します。

## 概要

新しい Web アプリプロジェクトに `dot_claude/` の内容をコピーすると、  
設計 → タスク分解 → 実装 → コードレビュー → テスト → マージ  
の開発パイプラインが自動的にセットアップされます。

## セットアップ

```bash
# 1. テンプレートをコピーして、技術スタック等を編集
cp dot_claude/CLAUDE.project.template.md dot_claude/CLAUDE.project.md

# 2. プロジェクトに配置
bash dot_claude/scripts/setup.sh /path/to/my-project
```

これにより、プロジェクトに以下が配置されます：
- `CLAUDE.md` — PM ワークフロー定義
- `.claude/agents/` — 20 エージェント
- `.claude/commands/` — 4 コマンド (`/design`, `/dev-start`, `/dev-task`, `/dev-rollback`)
- `.claude/rules/` — 自動適用ルール
- `.claude/references/` — 詳細ガイド
- `.claude/settings.json` — パーミッション設定

## 使い方

プロジェクトで Claude Code を起動し、以下のコマンドでワークフローを進めます：

| コマンド | 説明 |
|---|---|
| `/design` | 要件定義から設計ドキュメントを作成し、Beads タスクに分解 |
| `/dev-start` | 実行可能なタスクを取得し、開発パイプラインを開始 |
| `/dev-task <id>` | 単一タスクの開発パイプラインを実行 |
| `/dev-rollback <id>` | タスクのロールバック処理 |

## エージェント構成

| 層 | エージェント |
|---|---|
| オーケストレーション | 設計エージェント, Beads 管理者, Git 管理者 |
| スペシャリスト | Next.js, React+Vite |
| 実装 | フロントエンド, バックエンド, DB 設計, Supabase, Web デザイナー, インフラ, セキュリティ |
| レビュー | FE/BE コードレビュアー |
| テスト | FE/BE テストエンジニア, FE/BE テストレビュアー, FE/BE テストジャッジ |

## 技術スタック（選択式）

| 項目 | 選択肢 |
|---|---|
| フレームワーク | Next.js (App Router) **or** React + Vite |
| DB/Auth | Supabase |
| デプロイ | Vercel / Netlify / Cloudflare Pages 等 |
| スタイリング | CSS Modules（Tailwind CSS 禁止） |
| タスク管理 | [Beads](https://github.com/gastownhall/beads) |
| テスト | Jest + Playwright |

## 開発パイプライン

```
実装 → コードレビュー → テスト実装 → テストレビュー → テスト実行 → テスト結果判定 → 完了
         ↑ NG(2回まで)                                        ↑ NG(2回まで)
         └─ 再実装                                             └─ 再実装
         ↑ NG(3回目〜)                                        ↑ NG(3回目〜)
         └─ ロールバック                                       └─ ロールバック
```

## ディレクトリ構成

```
dot_claude/
├── CLAUDE.base.md                 # PM ワークフロー定義（全プロジェクト共通）
├── CLAUDE.project.template.md     # プロジェクト固有設定テンプレート
├── agents/                        # 20 サブエージェント
├── commands/                      # 4 スラッシュコマンド
├── rules/                         # 自動適用ルール（paths 条件付き）
├── references/                    # 詳細ガイド
├── scripts/setup.sh               # プロジェクトへの配置スクリプト
└── settings.json                  # パーミッション・フック設定
```

## ライセンス

MIT
