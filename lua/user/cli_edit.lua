-- user/cli_edit.lua
local M = {}

-- Auto-detect shell script type for temp files
vim.api.nvim_create_autocmd({"BufRead", "BufNewFile"}, {
  pattern = {"/tmp/kitty_edit*", "/tmp/zsh_edit*", "/tmp/bash_edit*"},
  callback = function()
    vim.bo.filetype = "sh"
    vim.bo.syntax = "zsh"
    -- Enable better completion for CLI editing
    vim.opt_local.complete = ".,w,b,u,t,i,kspell"
    vim.opt_local.completeopt = "menu,menuone,noselect"
  end
})

-- Quick save and quit for CLI editing
vim.api.nvim_create_autocmd("FileType", {
  pattern = "sh",
  callback = function()
    local bufname = vim.api.nvim_buf_get_name(0)
    if string.match(bufname, "/tmp/.*edit") then
      vim.keymap.set("n", "<CR>", ":wq<CR>", {buffer = true, desc = "Save and quit CLI edit"})
      vim.keymap.set("n", "<Esc>", ":q!<CR>", {buffer = true, desc = "Quit without saving"})
    end
  end
})

return M
