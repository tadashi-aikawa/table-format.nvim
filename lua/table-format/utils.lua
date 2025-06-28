local M = {}

function M.get_char_width(char)
    local byte = string.byte(char)

    if byte <= 0x7F then
        return 1
    end

    local utf8_char = vim.fn.char2nr(char)

    if utf8_char >= 0x1100 and utf8_char <= 0x115F then
        return 2
    end
    if utf8_char >= 0x2329 and utf8_char <= 0x232A then
        return 2
    end
    if utf8_char >= 0x2E80 and utf8_char <= 0x2EFF then
        return 2
    end
    if utf8_char >= 0x2F00 and utf8_char <= 0x2FDF then
        return 2
    end
    if utf8_char >= 0x2FF0 and utf8_char <= 0x2FFF then
        return 2
    end
    if utf8_char >= 0x3000 and utf8_char <= 0x303E then
        return 2
    end
    if utf8_char >= 0x3041 and utf8_char <= 0x3096 then
        return 2
    end
    if utf8_char >= 0x3099 and utf8_char <= 0x30FF then
        return 2
    end
    if utf8_char >= 0x3105 and utf8_char <= 0x312F then
        return 2
    end
    if utf8_char >= 0x3131 and utf8_char <= 0x318E then
        return 2
    end
    if utf8_char >= 0x3190 and utf8_char <= 0x31E3 then
        return 2
    end
    if utf8_char >= 0x31F0 and utf8_char <= 0x321E then
        return 2
    end
    if utf8_char >= 0x3220 and utf8_char <= 0x3247 then
        return 2
    end
    if utf8_char >= 0x3250 and utf8_char <= 0x4DBF then
        return 2
    end
    if utf8_char >= 0x4E00 and utf8_char <= 0xA48C then
        return 2
    end
    if utf8_char >= 0xA490 and utf8_char <= 0xA4C6 then
        return 2
    end
    if utf8_char >= 0xA960 and utf8_char <= 0xA97C then
        return 2
    end
    if utf8_char >= 0xAC00 and utf8_char <= 0xD7A3 then
        return 2
    end
    if utf8_char >= 0xF900 and utf8_char <= 0xFAFF then
        return 2
    end
    if utf8_char >= 0xFE10 and utf8_char <= 0xFE19 then
        return 2
    end
    if utf8_char >= 0xFE30 and utf8_char <= 0xFE6F then
        return 2
    end
    if utf8_char >= 0xFF00 and utf8_char <= 0xFF60 then
        return 2
    end
    if utf8_char >= 0xFFE0 and utf8_char <= 0xFFE6 then
        return 2
    end
    if utf8_char >= 0x1F300 and utf8_char <= 0x1F64F then
        return 2
    end
    if utf8_char >= 0x1F680 and utf8_char <= 0x1F6FF then
        return 2
    end
    if utf8_char >= 0x20000 and utf8_char <= 0x2FFFD then
        return 2
    end
    if utf8_char >= 0x30000 and utf8_char <= 0x3FFFD then
        return 2
    end

    return 1
end

function M.display_width(str)
    if str == nil then
        return 0
    end

    local width = 0
    local i = 1
    while i <= #str do
        local byte = string.byte(str, i)
        local char_len = 1

        if byte >= 240 then
            char_len = 4
        elseif byte >= 224 then
            char_len = 3
        elseif byte >= 192 then
            char_len = 2
        end

        local char = string.sub(str, i, i + char_len - 1)
        width = width + M.get_char_width(char)
        i = i + char_len
    end

    return width
end

function M.trim(str)
    return str:match("^%s*(.-)%s*$")
end

return M
