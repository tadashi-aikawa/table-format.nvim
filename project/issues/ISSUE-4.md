## タイトル

StyLuaのフォーマット対応

## 概要

- フォーマッターとしてStyLuaを使ってほしい
- ローカルでファイル編集後にフォーマットをかけてほしい
  - **少なくともコミット前には**
- CIでもフォーマットチェックをして、かかっていないようなら失敗させてほしい
- `stylua` コマンドが利用できる前提でよい
  - 今Localのバージョンは2.1.0

## ステータス

クローズ

## 作業記録

### 👤 Claude Code 2025/06/28 19:32:40

StyLuaフォーマット対応を完了しました。

実装内容：
- `.stylua.toml` でStyLuaの設定ファイルを作成
- `hooks/pre-push` でpush時にフォーマットチェックを実行するGit hookを作成
- `Makefile` にフォーマット実行(`make format`)とチェック(`make format-check`)コマンドを追加
- CIワークフローにStyLuaのフォーマットチェックを追加

セットアップ方法：
1. `git config core.hooksPath hooks` でGit hooksを有効化
2. `make format` でローカルでのフォーマット実行
3. Push時は自動的にフォーマットチェックが実行され、未フォーマットの場合は失敗

