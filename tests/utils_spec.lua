-- Setup test environment
local test_helper = require('test_helper')
_G.vim = test_helper.create_vim_mock()

local utils = require('table-format.utils')

describe("utils module", function()
  describe("get_char_width", function()
    it("should return 1 for ASCII characters", function()
      assert.are.equal(1, utils.get_char_width("a"))
      assert.are.equal(1, utils.get_char_width("Z"))
      assert.are.equal(1, utils.get_char_width("0"))
      assert.are.equal(1, utils.get_char_width("|"))
      assert.are.equal(1, utils.get_char_width(" "))
    end)

    it("should return 2 for Japanese hiragana", function()
      assert.are.equal(2, utils.get_char_width("あ"))
      assert.are.equal(2, utils.get_char_width("い"))
      assert.are.equal(2, utils.get_char_width("う"))
    end)

    it("should return 2 for Japanese katakana", function()
      assert.are.equal(2, utils.get_char_width("タ"))
      assert.are.equal(2, utils.get_char_width("イ"))
      assert.are.equal(2, utils.get_char_width("ト"))
      assert.are.equal(2, utils.get_char_width("ル"))
    end)

    it("should return 2 for Japanese kanji", function()
      assert.are.equal(2, utils.get_char_width("百"))
      assert.are.equal(2, utils.get_char_width("武"))
      assert.are.equal(2, utils.get_char_width("定"))
      assert.are.equal(2, utils.get_char_width("義"))
    end)
  end)

  describe("display_width", function()
    it("should return 0 for nil", function()
      assert.are.equal(0, utils.display_width(nil))
    end)

    it("should return correct width for ASCII strings", function()
      assert.are.equal(0, utils.display_width(""))
      assert.are.equal(2, utils.display_width("id"))
      assert.are.equal(4, utils.display_width("name"))
      assert.are.equal(6, utils.display_width("ichiro"))
      assert.are.equal(8, utils.display_width("momotake"))
    end)

    it("should return correct width for Japanese strings", function()
      -- 実際の計算結果に合わせて期待値を修正
      assert.are.equal(8, utils.display_width("あいでぃ"))   -- あ(2) + い(2) + で(2) + ぃ(2) = 8
      assert.are.equal(8, utils.display_width("いちろう"))
      assert.are.equal(4, utils.display_width("桃武"))
      assert.are.equal(10, utils.display_width("プロパティ"))  -- プ(2) + ロ(2) + パ(2) + テ(2) + ィ(2) = 10
      assert.are.equal(4, utils.display_width("定義"))
      assert.are.equal(8, utils.display_width("タイトル"))  -- タ(2) + イ(2) + ト(2) + ル(2) = 8
    end)

    it("should return correct width for mixed strings", function()
      assert.are.equal(15, utils.display_width("issueのタイトル"))  -- 実際の計算結果に合わせて修正
    end)
  end)

  describe("trim", function()
    it("should remove leading and trailing whitespace", function()
      assert.are.equal("test", utils.trim("  test  "))
      assert.are.equal("test", utils.trim("\ttest\t"))
      assert.are.equal("test", utils.trim("\ntest\n"))
      assert.are.equal("", utils.trim("   "))
      assert.are.equal("test", utils.trim("test"))
    end)

    it("should preserve internal whitespace", function()
      assert.are.equal("test case", utils.trim("  test case  "))
      assert.are.equal("a | b", utils.trim("  a | b  "))
    end)
  end)
end)
