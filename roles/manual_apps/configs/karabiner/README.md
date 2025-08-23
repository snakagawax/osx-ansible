# Karabiner-Elements 設定移行手順

## 概要
Karabiner-Elementsのキーマッピング、Complex Modifications、デバイス設定を完全に別のMacへ移行する手順

## インストール
公式サイトから最新版をダウンロード: https://karabiner-elements.pqrs.org/

## 設定ファイルの構造と場所

設定は `~/.config/karabiner/` フォルダに集約されています：

```
~/.config/karabiner/
├── karabiner.json                 # 全ての基本設定
├── assets/
│   ├── complex_modifications/     # 自作・ダウンロードしたJSON
│   └── resources/                 # アイコン等
├── automatic_backups/             # 自動バックアップ（zip）
└── log/                           # ログファイル
```

## バックアップ方法

### 方法1: フォルダ全体のバックアップ（推奨）
```bash
# 設定フォルダ全体を日付付きでバックアップ
mkdir -p ~/Documents/KarabinerBackup
rsync -avh --delete ~/.config/karabiner/ \
      ~/Documents/KarabinerBackup/karabiner_$(date +%Y-%m-%d)/
```

### 方法2: Finderで手動バックアップ
1. Finder → 「移動」→「フォルダへ移動...」
2. `~/.config` と入力してkarabinerフォルダを表示
3. karabinerフォルダ全体を外部メディア/クラウドにコピー

### 方法3: karabiner.jsonのみ（最小構成）
```bash
# 基本設定のみバックアップ
cp ~/.config/karabiner/karabiner.json ./karabiner_backup_$(date +%Y-%m-%d).json
```

## リストア方法

### 完全リストア（推奨）
```bash
# 新しいMacでKarabiner-Elementsを一度起動→終了して設定フォルダを作成
# 既存設定を退避（必要に応じて）
mv ~/.config/karabiner ~/.config/karabiner.backup

# バックアップした設定をリストア
rsync -avh --delete /path/to/backup/karabiner_2025-08-23/ ~/.config/karabiner/

# 設定を即座に反映（macOS 13以降）
launchctl kickstart -k gui/$(id -u)/org.pqrs.karabiner.karabiner_console_user_server
```

### 手動リストア
1. 新しいMacでKarabiner-Elementsを起動→終了
2. Finderで `~/.config/karabiner` を開く
3. 既存フォルダを削除またはリネーム
4. バックアップしたkarabinerフォルダをドラッグ&ドロップ
5. Karabiner-Elementsを再起動

## 移行後の必須設定

### 1. macOS権限の再許可
「システム設定」→「プライバシーとセキュリティ」で以下を許可：

- **入力監視**:
  - Karabiner-Elements
  - Karabiner-EventViewer
- **アクセシビリティ**:
  - Karabiner-Elements
  - Karabiner-DriverKit-VirtualHIDDevice

### 2. 動作確認
- キーマッピングが正常に動作するか
- Complex Modificationsが読み込まれているか
- デバイス固有の設定が適用されているか

## トラブルシューティング

### 設定が反映されない
```bash
# Karabinerプロセスを強制再起動
sudo launchctl stop org.pqrs.karabiner.karabiner_console_user_server
sudo launchctl start org.pqrs.karabiner.karabiner_console_user_server
```

### デバイスID不一致エラー
1. Karabiner-EventViewerを開く
2. 該当キーボードのVendor/Product IDを確認
3. karabiner.json内の`"identifiers"`を修正、または
4. 「Modify events from all devices」設定をオンにする

### JSON設定エラー
1. `~/.config/karabiner/automatic_backups/`から自動バックアップを確認
2. `karabiner.json.backup.*`ファイルがある場合はそちらを復元
3. オンラインJSONバリデーターでファイル構文をチェック

### 権限ダイアログが出ない
手動で権限を追加：
1. システム設定 → プライバシーとセキュリティ
2. 「入力監視」「アクセシビリティ」で「+」ボタン
3. `/Applications/Karabiner-Elements.app` を追加

## 高度な設定管理

### Gitでのバージョン管理（推奨）
```bash
# 設定をGitリポジトリ化
cd ~/.config
git init karabiner
cd karabiner
git add .
git commit -m "Initial Karabiner settings"

# GitHub等にプッシュして複数Mac間で共有
git remote add origin <your-private-repo>
git push -u origin main
```

### クラウド同期設定
- iCloudやDropboxに直接シンボリックリンクを張ることは非推奨
- 同期遅延でkarabiner.jsonが初期化されるリスクがある
- まずローカルにコピーしてからクラウドツールで管理

## 注意事項
- 設定移行は同一または新しいKarabiner-Elementsバージョン間で実施
- メジャーアップデート時は設定構造が変わる可能性がある
- 複数Macで異なるキーボードを使用する場合、デバイス設定の調整が必要
- 大量のComplex Modificationsがある場合、初回適用に時間がかかる場合がある