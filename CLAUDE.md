# cc_dev_team — Claude Code 開発チームエージェント群

## このリポジトリは何か

Claude Code で Web アプリを開発する際に使う **エージェント・コマンド・ルール・設定ファイル一式** を管理するリポジトリ。
ここで作成したファイルを、実際の開発プロジェクトの `.claude/` ディレクトリにコピーして使う。

**このリポジトリ自体はアプリケーションではない。** コードの実行やビルドは行わない。

## 想定する利用シーン

1. 新しいWebアプリプロジェクトを作る
2. `dot_claude/CLAUDE.project.template.md` をコピーして技術スタックを選択・編集する
3. `bash dot_claude/scripts/setup.sh /path/to/my-project` を実行する
4. プロジェクトの `.claude/` にエージェント群が配置され、`/design` → `/dev-start` → `/dev-task` のワークフローで開発を進める

## ディレクトリ構成

```
dot_claude/                          ← 成果物（プロジェクトにコピーされるファイル群）
├── CLAUDE.base.md                   # PM ワークフロー定義（不変部分）
├── CLAUDE.project.template.md       # プロジェクト固有設定のテンプレート
├── agents/                          # 20 サブエージェント定義
│   ├── design-architect.md          #   設計エージェント
│   ├── beads-manager.md             #   Beads タスク管理
│   ├── git-manager.md               #   Git 操作
│   ├── nextjs-specialist.md         #   Next.js アドバイザー
│   ├── react-vite-specialist.md     #   React+Vite アドバイザー
│   ├── frontend-engineer.md         #   フロントエンド実装
│   ├── backend-engineer.md          #   バックエンド実装
│   ├── db-designer.md               #   DB 設計（汎用）
│   ├── supabase-specialist.md       #   Supabase（DB+Auth+RLS）
│   ├── web-designer.md              #   CSS Modules スタイリング
│   ├── infra-engineer.md            #   デプロイ・CI/CD
│   ├── security-specialist.md       #   セキュリティ監査
│   ├── frontend-code-reviewer.md    #   FE コードレビュー
│   ├── backend-code-reviewer.md     #   BE コードレビュー
│   ├── frontend-test-engineer.md    #   FE テスト設計・実装・実行
│   ├── backend-test-engineer.md     #   BE テスト設計・実装・実行
│   ├── frontend-test-reviewer.md    #   FE テスト十分性チェック
│   ├── backend-test-reviewer.md     #   BE テスト十分性チェック
│   ├── frontend-test-judge.md       #   FE テスト結果判定
│   └── backend-test-judge.md        #   BE テスト結果判定
├── commands/                        # 4 スラッシュコマンド
│   ├── design.md                    #   /design — 設計フェーズ
│   ├── dev-start.md                 #   /dev-start — 開発開始
│   ├── dev-task.md                  #   /dev-task <id> — タスクパイプライン
│   └── dev-rollback.md              #   /dev-rollback <id> — ロールバック
├── rules/                           # 自動適用ルール
│   ├── bash-single-line.md          #   Bash 単一行実行（常時）
│   ├── no-tailwind.md               #   Tailwind 禁止（常時）
│   ├── nextjs-edge-runtime.md       #   Edge Runtime 制約（middleware.ts 触った時）
│   ├── chrome-extension-e2e.md      #   Chrome 拡張 E2E 制約（manifest.json 等触った時）
│   └── mandatory-testing.md         #   テスト必須ルール
├── references/                      # 詳細ガイド（ルールから参照される）
│   └── chrome-extension-e2e-test-guide.md
├── scripts/
│   └── setup.sh                     # プロジェクトへの配置スクリプト
└── settings.json                    # パーミッション・フック設定
```

## 技術的な前提

- **フレームワーク**: Next.js (App Router) または React + Vite（プロジェクトごとに選択）
- **DB/Auth**: Supabase（基本）
- **デプロイ**: Vercel（基本、他も対応可）
- **タスク管理**: Beads（グラフベースのタスクトラッカー）
- **スタイリング**: CSS Modules（Tailwind CSS は禁止）
- **テスト**: Jest + Playwright

## 設計思想

### CLAUDE.md の分離（base + project）
- `CLAUDE.base.md`: ワークフロー定義・ルール・エージェント一覧（全プロジェクト共通）
- `CLAUDE.project.template.md`: 技術スタック・Git戦略・設計ドキュメント構成（プロジェクトごとに編集）
- `setup.sh` が両者を結合して、プロジェクトの `CLAUDE.md` を生成する

### PM = メイン会話
- Claude Code の制約上、サブエージェントは他のサブエージェントを呼べない
- そのため PM（プロジェクトマネージャー）はサブエージェントではなく、メイン会話が担う
- PM のワークフロー定義は `CLAUDE.base.md` と commands/ に記述されている

### 開発パイプライン
```
実装 → コードレビュー → テスト実装 → テストレビュー → テスト実行 → テスト結果判定 → 完了
```
- 各ステップで NG の場合は実装に戻る（2回まで）
- 3回 NG → ロールバック（新タスク作成、旧タスクの失敗記録を引き継ぎ）
- 4回ロールバック → 停止してユーザーに通知

### ルール（Rules + paths）
- 常時適用ルール: Bash 単一行、Tailwind 禁止
- 条件付きルール: 特定ファイルを Read した時だけ発動（コンテキスト効率）
- スペシャリストの知識とルールのハイブリッド: 設計時はスペシャリストが事前検出、実装時はルールがセーフティネット

## このリポジトリでの作業ルール

- `dot_claude/` 以下のファイルを編集・追加する
- このリポジトリの `.claude/` は**このリポジトリ自体のローカル設定**であり、成果物ではない
- コミットメッセージは Conventional Commits（`feat:`, `fix:`, `docs:` 等）
- Bash コマンドは `&&` 等でチェインしない（1つずつ個別に実行）
