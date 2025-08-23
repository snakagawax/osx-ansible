#!/bin/bash
# VS Code拡張機能バックアップスクリプト

# 現在のディレクトリを取得
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

echo "=== VS Code拡張機能バックアップ ==="
echo "保存先: $SCRIPT_DIR/vscode_extensions.txt"

# 拡張機能リストを生成
if command -v code &> /dev/null; then
    code --list-extensions > "$SCRIPT_DIR/vscode_extensions.txt"
    
    # バックアップ完了メッセージ
    EXTENSION_COUNT=$(wc -l < "$SCRIPT_DIR/vscode_extensions.txt")
    echo "✅ $EXTENSION_COUNT 個の拡張機能をバックアップしました"
    echo ""
    echo "📋 バックアップされた拡張機能:"
    cat "$SCRIPT_DIR/vscode_extensions.txt"
else
    echo "❌ VS Code (code コマンド) が見つかりません"
    echo "VS Codeがインストールされていることを確認してください"
    exit 1
fi