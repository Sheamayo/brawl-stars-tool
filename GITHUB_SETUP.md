# GitHub Actions で dylib 自動ビルド

このガイドに従って、GitHub Actions で BrawlStarsTool dylib を自動コンパイル・ビルドします。

## ステップ 1: GitHub アカウント作成

1. https://github.com/signup にアクセス
2. メールアドレス・パスワードで新規登録
3. メール確認を完了

## ステップ 2: リポジトリ作成

1. GitHub ログイン後、右上の **+** → **New repository**
2. リポジトリ名：`brawl-stars-tool`
3. **Public** を選択（GitHub Actions が無料で使える）
4. **Create repository**

## ステップ 3: ローカルファイルを GitHub に Push

ターミナル/コマンドプロンプトで以下を実行：

```bash
cd /home/user/brawl-stars-mod
git init
git add .
git commit -m "Initial commit: BrawlStarsTool with AI autoplay"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/brawl-stars-tool.git
git push -u origin main
```

**`YOUR_USERNAME`** をあなたの GitHub ユーザー名に置き換えてください。

## ステップ 4: GitHub Actions で自動ビルド開始

1. GitHub で自分のリポジトリを開く
2. **Actions** タブをクリック
3. ワークフローが自動実行されるのを待つ
4. 🟢 **Build BrawlStarsTool dylib** が成功すると、dylib が Artifact として保存される

## ステップ 5: dylib をダウンロード

1. **Actions** タブ → 最新の **Build BrawlStarsTool dylib** ワークフローをクリック
2. **Artifacts** セクションで **BrawlStarsTool-dylib** をダウンロード
3. ダウンロード後、`BrawlStarsTool.dylib` を `/home/user/brawl-stars-mod/` に置き換え

## ステップ 6: .deb を再生成

ダウンロードした dylib で .deb を再作成：

```bash
cd /home/user/brawl-stars-mod
./pack.sh
```

これで新しい `.deb` ファイルが生成されます。

## ステップ 7: gbox で署名・インストール

生成された `.deb` を gbox にアップロード：

1. gbox を開く
2. **ライブラリを選択する** → `.deb` をアップロード
3. **署名** → IPA を選択・署名
4. **インストール** → iPhone にインストール

## トラブルシューティング

### ビルドが失敗する場合

1. **Actions** タブで失敗したワークフローをクリック
2. **Build** ステップのログを確認
3. エラーメッセージをコピーして共有してください

### dylib がダウンロードできない

- ワークフローの **Upload dylib artifact** ステップが成功したか確認
- Actions タブの Artifacts セクションに表示されているか確認

### .deb を作り直したい

```bash
cd /home/user/brawl-stars-mod
rm -f BrawlStarsTool_*.deb
./pack.sh
```

## 自動更新（オプション）

BrawlStarsTool.swift を変更後、以下を実行すれば自動ビルド＆リリース：

```bash
git add BrawlStarsTool.swift
git commit -m "Update AI logic"
git push origin main
```

GitHub Actions が自動的に新しい dylib をビルドします。
