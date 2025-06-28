local utils = require("table-format.utils")
local M = {}

function M.is_table_line(line)
    local trimmed = utils.trim(line)

    if trimmed == "|" then
        return true
    end

    return trimmed:match("^|.*") ~= nil or trimmed:match(".*|$") ~= nil or trimmed:match(".*|.*") ~= nil
end

function M.parse_table_line(line)
    local cells = {}
    local trimmed = utils.trim(line)

    if trimmed == "|" then
        return cells
    end

    if trimmed:sub(1, 1) == "|" then
        trimmed = trimmed:sub(2)
    end
    if #trimmed > 0 and trimmed:sub(-1) == "|" then
        trimmed = trimmed:sub(1, -2)
    end

    if #trimmed == 0 then
        return cells
    end

    local i = 1
    local start = 1
    while i <= #trimmed do
        if trimmed:sub(i, i) == "|" then
            local cell = trimmed:sub(start, i - 1)
            table.insert(cells, utils.trim(cell))
            start = i + 1
        end
        i = i + 1
    end

    if start <= #trimmed then
        local cell = trimmed:sub(start)
        table.insert(cells, utils.trim(cell))
    end

    return cells
end

function M.is_separator_line(line)
    local trimmed = utils.trim(line)

    -- 空のセパレータ行（|のみ）
    if trimmed == "|" then
        return true
    end

    -- 不完全なセパレータ行（|-、|--等）
    if trimmed:match("^|[-:]+$") then
        return true
    end

    -- 既存のパターン
    return trimmed:match("^|?%s*[-:]+%s*|.*$") ~= nil
        or trimmed:match("^|.*|%s*[-:]+%s*|?$") ~= nil
        or trimmed:match("^[-:]+$") ~= nil
end

function M.find_table_range(lines, cursor_line)
    local start_line = cursor_line
    local end_line = cursor_line

    while start_line > 1 and M.is_table_line(lines[start_line - 1]) do
        start_line = start_line - 1
    end

    while end_line < #lines and M.is_table_line(lines[end_line + 1]) do
        end_line = end_line + 1
    end

    if not M.is_table_line(lines[cursor_line]) then
        return nil, nil
    end

    return start_line, end_line
end

function M.parse_table(lines, start_line, end_line)
    local table_data = {
        rows = {},
        separator_line = nil,
        max_columns = 0,
    }

    for i = start_line, end_line do
        local line = lines[i]
        if M.is_separator_line(line) then
            table_data.separator_line = i - start_line + 1
        else
            local cells = M.parse_table_line(line)
            table.insert(table_data.rows, cells)
            table_data.max_columns = math.max(table_data.max_columns, #cells)
        end
    end

    for _, row in ipairs(table_data.rows) do
        while #row < table_data.max_columns do
            table.insert(row, "")
        end
    end

    return table_data
end

return M
