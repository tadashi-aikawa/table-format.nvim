-- UTF-8文字をUnicodeコードポイントに変換する関数
local function utf8_to_codepoint(char)
  if not char or #char == 0 then
    return 0
  end
  
  local byte1 = string.byte(char, 1)
  
  -- ASCII文字（1バイト）
  if byte1 <= 0x7F then
    return byte1
  end
  
  -- UTF-8文字（2-4バイト）
  local byte2 = string.byte(char, 2)
  local byte3 = string.byte(char, 3)
  local byte4 = string.byte(char, 4)
  
  if byte1 >= 0xC0 and byte1 <= 0xDF and byte2 then
    -- 2バイト文字
    return ((byte1 - 0xC0) * 0x40) + (byte2 - 0x80)
  elseif byte1 >= 0xE0 and byte1 <= 0xEF and byte2 and byte3 then
    -- 3バイト文字（日本語の多くはここ）
    return ((byte1 - 0xE0) * 0x1000) + ((byte2 - 0x80) * 0x40) + (byte3 - 0x80)
  elseif byte1 >= 0xF0 and byte1 <= 0xF7 and byte2 and byte3 and byte4 then
    -- 4バイト文字
    return ((byte1 - 0xF0) * 0x40000) + ((byte2 - 0x80) * 0x1000) + ((byte3 - 0x80) * 0x40) + (byte4 - 0x80)
  end
  
  -- フォールバック
  return byte1
end

-- テスト用のvimモック
local function create_vim_mock()
  return {
    fn = {
      char2nr = utf8_to_codepoint
    }
  }
end

return {
  create_vim_mock = create_vim_mock,
  utf8_to_codepoint = utf8_to_codepoint
}