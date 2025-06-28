.PHONY: test test-unit install-deps format format-check setup-hooks

# テスト実行
test: test-unit

# ユニットテスト実行
test-unit:
	@echo "Running unit tests..."
	busted

# テスト依存関係のインストール
install-deps:
	@echo "Installing test dependencies..."
	@echo "Please install busted: luarocks install busted"
	@echo "Note: Integration tests (plenary.nvim) are planned for future implementation"

# テストカバレッジ
coverage:
	busted --coverage

# テストの詳細出力
test-verbose:
	busted --verbose

# コードフォーマット実行
format:
	@echo "Running StyLua format..."
	stylua .

# フォーマットチェック
format-check:
	@echo "Running StyLua format check..."
	stylua --check .