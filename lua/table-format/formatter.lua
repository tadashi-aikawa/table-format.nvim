local utils = require("table-format.utils")
local parser = require("table-format.parser")
local M = {}

function M.calculate_column_widths(table_data)
    local widths = {}

    for col = 1, table_data.max_columns do
        widths[col] = 0
    end

    for _, row in ipairs(table_data.rows) do
        for col, cell in ipairs(row) do
            local width = utils.display_width(cell)
            widths[col] = math.max(widths[col], width)
        end
    end

    return widths
end

function M.pad_cell(content, width)
    local content_width = utils.display_width(content)
    local padding = width - content_width
    return content .. string.rep(" ", padding)
end

function M.format_row(row, widths)
    local formatted_cells = {}

    -- 空の行（パイプのみの行）またはnilの場合は空の行を返す
    if not row or #row == 0 then
        return "| "
    end

    for col, cell in ipairs(row) do
        table.insert(formatted_cells, M.pad_cell(cell, widths[col]))
    end

    return "| " .. table.concat(formatted_cells, " | ") .. " |"
end

function M.format_separator(widths)
    local separators = {}

    for _, width in ipairs(widths) do
        table.insert(separators, string.rep("-", width))
    end

    return "| " .. table.concat(separators, " | ") .. " |"
end

function M.format_table(table_data)
    local widths = M.calculate_column_widths(table_data)
    local formatted_lines = {}

    if parser.is_header_only_table(table_data) then
        -- ヘッダのみテーブルの場合：ヘッダ→セパレータ→空行を追加
        table.insert(formatted_lines, M.format_row(table_data.rows[1], widths))
        table.insert(formatted_lines, M.format_separator(widths))

        -- 空のデータ行を作成（期待値通り "| " のみ）
        table.insert(formatted_lines, "| ")

        return formatted_lines
    end

    local row_index = 1
    for i = 1, #table_data.rows + (table_data.separator_line and 1 or 0) do
        if table_data.separator_line and i == table_data.separator_line then
            table.insert(formatted_lines, M.format_separator(widths))
        else
            table.insert(formatted_lines, M.format_row(table_data.rows[row_index], widths))
            row_index = row_index + 1
        end
    end

    if not table_data.separator_line and #table_data.rows > 1 then
        table.insert(formatted_lines, 2, M.format_separator(widths))
    end

    return formatted_lines
end

return M
