local parser = require("table-format.parser")
local formatter = require("table-format.formatter")

local M = {}

function M.setup(opts)
    opts = opts or {}
end

function M.format_table()
    local current_buf = vim.api.nvim_get_current_buf()
    local cursor_pos = vim.api.nvim_win_get_cursor(0)
    local cursor_line = cursor_pos[1]

    local lines = vim.api.nvim_buf_get_lines(current_buf, 0, -1, false)

    local start_line, end_line = parser.find_table_range(lines, cursor_line)

    if not start_line or not end_line then
        vim.notify("No table found at cursor position", vim.log.levels.WARN)
        return
    end

    local table_lines = {}
    for i = start_line, end_line do
        table.insert(table_lines, lines[i])
    end

    local table_data = parser.parse_table(table_lines, 1, #table_lines)
    local is_header_only = parser.is_header_only_table(table_data)
    local formatted_lines = formatter.format_table(table_data)

    vim.api.nvim_buf_set_lines(current_buf, start_line - 1, end_line, false, formatted_lines)

    -- カーソル位置を安全に設定
    local new_end_line = start_line + #formatted_lines - 1
    local buf_line_count = vim.api.nvim_buf_line_count(current_buf)

    if is_header_only then
        -- ヘッダのみテーブルの場合、カーソルを空のデータ行（3行目）の最初のセルに移動
        local target_line = start_line + 2
        if target_line <= buf_line_count then
            vim.api.nvim_win_set_cursor(0, { target_line, 2 }) -- 3行目、2文字目（| の次）
        end
    else
        -- 元のカーソル位置が有効な範囲内かチェック
        local target_line = math.min(cursor_pos[1], new_end_line)
        target_line = math.min(target_line, buf_line_count)
        vim.api.nvim_win_set_cursor(0, { target_line, cursor_pos[2] })
    end
end

return M
