# 手動インストール手順書作成計画

## 目的
Ansibleで自動化できないアプリケーション・ツールの手動インストール手順を体系的に文書化し、開発環境構築を完全ガイド化する。

## 手動インストールが必要な理由分析

### カテゴリ別分類
1. **ライセンス認証必要**: ユーザー固有の認証が必要
2. **AppStore制限**: 企業ポリシーでAppStore版利用不可
3. **設定依存**: 個人設定・認証情報が必要
4. **最新版必要**: パッケージマネージャーより最新版が必要

## 対象アプリケーション

### 現在インストール済み（/Applications/）から除外対象
- ❌ **自動化済み（Homebrew）**: Google Chrome, VS Code, iTerm2, Rectangle等
- ❌ **自動化済み（AppStore）**: Xcode, Slack, Keynote等
- ✅ **手動必要**: 以下で特定

### 想定される手動インストール対象
```yaml
manual_install_apps:
  # 開発ツール
  - name: "Docker Desktop"
    category: "Development"
    reason: "ライセンス認証・設定必要"
    
  - name: "JetBrains Toolbox"
    category: "Development" 
    reason: "ライセンス管理・IDE選択"
    
  # 生産性ツール
  - name: "1Password"
    category: "Security"
    reason: "個人アカウント設定"
    
  # デザイン・メディア
  - name: "Figma"
    category: "Design"
    reason: "チーム設定・プラグイン"
    
  # 通信・会議
  - name: "Zoom"
    category: "Communication"
    reason: "企業設定・SSO"
```

## 文書構造設計

### 1. メイン手順書（MANUAL_INSTALL_GUIDE.md）
```markdown
# 手動インストールガイド

## はじめに
- Ansible実行完了後の追加インストール手順
- カテゴリ別に整理された効率的な導入順序

## 前提条件
- [ ] Ansibleプレイブック実行完了
- [ ] Homebrew・AppStoreアプリインストール完了
- [ ] mise開発環境セットアップ完了

## インストール手順

### Phase 1: セキュリティ・認証系
### Phase 2: 開発環境
### Phase 3: 生産性ツール
### Phase 4: 設定・カスタマイズ
```

### 2. アプリ別詳細手順（apps/）
```
apps/
├── docker-desktop.md
├── jetbrains-toolbox.md
├── 1password.md
├── notion.md
├── figma.md
└── zoom.md
```

### 3. チェックリスト（INSTALLATION_CHECKLIST.md）
```markdown
# インストール完了チェックリスト

## 自動インストール（Ansible）
- [ ] Homebrewパッケージ（XX個）
- [ ] AppStoreアプリ（9個）
- [ ] mise開発環境
- [ ] dotfiles設定

## 手動インストール
### セキュリティ
- [ ] 1Password
- [ ] VPN設定

### 開発環境
- [ ] Docker Desktop
- [ ] JetBrains Toolbox
  - [ ] IntelliJ IDEA
  - [ ] PyCharm

### 生産性
- [ ] Figma
```

## 実装手順

### Phase 1: 現状調査・情報収集
1. ✅ インストール済みアプリ詳細調査
2. ✅ ライセンス・設定要件分析
3. ✅ カテゴリ分類・優先順位決定

### Phase 2: 文書テンプレート作成
1. ✅ 標準化されたアプリ手順テンプレート
2. ✅ スクリーンショット撮影ガイドライン
3. ✅ トラブルシューティング項目

### Phase 3: 個別アプリ手順作成
1. ✅ 各アプリのダウンロード〜設定完了
2. ✅ 設定エクスポート・インポート手順
3. ✅ よくある問題と解決方法

### Phase 4: 統合・自動化
1. ✅ Ansibleタスクとして文書表示
2. ✅ インストール状況チェック機能
3. ✅ 進捗管理・完了確認

## Ansible統合設計

### roles/manual_apps/tasks/main.yml
```yaml
---
- name: 手動インストールガイド表示
  debug:
    msg: |
      ===========================================
      手動インストールが必要なアプリケーション
      ===========================================
      詳細手順: {{ playbook_dir }}/MANUAL_INSTALL_GUIDE.md
      
      次のアプリを手動でインストールしてください：
      {% for app in manual_apps %}
      - {{ app.name }}: {{ app.url }}
      {% endfor %}

- name: 手動インストールガイド生成
  template:
    src: manual_install_guide.md.j2
    dest: "{{ ansible_env.HOME }}/Desktop/MANUAL_INSTALL_GUIDE.md"
    mode: '0644'
  
- name: インストールチェックリスト生成  
  template:
    src: installation_checklist.md.j2
    dest: "{{ ansible_env.HOME }}/Desktop/INSTALLATION_CHECKLIST.md"
    mode: '0644'

- name: 完了後の確認メッセージ
  pause:
    prompt: |
      
      ========================================
      Ansible自動インストール完了！
      ========================================
      
      デスクトップに以下のファイルを生成しました：
      - MANUAL_INSTALL_GUIDE.md: 手動インストール手順
      - INSTALLATION_CHECKLIST.md: 完了確認リスト
      
      続けて手動インストールを実行しますか？
      [Enter]キーで続行、[Ctrl+C]で終了
```

## 品質管理

### 文書品質基準
- ✅ **完全性**: ダウンロード〜設定完了まで網羅
- ✅ **正確性**: 最新版手順・スクリーンショット
- ✅ **効率性**: 最短手順・バッチ処理可能な順序
- ✅ **保守性**: テンプレート化・更新容易

### 更新管理
```yaml
# roles/manual_apps/defaults/main.yml
manual_apps_last_updated: "2024-08-20"
manual_apps_version: "1.0.0"

# バージョン確認タスク
- name: 手順書バージョン確認
  uri:
    url: "https://api.github.com/repos/user/osx-ansible/releases/latest"
  register: latest_version
  when: manual_apps_check_updates | default(false)
```

## 成功指標

### 定量的指標
- **新環境構築時間**: 8時間 → 2時間（75%短縮）
- **手順書利用率**: 100%（全手動アプリをカバー）
- **エラー発生率**: <5%（詳細手順による）

### 定性的指標  
- **チーム統一**: 全メンバー同一環境
- **知識共有**: 属人的設定作業の排除
- **新人対応**: 即座に生産環境構築可能

## 今後の展開
- **CI/CD統合**: 手順書の自動更新・テスト
- **Docker化**: より完全な環境再現
- **クラウド統合**: 設定の中央管理