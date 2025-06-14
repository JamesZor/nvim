-- lua/user/dbml.lua
local M = {}

M.setup = function()
  -- Define keybindings for DBML files
  vim.api.nvim_create_autocmd("FileType", {
    pattern = "dbml",
    callback = function()
      -- Convert DBML to SQL (PostgreSQL)
      vim.keymap.set("n", "<leader>dp", ":!dbml2sql % -o %:r.sql --postgres<CR>", 
        { buffer = true, desc = "Convert DBML to PostgreSQL" })
      
      -- Build dbdocs
      vim.keymap.set("n", "<leader>db", ":!dbdocs build % --project betting_system<CR>", 
        { buffer = true, desc = "Build dbdocs" })
      
      -- Convert SQL to DBML (for when you're working with SQL files)
      vim.keymap.set("n", "<leader>ds", ":!sql2dbml % -o %:r.dbml<CR>", 
        { buffer = true, desc = "Convert SQL to DBML" })
    end,
  })

  -- Ensure file type detection for DBML
  vim.cmd[[
    augroup dbml_filetype
      autocmd!
      autocmd BufRead,BufNewFile *.dbml set filetype=dbml
    augroup END
  ]]
end

return M
