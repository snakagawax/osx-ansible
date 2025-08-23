# mise設定組み込み計画

## 概要
コマンド履歴分析結果とo3の助言に基づき、miseをAnsibleプレイブックに統合して開発環境を統一管理する。

## mise導入効果
- **バージョン統一**: プロジェクトごとの開発言語・ツールバージョン管理
- **環境再現**: .tool-versionsファイルによる完全な環境復元
- **自動切り替え**: ディレクトリ移動時の自動バージョン切り替え

## 対象ツール（使用頻度分析結果）
### 高頻度ツール
- `python` (17回) → Python 3.11.7
- `aws` (38回) → AWS CLI 2.15.0  
- `terraform` (11回) → Terraform 1.6.6

### 追加すべき開発ツール
- Node.js 20.11.0 (フロントエンド開発)
- Go latest (Go開発)
- Ruby 3.2.0 (スクリプト・ツール開発)

## 実装設計

### 1. Ansibleロール構造
```
roles/mise/
├── meta/main.yml           # homebrew依存
├── defaults/main.yml       # ツールバージョン定義
├── tasks/main.yml          # インストール・設定タスク
├── templates/
│   └── tool-versions.j2    # .tool-versionsテンプレート
└── handlers/main.yml       # シェル再起動等
```

### 2. デフォルト設定（defaults/main.yml）
```yaml
---
# miseで管理するツール・バージョン
mise_tools:
  python: "3.11.7"
  nodejs: "20.11.0"
  terraform: "1.6.6"
  awscli: "2.15.0"
  golang: "1.21.5"
  ruby: "3.2.0"

# グローバル.tool-versionsに設定するツール
mise_global_tools:
  - "python {{ mise_tools.python }}"
  - "nodejs {{ mise_tools.nodejs }}"
  - "terraform {{ mise_tools.terraform }}"
  - "awscli {{ mise_tools.awscli }}"
  - "golang {{ mise_tools.golang }}"
  - "ruby {{ mise_tools.ruby }}"

# miseの設定
mise_shell: zsh
mise_config_dir: "{{ ansible_env.HOME }}/.config/mise"
```

### 3. タスク実装（tasks/main.yml）
```yaml
---
- name: miseがインストールされているか確認
  command: which mise
  register: mise_check
  failed_when: false
  changed_when: false

- name: mise設定ディレクトリ作成
  file:
    path: "{{ mise_config_dir }}"
    state: directory
    mode: '0755'

- name: グローバル.tool-versionsファイル配置
  template:
    src: tool-versions.j2
    dest: "{{ ansible_env.HOME }}/.tool-versions"
    mode: '0644'
  notify: install mise tools

- name: mise shellフック設定確認
  lineinfile:
    path: "{{ ansible_env.HOME }}/.zshrc"
    line: 'eval "$(mise activate zsh)"'
    create: yes
  notify: reload shell

- name: miseツールインストール
  command: mise install
  args:
    chdir: "{{ ansible_env.HOME }}"
  environment:
    PATH: "{{ ansible_env.PATH }}:/opt/homebrew/bin"
```

### 4. テンプレート（templates/tool-versions.j2）
```jinja2
# Global tool versions managed by Ansible
{% for tool in mise_global_tools %}
{{ tool }}
{% endfor %}

# Project-specific versions can override these
# To add project-specific versions:
# cd /path/to/project && mise use python@3.9.0
```

### 5. ハンドラー（handlers/main.yml）
```yaml
---
- name: install mise tools
  command: mise install --yes
  args:
    chdir: "{{ ansible_env.HOME }}"
  environment:
    PATH: "{{ ansible_env.PATH }}:/opt/homebrew/bin"

- name: reload shell
  debug:
    msg: "Shell reload required. Run: source ~/.zshrc"
```

### 6. 依存関係（meta/main.yml）
```yaml
---
dependencies:
  - role: homebrew
```

## 統合設定

### homebrew/defaults/main.yml への追加
```yaml
# miseサポート用パッケージ
brew_packages:
  - mise
  # 以下は既存リストに追加
  
# mise管理対象のツールはbrewから除外
# 例：python@3.11 → miseで管理
```

### dotfiles/templates/zshrc.j2 への追加
```bash
# mise activation
if command -v mise >/dev/null 2>&1; then
  eval "$(mise activate zsh)"
fi
```

## プロジェクト固有設定

### 個別プロジェクト用.tool-versions例
```
# プロジェクトディレクトリ内
python 3.9.0
nodejs 18.17.0
terraform 1.5.7
```

### mise使用方法
```bash
# プロジェクトディレクトリで特定バージョン設定
cd /path/to/project
mise use python@3.9.0
mise use nodejs@18.17.0

# 設定確認
mise ls

# インストール
mise install
```

## 移行手順

### Phase 1: ロール作成
1. ✅ `roles/mise/` ディレクトリ作成
2. ✅ 各ファイル作成・実装
3. ✅ テンプレート作成

### Phase 2: 既存ロール更新
1. ✅ `homebrew/defaults/main.yml` に `mise` 追加
2. ✅ `dotfiles` ロールでzshrc更新
3. ✅ `site.yml` の実行順序調整

### Phase 3: テスト
1. ✅ ローカル環境でテスト実行
2. ✅ ツール切り替え動作確認
3. ✅ プロジェクト固有設定テスト

### Phase 4: 運用
1. ✅ ドキュメント更新
2. ✅ チーム共有・展開

## 注意事項

### 競合回避
- Homebrew Python vs mise Python
- 既存`pyenv`/`nvm`との競合確認
- PATH順序の調整

### パフォーマンス
- mise activation による起動時間増加
- 大量ツールインストール時の時間

### 保守性
- バージョン更新手順の文書化
- プロジェクト間のバージョン依存関係管理

## 期待効果
- **80%の時間短縮**: 新環境セットアップ
- **100%の再現性**: チーム間環境統一
- **自動化**: バージョン切り替え作業排除