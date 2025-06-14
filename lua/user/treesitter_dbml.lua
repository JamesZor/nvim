-- File: lua/user/treesitter_dbml.lua

local M = {}

M.setup = function()
  -- Get the current treesitter config
  local status_ok, treesitter_configs = pcall(require, "nvim-treesitter.configs")
  if not status_ok then
    vim.notify("TreeSitter not found, DBML grammar not loaded", vim.log.levels.WARN)
    return
  end

  -- Ensure the parser is installed
  local parser_config = require "nvim-treesitter.parsers".get_parser_configs()
  parser_config.dbml = {
    install_info = {
      url = "https://github.com/dynamotn/tree-sitter-dbml",
      files = {"src/parser.c"},
      branch = "main",
    },
    filetype = "dbml",
  }

  -- Set up file type detection for DBML files
  vim.cmd[[
    augroup dbml_filetype
      autocmd!
      autocmd BufNewFile,BufRead *.dbml setfiletype dbml
    augroup END
  ]]

  -- Configure TreeSitter for DBML
  local configs = require("nvim-treesitter.configs")
  configs.setup {
    ensure_installed = "dbml", -- Add DBML to ensure_installed list
    highlight = {
      enable = true,
      additional_vim_regex_highlighting = false,
    },
    indent = {
      enable = true,
    },
    rainbow = {
      enable = true,
      extended_mode = true,
      max_file_lines = nil,
    },
  }

  -- Add keymaps for DBML
  vim.api.nvim_create_autocmd("FileType", {
    pattern = "dbml",
    callback = function()
      -- Convert SQL to DBML
      vim.keymap.set("n", "<leader>ds", ":!sql2dbml % -o %:r.dbml<CR>", 
        { buffer = true, desc = "Convert SQL to DBML" })
      
      -- Convert DBML to SQL (PostgreSQL)
      vim.keymap.set("n", "<leader>dp", ":!dbml2sql % -o %:r.sql --postgres<CR>", 
        { buffer = true, desc = "Convert DBML to PostgreSQL" })
      
      -- Build dbdocs
      vim.keymap.set("n", "<leader>db", ":!dbdocs build % --project betting_system<CR>", 
        { buffer = true, desc = "Build dbdocs" })
    end,
  })
end

return M
