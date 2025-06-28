-- Setup test environment
local test_helper = require("test_helper")
_G.vim = test_helper.create_vim_mock()

local parser = require("table-format.parser")
local formatter = require("table-format.formatter")

-- Helper function to format table from raw lines
local function format_table_lines(lines)
    local start_line, end_line = parser.find_table_range(lines, 1)
    if not start_line or not end_line then
        return nil, "No table found"
    end

    local table_lines = {}
    for i = start_line, end_line do
        table.insert(table_lines, lines[i])
    end

    local table_data = parser.parse_table(table_lines, 1, #table_lines)
    return formatter.format_table(table_data)
end

describe("End-to-End table formatting", function()
    describe("ISSUE-1 examples", function()
        it("should format example 1 (basic table)", function()
            local input = {
                "| id | name |",
                "|-|-|",
                "|1| ichiro|",
                "|100|momotake|",
            }

            local expected = {
                "| id  | name     |",
                "| --- | -------- |",
                "| 1   | ichiro   |",
                "| 100 | momotake |",
            }

            local result = format_table_lines(input)
            assert.are.same(expected, result)
        end)

        it("should format example 2 (Japanese characters)", function()
            local input = {
                "| あいでぃ | name |",
                "|-|-|",
                "| 1 | いちろう|",
                "| 100 |桃武|",
            }

            local expected = {
                "| あいでぃ | name     |",
                "| -------- | -------- |",
                "| 1        | いちろう |",
                "| 100      | 桃武     |",
            }

            local result = format_table_lines(input)
            assert.are.same(expected, result)
        end)

        it("should format example 3 (incomplete table)", function()
            local input = {
                "| プロパティ | 定義|",
                "|",
                "|タイトル|issueのタイトル",
            }

            local expected = {
                "| プロパティ | 定義            |",
                "| ---------- | --------------- |",
                "| タイトル   | issueのタイトル |",
            }

            local result = format_table_lines(input)
            assert.are.same(expected, result)
        end)
    end)

    describe("Edge cases", function()
        it("should handle single column table", function()
            local input = {
                "| column |",
                "|--------|",
                "| value1 |",
                "| value2 |",
            }

            local expected = {
                "| column |",
                "| ------ |",
                "| value1 |",
                "| value2 |",
            }

            local result = format_table_lines(input)
            assert.are.same(expected, result)
        end)

        it("should handle empty cells", function()
            local input = {
                "| a | b | c |",
                "|---|---|---|",
                "| 1 |   | 3 |",
                "|   | 2 |   |",
            }

            local expected = {
                "| a | b | c |",
                "| - | - | - |",
                "| 1 |   | 3 |",
                "|   | 2 |   |",
            }

            local result = format_table_lines(input)
            assert.are.same(expected, result)
        end)

        it("should auto-complete missing columns", function()
            local input = {
                "| a | b | c |",
                "| 1 | 2 |", -- Missing third column
                "| x |", -- Missing second and third columns
            }

            local expected = {
                "| a | b | c |",
                "| - | - | - |",
                "| 1 | 2 |   |",
                "| x |   |   |",
            }

            local result = format_table_lines(input)
            assert.are.same(expected, result)
        end)

        it("should return error for non-table content", function()
            local input = {
                "This is not a table",
                "Just some regular text",
                "No pipes here",
            }

            local result, error = format_table_lines(input)
            assert.is_nil(result)
            assert.are.equal("No table found", error)
        end)
    end)

    describe("Mixed content scenarios", function()
        it("should find table within document", function()
            local input = {
                "# Document Title",
                "",
                "Some introduction text.",
                "",
                "| id | name |",
                "|-|-|",
                "|1|test|",
                "",
                "Some conclusion text.",
            }

            -- Test with cursor on table line (line 5)
            local start_line, end_line = parser.find_table_range(input, 5)
            assert.are.equal(5, start_line)
            assert.are.equal(7, end_line)

            local table_lines = {}
            for i = start_line, end_line do
                table.insert(table_lines, input[i])
            end

            local table_data = parser.parse_table(table_lines, 1, #table_lines)
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
