#!/bin/bash
#
# setup.sh - dot_claude のファイルをプロジェクトの .claude/ にセットアップするスクリプト
#
# 使い方:
#   1. dot_claude/CLAUDE.project.template.md を dot_claude/CLAUDE.project.md にコピーして編集
#   2. このスクリプトを実行:
#      bash dot_claude/scripts/setup.sh <プロジェクトのパス>
#
# 例:
#   bash dot_claude/scripts/setup.sh /path/to/my-project
#
# 実行されること:
#   - CLAUDE.base.md + CLAUDE.project.md → プロジェクトの CLAUDE.md に結合
#   - agents/ → プロジェクトの .claude/agents/ にコピー
#   - commands/ → プロジェクトの .claude/commands/ にコピー
#   - rules/ → プロジェクトの .claude/rules/ にコピー
#   - settings.json → プロジェクトの .claude/settings.json にコピー

set -euo pipefail

# --- 引数チェック ---
if [ $# -lt 1 ]; then
    echo "使い方: bash $0 <プロジェクトのパス>"
    echo "例:     bash $0 /path/to/my-project"
    exit 1
fi

PROJECT_DIR="$1"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DOT_CLAUDE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# --- ファイル存在チェック ---
if [ ! -f "$DOT_CLAUDE_DIR/CLAUDE.base.md" ]; then
    echo "エラー: $DOT_CLAUDE_DIR/CLAUDE.base.md が見つかりません"
    exit 1
fi

if [ ! -f "$DOT_CLAUDE_DIR/CLAUDE.project.md" ]; then
    echo "エラー: $DOT_CLAUDE_DIR/CLAUDE.project.md が見つかりません"
    echo ""
    echo "CLAUDE.project.template.md をコピーして、プロジェクトに合わせて編集してください:"
    echo "  cp $DOT_CLAUDE_DIR/CLAUDE.project.template.md $DOT_CLAUDE_DIR/CLAUDE.project.md"
    exit 1
fi

if [ ! -d "$PROJECT_DIR" ]; then
    echo "エラー: プロジェクトディレクトリ $PROJECT_DIR が見つかりません"
    exit 1
fi

# --- セットアップ実行 ---
TARGET_CLAUDE_DIR="$PROJECT_DIR/.claude"

echo "=== cc_dev_team セットアップ ==="
echo "ソース:   $DOT_CLAUDE_DIR"
echo "ターゲット: $TARGET_CLAUDE_DIR"
echo ""

# .claude ディレクトリ作成
mkdir -p "$TARGET_CLAUDE_DIR/agents"
mkdir -p "$TARGET_CLAUDE_DIR/commands"
mkdir -p "$TARGET_CLAUDE_DIR/rules"
mkdir -p "$TARGET_CLAUDE_DIR/references"

# CLAUDE.md を結合生成
echo "CLAUDE.md を生成中..."
{
    cat "$DOT_CLAUDE_DIR/CLAUDE.base.md"
    echo ""
    echo "---"
    echo ""
    cat "$DOT_CLAUDE_DIR/CLAUDE.project.md"
} > "$PROJECT_DIR/CLAUDE.md"
echo "  → $PROJECT_DIR/CLAUDE.md"

# agents をコピー
echo "agents/ をコピー中..."
cp "$DOT_CLAUDE_DIR/agents/"*.md "$TARGET_CLAUDE_DIR/agents/"
echo "  → $TARGET_CLAUDE_DIR/agents/ ($(ls "$DOT_CLAUDE_DIR/agents/"*.md | wc -l) files)"

# commands をコピー
echo "commands/ をコピー中..."
cp "$DOT_CLAUDE_DIR/commands/"*.md "$TARGET_CLAUDE_DIR/commands/"
echo "  → $TARGET_CLAUDE_DIR/commands/ ($(ls "$DOT_CLAUDE_DIR/commands/"*.md | wc -l) files)"

# rules をコピー
echo "rules/ をコピー中..."
cp "$DOT_CLAUDE_DIR/rules/"*.md "$TARGET_CLAUDE_DIR/rules/"
echo "  → $TARGET_CLAUDE_DIR/rules/ ($(ls "$DOT_CLAUDE_DIR/rules/"*.md | wc -l) files)"

# references をコピー
if ls "$DOT_CLAUDE_DIR/references/"*.md 1> /dev/null 2>&1; then
  echo "references/ をコピー中..."
  cp "$DOT_CLAUDE_DIR/references/"*.md "$TARGET_CLAUDE_DIR/references/"
  echo "  → $TARGET_CLAUDE_DIR/references/ ($(ls "$DOT_CLAUDE_DIR/references/"*.md | wc -l) files)"
fi

# settings.json をコピー
echo "settings.json をコピー中..."
cp "$DOT_CLAUDE_DIR/settings.json" "$TARGET_CLAUDE_DIR/settings.json"
echo "  → $TARGET_CLAUDE_DIR/settings.json"

# tmp ディレクトリ作成
mkdir -p "$PROJECT_DIR/tmp"
echo "tmp/ を作成..."
echo "  → $PROJECT_DIR/tmp/"

echo ""
echo "=== セットアップ完了 ==="
echo ""
echo "配置されたもの:"
echo "  - CLAUDE.md (base + project 結合)"
echo "  - .claude/agents/ (20 エージェント)"
echo "  - .claude/commands/ (4 コマンド: /design, /dev-start, /dev-task, /dev-rollback)"
echo "  - .claude/rules/"
echo "  - .claude/references/ (詳細ガイド)"
echo "  - .claude/settings.json"
echo "  - tmp/ (一時ファイル用)"
echo ""
echo "次のステップ:"
echo "  1. $PROJECT_DIR/CLAUDE.md の内容を確認してください"
echo "  2. $TARGET_CLAUDE_DIR/settings.json のパーミッションを確認してください"
echo "  3. Supabaseを使う場合は、環境変数 SUPABASE_URL, SUPABASE_SERVICE_KEY を設定してください"
echo "  4. /design で設計フェーズを開始してください"
