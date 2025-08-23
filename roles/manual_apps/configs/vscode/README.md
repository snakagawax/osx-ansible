# Visual Studio Code 設定移行手順

## 概要
VS Codeの設定、キーバインド、拡張機能、スニペット、ワークスペース設定を完全に別のMacへ移行する手順

## インストール
公式サイトから最新版をダウンロード: https://code.visualstudio.com/

## 移行方法の選択

### 方法1: Microsoft公式Settings Sync（推奨）
最も簡単で漏れが少ない方法

### 方法2: 手動バックアップ・リストア
オフライン環境や細かく管理したい場合

---

## 方法1: Settings Sync（公式同期）

### 移行元Mac側
1. VS Code v1.48以降で、ステータスバー右下の「アカウント」アイコンをクリック
2. 「設定の同期をオンにする」を選択
3. Microsoft／GitHubアカウントでサインイン
4. 同期対象を確認してチェック：
   - 設定（Settings）
   - キーバインド（Keybindings）
   - 拡張機能（Extensions）
   - ユーザースニペット（User Snippets）
   - UI状態（UI State）
   - タスク／デバッグ構成（Tasks & Debug Configuration）

### 移行先Mac側
1. VS Codeをインストール
2. 同じアカウントでサインイン
3. 「同期をオン」を選択
4. 初回は「ダウンロードしてマージ」または「置き換え」を選択
5. 数秒〜数分で拡張機能が自動インストールされ、設定が反映

### Settings Syncのメリット
- クリック数回で完了
- OS間（Windows ↔ macOS等）でも動作
- 設定の差分が自動マージされる
- 複数デバイス間での継続的同期

---

## 方法2: 手動バックアップ・リストア

### 設定ファイルの構造と場所

#### ユーザースコープ
```
~/Library/Application Support/Code/User/
├── settings.json           # 基本設定
├── keybindings.json        # キーバインド
├── snippets/               # カスタムスニペット（各言語用.code-snippets）
├── globalStorage/          # 拡張機能のグローバルデータ
└── workspaceStorage/       # ワークスペース固有データ
```

#### 拡張機能
```
~/.vscode/extensions/       # インストールされた拡張機能
```

#### ワークスペース／フォルダスコープ
```
プロジェクト/.vscode/
├── settings.json           # ワークスペース設定
├── launch.json             # デバッグ設定
├── tasks.json              # タスク設定
└── extensions.json         # 推奨拡張機能
```

### バックアップ方法

#### 完全バックアップ
```bash
# バックアップディレクトリ作成
mkdir -p ~/Documents/VSCodeBackup/$(date +%Y-%m-%d)
cd ~/Documents/VSCodeBackup/$(date +%Y-%m-%d)

# ユーザー設定をバックアップ
cp -R ~/Library/Application\ Support/Code/User ./User

# 拡張機能をバックアップ（フォルダ全体）
cp -R ~/.vscode/extensions ./extensions

# 拡張機能リストを生成（軽量な代替方法）
code --list-extensions > ./extensions.txt

# 拡張機能の詳細情報も含める場合
code --list-extensions --show-versions > ./extensions_with_versions.txt
```

#### 自動化スクリプト
拡張機能の自動バックアップスクリプトを作成（後述）

### リストア方法

#### 完全リストア
```bash
# ユーザー設定のリストア
rm -rf ~/Library/Application\ Support/Code/User
cp -R /path/to/backup/User ~/Library/Application\ Support/Code/

# 拡張機能のリストア（フォルダ全体）
rm -rf ~/.vscode/extensions
cp -R /path/to/backup/extensions ~/.vscode/extensions

# または拡張機能リストからインストール
cat /path/to/backup/extensions.txt | xargs -L1 code --install-extension
```

#### スクリプト化されたリストア
```bash
#!/bin/bash
# restore_vscode.sh

BACKUP_DIR="/path/to/backup"

echo "Restoring VS Code settings..."
cp -R "$BACKUP_DIR/User" ~/Library/Application\ Support/Code/

echo "Installing extensions..."
cat "$BACKUP_DIR/extensions.txt" | while read extension; do
    echo "Installing $extension..."
    code --install-extension "$extension"
done

echo "VS Code restoration complete!"
```

### ワークスペース設定の移行
プロジェクト毎の`.vscode/`フォルダは：
- **Git管理推奨**: チーム共有する場合
- **手動コピー**: 個人設定の場合

```bash
# プロジェクト設定をGitに含める場合
git add .vscode/
git commit -m "Add VS Code workspace settings"

# 手動でバックアップする場合
cp -R .vscode/ /backup/location/project_name/.vscode/
```

---

## 移行後の確認事項

### 1. 基本設定の確認
- エディタのテーマ・フォントサイズ
- タブサイズ・インデント設定
- 自動保存設定

### 2. 拡張機能の確認
```bash
# インストールされた拡張機能を確認
code --list-extensions

# 特定の拡張機能の動作確認
# - GitLens: Gitの履歴表示
# - Prettier: コードフォーマット
# - Live Server: HTMLプレビュー
```

### 3. デバッグ設定の確認
- launch.json（デバッガ設定）
- tasks.json（ビルドタスク）
- プロジェクト固有の設定

### 4. テーマ・アイコン設定
- カスタムテーマが適用されているか
- ファイルアイコンテーマ

---

## トラブルシューティング

### 拡張機能がインストールされない
```bash
# VS Codeのバージョン確認
code --version

# 拡張機能を個別にインストール
code --install-extension ms-python.python

# 拡張機能の強制インストール
code --install-extension <extension-id> --force
```

### 設定が反映されない
1. VS Codeを完全に終了（⌘+Q）
2. 設定ファイルの権限を確認
3. VS Codeを再起動
4. Developer Tools（⌘+Shift+I）でエラーを確認

### 拡張機能の競合
1. 拡張機能を一時的に無効化して原因を特定
2. 問題のある拡張機能を削除・再インストール

### ARM ↔ Intel Mac間の移行
- 拡張機能の直接コピーは基本的に問題なし
- バイナリを含む拡張機能は一覧からの再インストールを推奨

---

## 高度な設定管理

### Settings Syncの無効化とローカル管理への切替
```bash
# Settings Syncを無効にしてローカル管理に変更
# VS Code → Settings Sync → Turn Off
```

### 企業環境での設定配布
```json
// settings.json での企業ポリシー例
{
    "extensions.autoUpdate": false,
    "telemetry.telemetryLevel": "off",
    "update.mode": "manual"
}
```

---

## 注意事項
- **バージョン統一**: 新旧Mac間でVS Codeのバージョンを揃える
- **プライベート拡張**: .vsixファイルは手動でインストール必要
- **ライセンス認証**: 一部の有料拡張機能は個別認証が必要
- **ワークスペース設定**: プロジェクト固有設定は別途管理
- **オフライン制限**: Settings SyncはインターネットアクセスMが必要