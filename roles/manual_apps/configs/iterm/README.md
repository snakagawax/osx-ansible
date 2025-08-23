# iTerm2 設定移行手順

## 概要
iTerm2のプロファイル、カラーテーマ、キーバインド、フォント設定、Dynamic Profilesを完全に別のMacへ移行する手順

## インストール
公式サイトから最新版をダウンロード: https://iterm2.com/

## 設定ファイルの構造と場所

### 1. メイン設定（Preferences）
- **パス**: `~/Library/Preferences/com.googlecode.iterm2.plist`
- **内容**: プロファイル・カラーテーマ・キーバインド・一般設定など、ほぼすべてを含む

### 2. Dynamic Profiles（任意）
- **パス**: `~/.iterm2/` または任意フォルダの `*.json`
- **内容**: 複数Mac共用を想定したJSON形式のプロファイル定義

### 3. カラースキーム（Color Presets）
- **パス**: `~/Library/Application Support/iTerm2/DynamicProfiles/` または任意フォルダ
- **内容**: カスタム `.itermcolors` ファイル

### 4. カスタムフォント
- **パス**: `~/Library/Fonts/` または `/Library/Fonts/`
- **内容**: Nerd Font等のターミナル用フォント

## バックアップ方法

### 方法1: 手動バックアップ（推奨）
```bash
# iTerm2を終了してplistが確実に書き出されるのを待つ
pkill iTerm2

# バックアップディレクトリ作成
mkdir -p ~/Documents/iTerm2Backup/$(date +%Y-%m-%d)
cd ~/Documents/iTerm2Backup/$(date +%Y-%m-%d)

# メイン設定をバックアップ
cp ~/Library/Preferences/com.googlecode.iterm2.plist ./

# Dynamic Profilesをバックアップ（使用している場合）
cp -R ~/.iterm2 ./ 2>/dev/null || echo "No ~/.iterm2 directory found"

# Application Support内の設定をバックアップ
cp -R ~/Library/Application\ Support/iTerm2 ./ 2>/dev/null || echo "No iTerm2 Application Support found"

# カスタムフォントをバックアップ（必要に応じて）
mkdir -p ./Fonts
cp ~/Library/Fonts/*Nerd* ./Fonts/ 2>/dev/null || echo "No Nerd Fonts found"
```

### 方法2: Preference Syncing（クラウド同期）
iTerm2 3.3以降の公式機能：

1. **移行元Mac側**:
   - iTerm2 → Preferences → General → Preferences
   - 「Save changes to folder」をオンにし、Dropbox/iCloud Drive等の共有フォルダを指定
   - com.googlecode.iterm2.plistが指定フォルダに都度エクスポートされる

2. **移行先Mac側**:
   - 共有フォルダを同期
   - iTerm2 → 同じ画面で「Load preferences from a custom folder」をオンにし、同フォルダを選択
   - 即座に設定が反映、以後は2台で自動同期

## リストア方法

### 手動リストア
```bash
# iTerm2をまだ起動していない場合はそのまま、起動済みの場合は終了
pkill iTerm2

# バックアップから設定をリストア
cp /path/to/backup/com.googlecode.iterm2.plist ~/Library/Preferences/

# Dynamic Profilesをリストア（ある場合）
cp -R /path/to/backup/.iterm2 ~/

# Application Supportをリストア（ある場合）
cp -R /path/to/backup/iTerm2 ~/Library/Application\ Support/

# カスタムフォントをインストール（Font Bookで有効化）
cp /path/to/backup/Fonts/* ~/Library/Fonts/

# iTerm2を起動して設定確認
open -a iTerm
```

### defaultsコマンドを使ったリストア
```bash
# plistファイルをdefaultsでインポート
defaults import com.googlecode.iterm2 /path/to/backup/com.googlecode.iterm2.plist
```

## 移行後の確認・設定

### 1. 基本動作確認
- プロファイルが正しく読み込まれているか
- カラーテーマが適用されているか
- キーバインドが動作するか（⌘+D分割、⌘+Tタブ等）

### 2. macOS権限の再設定
「システム設定」→「プライバシーとセキュリティ」で以下を許可：
- **アクセシビリティ**: iTerm.app
- **フルディスクアクセス**: iTerm.app（必要に応じて）
- **画面収録**: iTerm.app（tmux使用時等）

### 3. フォントの確認
```bash
# インストールされたフォントを確認
fc-list | grep -i nerd
# または
ls ~/Library/Fonts/ | grep -i font
```

### 4. Dynamic Profilesの確認（使用している場合）
- iTerm2 → Preferences → Profiles でカスタムプロファイルが表示されるか

## トラブルシューティング

### 設定が反映されない
1. iTerm2を完全終了（⌘+Q）
2. `rm ~/Library/Preferences/com.googlecode.iterm2.plist.lockfile` でロックファイル削除
3. iTerm2を再起動

### キーバインドがおかしい
1. Preferences → Keys → Key Bindings
2. 「Load Preset」で適切なプリセットを選択

### カラーテーマが抜ける
1. カスタム.itermcolorsファイルのパスが絶対パスになっていないか確認
2. Preferences → Profiles → Colors で再度カラースキームを選択

### 日本語フォントが文字化け
1. Preferences → Profiles → Text
2. 「Non-ASCII Font」で日本語対応フォント（Hiragino、Noto等）を再指定

### プロファイルが重複する
- Dynamic ProfilesとPreferencesで同名プロファイルがある場合
- Dynamic Profiles側が優先されるため、不要なプロファイルを削除

## 高度な設定管理

### Gitでのバージョン管理
```bash
# 設定をGitで管理
mkdir ~/iTerm2Config
cd ~/iTerm2Config

# 定期的に設定をバックアップ
defaults export com.googlecode.iterm2 iTerm2.plist
cp -R ~/.iterm2 ./ 2>/dev/null
cp -R ~/Library/Application\ Support/iTerm2 ./ 2>/dev/null

git add .
git commit -m "Update iTerm2 settings $(date)"
```

### スクリプトによる自動バックアップ
```bash
#!/bin/bash
# ~/bin/backup_iterm2.sh
BACKUP_DIR="$HOME/Dropbox/iTerm2Backup/$(date +%Y-%m-%d)"
mkdir -p "$BACKUP_DIR"

defaults export com.googlecode.iterm2 "$BACKUP_DIR/com.googlecode.iterm2.plist"
cp -R ~/.iterm2 "$BACKUP_DIR/" 2>/dev/null
cp -R ~/Library/Application\ Support/iTerm2 "$BACKUP_DIR/" 2>/dev/null

echo "iTerm2 settings backed up to $BACKUP_DIR"
```

## 注意事項
- macOS 14以降では「App Sandbox」により、初回起動後にロックファイルが生成される場合がある
- Mac間でmacOSのメジャーバージョンが大きく異なる場合、一部設定が適用されない可能性がある
- 同期中に両方のMacで同時に設定変更すると競合する可能性があるため、Git管理推奨
- フォント設定は外部ファイル依存のため、フォントファイルも含めて移行すること