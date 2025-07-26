local M = {}

M.setup = function()
  local status_ok, saga = pcall(require, "lspsaga")
  if not status_ok then
    return
  end

  saga.setup({
    ui = {
      border = "rounded",
      code_action = " ",
    },
    symbol_in_winbar = {
      enable = true,
      separator = " › ",
      hide_keyword = true,
      show_file = true,
      folder_level = 2,
      respect_root = false,
      color_mode = true,
    },
    lightbulb = {
      enable = true,
      enable_in_insert = true,
      sign = true,
      sign_priority = 40,
      virtual_text = true,
    },
    code_action = {
      num_shortcut = true,
      keys = {
        quit = {"q", "<ESC>"},
        exec = "<CR>",
      },
    },
    -- Python-specific behavior
    finder = {
      edit = {"o", "<CR>"},
      vsplit = "v",
      split = "s",
      tabe = "t",
      quit = {"q", "<ESC>"},
    },
    definition = {
      edit = "<C-c>o",
      vsplit = "<C-c>v",
      split = "<C-c>s",
      tabe = "<C-c>t",
      quit = "q",
      close = "<ESC>",
    },
    outline = {
      win_position = "right",
      win_width = 30,
      auto_preview = true,
      detail = true,
      auto_refresh = true,
      auto_close = true,
      keys = {
        jump = "o",
        expand_collapse = "u",
        quit = "q",
      },
    },
  })
end

-- Set up lspsaga keymaps (can be called in handlers.lua)
M.set_keymaps = function(bufnr)
  local opts = { noremap = true, silent = true }
  
  -- Replace default LSP keymaps with lspsaga ones
  vim.api.nvim_buf_set_keymap(bufnr, "n", "gh", "<cmd>Lspsaga lsp_finder<CR>", opts)
  vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>ca", "<cmd>Lspsaga code_action<CR>", opts)
  vim.api.nvim_buf_set_keymap(bufnr, "n", "K", "<cmd>Lspsaga hover_doc<CR>", opts)
  vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>rn", "<cmd>Lspsaga rename<CR>", opts)
  vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>cd", "<cmd>Lspsaga show_line_diagnostics<CR>", opts)
  vim.api.nvim_buf_set_keymap(bufnr, "n", "[e", "<cmd>Lspsaga diagnostic_jump_prev<CR>", opts)
  vim.api.nvim_buf_set_keymap(bufnr, "n", "]e", "<cmd>Lspsaga diagnostic_jump_next<CR>", opts)

  -- Additional useful keymaps
  vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>o", "<cmd>Lspsaga outline<CR>", opts)
  vim.api.nvim_buf_set_keymap(bufnr, "n", "gp", "<cmd>Lspsaga peek_definition<CR>", opts)
  vim.api.nvim_buf_set_keymap(bufnr, "n", "gd", "<cmd>Lspsaga goto_definition<CR>", opts)
  
  -- Especially useful for Python
  vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>ft", "<cmd>Lspsaga peek_type_definition<CR>", opts)
end

return M
