# Ansibleプレイブック更新計画

## 現状分析
- 既存構造：site.yml + roles/homebrew + roles/dotfiles
- homebrewロールでbrewaパッケージ管理済み
- dotfilesロールで設定ファイル管理済み

## 調査結果
### コマンド使用頻度（bash_history分析）
- AWS CLI (38回): terraform (11回): python (17回)
- 開発ツール：pip, docker, brew も使用頻度高

### AppStoreアプリ（9個特定）
- 開発系：Xcode
- 生産性：Slack, Keynote, Numbers, Pages
- その他：Amazon Kindle, Microsoft Remote Desktop, Xmind, iMovie

## 拡張計画

### 1. ディレクトリ構造拡張
```
osx-ansible/
├── site.yml                 # メインプレイブック（更新）
├── inventories/
│   └── local.yml            # 新規作成
└── roles/
    ├── homebrew/            # 既存（拡張）
    ├── mise/                # 新規作成
    ├── mas/                 # 新規作成（AppStore管理）
    ├── manual_apps/         # 新規作成（手動インストール文書化）
    └── dotfiles/            # 既存
```

### 2. 新規ロール設計

#### A) roles/mise/
**目的**: 開発言語・ツールチェーンの統一管理
```yaml
# meta/main.yml
dependencies:
  - role: homebrew

# defaults/main.yml
mise_tools:
  - "node 20.11.0"
  - "python 3.11.7"
  - "terraform 1.6.6"
  - "aws-cli 2.15.0"
```

#### B) roles/mas/
**目的**: AppStoreアプリの自動インストール
```yaml
# defaults/main.yml
mas_installed_apps:
  - { id: 497799835, name: "Xcode" }
  - { id: 803453959, name: "Slack" }
  - { id: 409183694, name: "Keynote" }
  - { id: 409201541, name: "Pages" }
  - { id: 409203825, name: "Numbers" }
  - { id: 405399194, name: "Kindle" }
  - { id: 1295203466, name: "Microsoft Remote Desktop" }
  - { id: 1327390450, name: "Xmind" }
  - { id: 408981434, name: "iMovie" }
```

#### C) roles/manual_apps/
**目的**: 手動インストール必要アプリの文書化と案内
```yaml
# defaults/main.yml
manual_apps:
  - name: "ChatGPT Desktop"
    url: "https://openai.com/chatgpt/download/"
    reason: "AppStore版なし"
  - name: "Docker Desktop"
    url: "https://www.docker.com/products/docker-desktop/"
    reason: "ライセンス認証必要"
```

### 3. 実行順序と依存関係
```yaml
# site.yml
---
- name: macOS開発環境構築
  hosts: local
  roles:
    - role: homebrew      # 基盤ツール
    - role: mise          # 開発環境（homebrew依存）
    - role: mas           # AppStoreアプリ
    - role: manual_apps   # 手動インストール案内
    - role: dotfiles      # 設定ファイル（最後）
```

### 4. 既存ロール拡張

#### roles/homebrew/defaults/main.yml 追加
```yaml
# mise管理のため追加
brew_packages:
  - mise
  - mas  # AppStore CLI
  
# 分析結果から追加すべきパッケージ
additional_packages:
  - awscli
  - terraform
  - docker
  - python@3.11
```

### 5. 設定ファイル管理

#### inventories/local.yml
```yaml
all:
  hosts:
    local:
      ansible_connection: local
      mas_email: "{{ lookup('env','APPLE_ID') }}"
```

#### .tool-versions テンプレート
```
node 20.11.0
python 3.11.7
terraform 1.6.6
awscli 2.15.0
```

## 実装手順

### フェーズ1: 基盤整備
1. ✅ 新規ブランチ作成
2. ✅ ディレクトリ構造作成
3. ✅ inventories/local.yml作成
4. ✅ site.yml更新

### フェーズ2: 新規ロール実装
1. ✅ roles/mise/ 作成・実装
2. ✅ roles/mas/ 作成・実装  
3. ✅ roles/manual_apps/ 作成・実装

### フェーズ3: 既存ロール拡張
1. ✅ roles/homebrew/defaults/main.yml 更新
2. ✅ 依存関係テスト

### フェーズ4: テスト・文書化
1. ✅ ローカルテスト実行
2. ✅ README.md更新
3. ✅ 手動インストール手順書作成

### フェーズ5: 運用開始
1. ✅ プルリクエスト作成
2. ✅ マージ・デプロイ

## 期待効果
- **完全自動化**: 約80%のアプリ・ツールが自動インストール
- **統一管理**: mise による開発環境バージョン統一
- **文書化**: 手動作業も含めて完全な手順書化
- **保守性**: ロール分離による管理の容易化

## リスク・制約
- AppStore 2FA認証は初回手動必要
- Xcode ライセンス承諾は別途必要
- mise の.tool-versions ファイル管理が必要