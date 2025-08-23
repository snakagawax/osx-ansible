#!/bin/bash
# VS Code拡張機能インストールスクリプト

# 現在のディレクトリを取得
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
EXTENSIONS_FILE="$SCRIPT_DIR/vscode_extensions.txt"

echo "=== VS Code拡張機能インストール ==="

# VS Codeがインストールされているかチェック
if ! command -v code &> /dev/null; then
    echo "❌ VS Code (code コマンド) が見つかりません"
    echo "VS Codeがインストールされていることを確認してください"
    echo "公式サイト: https://code.visualstudio.com/"
    exit 1
fi

# 拡張機能リストファイルが存在するかチェック
if [ ! -f "$EXTENSIONS_FILE" ]; then
    echo "❌ 拡張機能リストファイルが見つかりません: $EXTENSIONS_FILE"
    echo "先に backup_extensions.sh を実行してください"
    exit 1
fi

# 拡張機能数を取得
TOTAL_EXTENSIONS=$(wc -l < "$EXTENSIONS_FILE")
echo "📦 $TOTAL_EXTENSIONS 個の拡張機能をインストールします..."
echo ""

# カウンタ初期化
CURRENT=0
FAILED=0

# 拡張機能を一つずつインストール
while IFS= read -r extension; do
    # 空行やコメント行をスキップ
    [[ -z "$extension" || "$extension" =~ ^#.*$ ]] && continue
    
    CURRENT=$((CURRENT + 1))
    echo "[$CURRENT/$TOTAL_EXTENSIONS] Installing: $extension"
    
    # 拡張機能をインストール
    if code --install-extension "$extension" --force > /dev/null 2>&1; then
        echo "  ✅ 成功"
    else
        echo "  ❌ 失敗"
        FAILED=$((FAILED + 1))
    fi
done < "$EXTENSIONS_FILE"

echo ""
echo "=== インストール完了 ==="
echo "✅ 成功: $((CURRENT - FAILED)) 個"
if [ $FAILED -gt 0 ]; then
    echo "❌ 失敗: $FAILED 個"
    echo ""
    echo "失敗した拡張機能は手動でインストールしてください:"
    echo "VS Code → Extensions (⌘+Shift+X) → 検索してインストール"
fi

echo ""
echo "VS Codeを再起動して拡張機能の動作を確認してください。"