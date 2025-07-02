-- Setup test environment
local test_helper = require("test_helper")
_G.vim = test_helper.create_vim_mock()

local parser = require("table-format.parser")

describe("parser module", function()
    describe("is_table_line", function()
        it("should recognize complete table lines", function()
            assert.is_true(parser.is_table_line("| id | name |"))
            assert.is_true(parser.is_table_line("|1|ichiro|"))
            assert.is_true(parser.is_table_line("  | あいでぃ | name |  "))
        end)

        it("should recognize incomplete table lines", function()
            assert.is_true(parser.is_table_line("|タイトル|issueのタイトル")) -- 末尾パイプなし
            assert.is_true(parser.is_table_line("プロパティ | 定義|")) -- 開始パイプなし
            assert.is_true(parser.is_table_line("|")) -- セパレータのみ
        end)

        it("should reject non-table lines", function()
            assert.is_false(parser.is_table_line("This is not a table"))
            assert.is_false(parser.is_table_line(""))
            assert.is_false(parser.is_table_line("   "))
        end)
    end)

    describe("is_separator_line", function()
        it("should recognize complete separator lines", function()
            assert.is_true(parser.is_separator_line("|-|-|"))
            assert.is_true(parser.is_separator_line("|---|-----------|"))
            assert.is_true(parser.is_separator_line("| --- | --------- |"))
        end)

        it("should recognize incomplete separator lines", function()
            -- assert.is_true(parser.is_separator_line("|")) -- 空セパレータ（ISSUE-7修正により除外）
            assert.is_true(parser.is_separator_line("|-")) -- 不完全セパレータ
            assert.is_true(parser.is_separator_line("|--"))
            assert.is_true(parser.is_separator_line("---")) -- パイプなし
        end)

        it("should reject non-separator lines", function()
            assert.is_false(parser.is_separator_line("| id | name |"))
            assert.is_false(parser.is_separator_line("|1|ichiro|"))
            assert.is_false(parser.is_separator_line("not a separator"))
            assert.is_false(parser.is_separator_line("|")) -- ISSUE-7修正により、パイプのみの行はデータ行
        end)

        it("should reject data lines with single hyphen cells (ISSUE-8)", function()
            assert.is_false(parser.is_separator_line("| aa | - |"))
            assert.is_false(parser.is_separator_line("| - | bb |"))
            assert.is_false(parser.is_separator_line("| aa | -- |")) -- 2つのハイフンでも同様
            assert.is_false(parser.is_separator_line("| + | bb |")) -- ハイフン以外の記号は問題なし
            assert.is_false(parser.is_separator_line("| aa | - | cc |")) -- 中間カラムがハイフンでも問題なし（端のカラム以外）
        end)
    end)

    describe("parse_table_line", function()
        it("should parse complete table lines", function()
            local cells = parser.parse_table_line("| id | name |")
            assert.are.same({ "id", "name" }, cells)
        end)

        it("should parse incomplete table lines", function()
            local cells = parser.parse_table_line("|タイトル|issueのタイトル")
            assert.are.same({ "タイトル", "issueのタイトル" }, cells)
        end)

        it("should handle empty separator lines", function()
            local cells = parser.parse_table_line("|")
            assert.are.same({}, cells)
        end)

        it("should trim cell contents", function()
            local cells = parser.parse_table_line("| id | name |")
            assert.are.same({ "id", "name" }, cells)

            local cells2 = parser.parse_table_line("|  1  |  ichiro  |")
            assert.are.same({ "1", "ichiro" }, cells2)
        end)
    end)

    describe("find_table_range", function()
        it("should find table range for complete table", function()
            local lines = {
                "# Header",
                "| id | name |",
                "| -- | ---- |",
                "| 1  | test |",
                "| 2  | test2|",
                "End text",
            }

            local start_line, end_line = parser.find_table_range(lines, 3)
            assert.are.equal(2, start_line)
            assert.are.equal(5, end_line)
        end)

        it("should return nil for non-table lines", function()
            local lines = {
                "# Header",
                "Not a table",
                "Still not a table",
            }

            local start_line, end_line = parser.find_table_range(lines, 2)
            assert.is_nil(start_line)
            assert.is_nil(end_line)
        end)

        it("should find range for incomplete table (ISSUE-1 example 3)", function()
            local lines = {
                "# Document",
                "",
                "| プロパティ | 定義|",
                "|",
                "|タイトル|issueのタイトル",
                "",
                "End of doc",
            }

            -- カーソルが不完全なテーブル内の各行にある場合をテスト

            -- ヘッダ行にカーソル（3行目）
            local start_line, end_line = parser.find_table_range(lines, 3)
            assert.are.equal(3, start_line)
            assert.are.equal(5, end_line)

            -- セパレータ行にカーソル（4行目）
            start_line, end_line = parser.find_table_range(lines, 4)
            assert.are.equal(3, start_line)
            assert.are.equal(5, end_line)

            -- データ行にカーソル（5行目）
            start_line, end_line = parser.find_table_range(lines, 5)
            assert.are.equal(3, start_line)
            assert.are.equal(5, end_line)
        end)

        it("should find range for table with missing pipes", function()
            local lines = {
                "Some text",
                "| col1 | col2 |",
                "|------|------|",
                "val1 | val2", -- 開始パイプなし
                "| val3 | val4", -- 終了パイプなし
                "More text",
            }

            -- テーブル内の任意の行にカーソル
            local start_line, end_line = parser.find_table_range(lines, 3)
            assert.are.equal(2, start_line)
            assert.are.equal(5, end_line)

            -- 不完全な行にカーソル
            start_line, end_line = parser.find_table_range(lines, 4)
            assert.are.equal(2, start_line)
            assert.are.equal(5, end_line)
        end)
    end)

    describe("parse_table", function()
        it("should parse ISSUE-1 example 1", function()
            local lines = {
                "| id | name |",
                "|-|-|",
                "|1| ichiro|",
                "|100|momotake|",
            }

            local table_data = parser.parse_table(lines, 1, 4)

            assert.are.equal(2, table_data.separator_line)
            assert.are.equal(2, table_data.max_columns)
            assert.are.equal(3, #table_data.rows)

            assert.are.same({ "id", "name" }, table_data.rows[1])
            assert.are.same({ "1", "ichiro" }, table_data.rows[2])
            assert.are.same({ "100", "momotake" }, table_data.rows[3])
        end)

        it("should parse ISSUE-1 example 3 (incomplete table)", function()
            local lines = {
                "| プロパティ | 定義|",
                "|",
                "|タイトル|issueのタイトル",
            }

            local table_data = parser.parse_table(lines, 1, 3)

            assert.is_nil(table_data.separator_line) -- `|` はデータ行として扱われる
            assert.are.equal(2, table_data.max_columns)
            assert.are.equal(3, #table_data.rows) -- 3行のデータ行

            assert.are.same({ "プロパティ", "定義" }, table_data.rows[1])
            assert.are.same({ "", "" }, table_data.rows[2]) -- 空の行
            assert.are.same({ "タイトル", "issueのタイトル" }, table_data.rows[3])
        end)

        it("should pad rows to max columns", function()
            local lines = {
                "| a | b | c |",
                "| 1 | 2 |", -- 不足カラム
            }

            local table_data = parser.parse_table(lines, 1, 2)

            assert.are.equal(3, table_data.max_columns)
            assert.are.same({ "a", "b", "c" }, table_data.rows[1])
            assert.are.same({ "1", "2", "" }, table_data.rows[2]) -- 空文字で補完
        end)
    end)
end)
