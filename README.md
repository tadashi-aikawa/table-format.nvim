# table-format.nvim

Markdown形式のテーブルをフォーマットするNeovimプラグインです。

> [!WARNING]
> このプロジェクトは計画・記録・コーディング・テストをほぼすべてClaude Codeで行っています。Issueは `project/issues` 配下で管理しています。

## 特徴

- `:TableFormat`コマンドでカーソル位置のテーブルを自動フォーマット
- UTF-8文字（日本語のひらがな、漢字等）に対応した幅計算
- テーブル罫線の美しい等幅揃え
- 不足カラムの自動補完
- セパレータ行の自動挿入

## インストール

### lazy.nvim

```lua
{
  "tadashi-aikawa/table-format.nvim",
  cmd = "TableFormat"
  opts = {},
}
```

## 使用方法

1. Markdownファイルでテーブル内にカーソルを置く
2. `:TableFormat`コマンドを実行

## 例

### 基本的なテーブル

実行前:
```markdown
| id | name |
|-|-|
|1| ichiro|
|100|momotake|
```

実行後:
```markdown
| id  | name      |
|-----|-----------|
| 1   | ichiro    |
| 100 | momotake |
```

### 日本語文字を含むテーブル

実行前:
```markdown
| あいでぃ | name |
|-|-|
| 1 | いちろう|
| 100 |桃武|
```

実行後:
```markdown
| あいでぃ | name     |
|----------|----------|
| 1        | いちろう |
| 100      | 桃武     |
```

### 不完全なテーブル

実行前:
```markdown
| プロパティ | 定義|
|
|タイトル|issueのタイトル
```

実行後:
```markdown
| プロパティ | 定義            |
|------------|-----------------|
| タイトル   | issueのタイトル |
```

## 設定

現在、特別な設定は不要です。`opts = {}`で十分です。

## 開発

### テスト実行

```bash
# bustedのインストール（初回のみ）
luarocks install busted

# テスト実行
make test

# 詳細出力でのテスト実行
make test-verbose

# カバレッジ付きテスト実行
make coverage
```

**注意**: 統合テスト（plenary.nvim）は将来の実装予定です。現在は`make test`でPure Luaユニットテストが利用可能です。

### テスト構成

- `tests/utils_spec.lua`: UTF-8文字幅計算のテスト
- `tests/parser_spec.lua`: テーブル解析のテスト
- `tests/formatter_spec.lua`: フォーマット処理のテスト
- `tests/e2e_spec.lua`: ISSUE-1の例を含むE2Eテスト

## ライセンス

MIT License
