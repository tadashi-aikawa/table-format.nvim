if vim.g.loaded_table_format then
    return
end
vim.g.loaded_table_format = 1

vim.api.nvim_create_user_command("TableFormat", function()
    require("table-format").format_table()
end, {
    desc = "Format markdown table at cursor position",
})
