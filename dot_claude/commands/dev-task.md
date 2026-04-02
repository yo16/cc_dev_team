---
name: dev-task
description: 単一のBeadsタスクに対して、ブランチ作成→実装→コードレビュー→テスト→マージの開発パイプラインを実行する。
argument-hint: "<beads-task-id>"
user-invocable: true
---

# タスク開発パイプライン

引数で受け取ったBeadsタスクID: $ARGUMENTS に対して、以下のパイプラインを順番に実行する。

## ステップ1: 準備
1. Agent(`git-manager`): devからfeatureブランチを作成 (`feature/bd-{id}`)
2. Agent(`beads-manager`): タスクをオープンし、開始を宣言

## ステップ2: 実装
Agent(`beads-manager`) にタスクの要件を取得させ、タスク内容に応じた実装エンジニアを呼び出す:
- フロントエンド → Agent(`frontend-engineer`)
- バックエンド → Agent(`backend-engineer`)
- DB設計 → Agent(`db-designer`)
- Supabase実装 → Agent(`supabase-specialist`)
- スタイリング → Agent(`web-designer`)
- インフラ → Agent(`infra-engineer`)
- セキュリティ → Agent(`security-specialist`)

フレームワーク固有の判断が必要な場合は、Agent(`nextjs-specialist`) or Agent(`react-vite-specialist`) に相談する。

## ステップ3: コードレビュー
タスク内容に応じたコードレビュアーを呼び出す:
- フロントエンド → Agent(`frontend-code-reviewer`)
- バックエンド → Agent(`backend-code-reviewer`)

レビュアーにはBeadsタスクの要件を渡し、git logベースで変更内容を照合させる。

### レビュー結果の処理
- **OK** → ステップ4へ
- **NG** →
  1. Agent(`beads-manager`): NG理由とNG回数を記録
  2. 2回目のNGまで → ステップ2に戻り再実装
  3. 3回目以降のNG → `/dev-rollback {id}` を実行

## ステップ4: テスト実装
タスク内容に応じたテストエンジニアを呼び出す:
- フロントエンド → Agent(`frontend-test-engineer`)
- バックエンド → Agent(`backend-test-engineer`)

## ステップ5: テストレビュー
タスク内容に応じたテストレビュアーを呼び出す:
- フロントエンド → Agent(`frontend-test-reviewer`)
- バックエンド → Agent(`backend-test-reviewer`)

- **NG** → ステップ4に戻る

## ステップ6: テスト実行
ステップ4と同じテストエンジニアにテスト実行を指示する。

## ステップ7: テスト結果判定
タスク内容に応じたテストジャッジを呼び出す:
- フロントエンド → Agent(`frontend-test-judge`)
- バックエンド → Agent(`backend-test-judge`)

### 判定結果の処理
- **OK** → ステップ8へ
- **NG** →
  1. Agent(`beads-manager`): NG理由とNG回数を記録
  2. 2回目のNGまで → ステップ2に戻り再実装
  3. 3回目以降のNG → `/dev-rollback {id}` を実行

## ステップ8: 完了
1. Agent(`beads-manager`): タスクをクローズし、終了を宣言
2. Agent(`git-manager`): featureブランチにコミットし、devブランチへマージ
