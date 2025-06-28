-- Setup test environment
local test_helper = require("test_helper")
_G.vim = test_helper.create_vim_mock()

local formatter = require("table-format.formatter")

describe("formatter module", function()
    describe("calculate_column_widths", function()
        it("should calculate correct widths for ASCII table", function()
            local table_data = {
                rows = {
                    { "id", "name" },
                    { "1", "ichiro" },
                    { "100", "momotake" },
                },
                max_columns = 2,
            }

            local widths = formatter.calculate_column_widths(table_data)
            assert.are.same({ 3, 8 }, widths)
        end)

        it("should calculate correct widths for Japanese table", function()
            local table_data = {
                rows = {
                    { "あいでぃ", "name" },
                    { "1", "いちろう" },
                    { "100", "桃武" },
                },
                max_columns = 2,
            }

            local widths = formatter.calculate_column_widths(table_data)
            assert.are.same({ 8, 8 }, widths)
        end)
    end)

    describe("pad_cell", function()
        it("should pad ASCII content correctly", function()
            assert.are.equal("id ", formatter.pad_cell("id", 3))
            assert.are.equal("name    ", formatter.pad_cell("name", 8))
            assert.are.equal("1  ", formatter.pad_cell("1", 3))
        end)

        it("should pad Japanese content correctly", function()
            assert.are.equal("あいでぃ", formatter.pad_cell("あいでぃ", 8))
            assert.are.equal("桃武    ", formatter.pad_cell("桃武", 8))
            assert.are.equal("1       ", formatter.pad_cell("1", 8))
        end)
    end)

    describe("format_row", function()
        it("should format ASCII row correctly", function()
            local row = { "id", "name" }
            local widths = { 3, 8 }

            local result = formatter.format_row(row, widths)
            assert.are.equal("| id  | name     |", result)
        end)

        it("should format Japanese row correctly", function()
            local row = { "あいでぃ", "桃武" }
            local widths = { 8, 8 }

            local result = formatter.format_row(row, widths)
            assert.are.equal("| あいでぃ | 桃武     |", result)
        end)
    end)

    describe("format_separator", function()
        it("should format separator correctly", function()
            local widths = { 3, 8 }

            local result = formatter.format_separator(widths)
            assert.are.equal("| --- | -------- |", result)
        end)

        it("should format separator for Japanese widths", function()
            local widths = { 8, 8 }

            local result = formatter.format_separator(widths)
            assert.are.equal("| -------- | -------- |", result)
        end)
    end)

    describe("format_table", function()
        it("should format ISSUE-1 example 1 correctly", function()
            local table_data = {
                rows = {
                    { "id", "name" },
                    { "1", "ichiro" },
                    { "100", "momotake" },
                },
                separator_line = 2,
                max_columns = 2,
            }

            local result = formatter.format_table(table_data)
            local expected = {
                "| id  | name     |",
                "| --- | -------- |",
                "| 1   | ichiro   |",
                "| 100 | momotake |",
            }

            assert.are.same(expected, result)
        end)

        it("should format ISSUE-1 example 2 correctly", function()
            local table_data = {
                rows = {
                    { "あいでぃ", "name" },
                    { "1", "いちろう" },
                    { "100", "桃武" },
                },
                separator_line = 2,
                max_columns = 2,
            }

            local result = formatter.format_table(table_data)
            local expected = {
                "| あいでぃ | name     |",
                "| -------- | -------- |",
                "| 1        | いちろう |",
                "| 100      | 桃武     |",
            }

            assert.are.same(expected, result)
        end)

        it("should format ISSUE-1 example 3 correctly", function()
            local table_data = {
                rows = {
                    { "プロパティ", "定義" },
                    { "タイトル", "issueのタイトル" },
                },
                separator_line = 2,
                max_columns = 2,
            }

            local result = formatter.format_table(table_data)
            local expected = {
                "| プロパティ | 定義            |",
                "| ---------- | --------------- |",
                "| タイトル   | issueのタイトル |",
            }

            assert.are.same(expected, result)
        end)

        it("should auto-insert separator when missing", function()
            local table_data = {
                rows = {
                    { "id", "name" },
                    { "1", "test" },
                },
                separator_line = nil,
                max_columns = 2,
            }

            local result = formatter.format_table(table_data)
            local expected = {
                "| id | name |",
                "| -- | ---- |",
                "| 1  | test |",
            }

            assert.are.same(expected, result)
        end)
    end)
end)
