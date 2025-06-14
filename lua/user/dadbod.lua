local M = {}

function M.setup()
  -- Dadbod UI configuration
  vim.g.db_ui_use_nerd_fonts = 1
  vim.g.db_ui_show_database_icon = 1
  vim.g.db_ui_force_echo_notifications = 1
  
  -- Optional: Set a default save location for query results
  vim.g.db_ui_save_location = vim.fn.stdpath("data") .. '/db_ui'
  
  -- Define custom database icons if you're using nerd fonts
  vim.g.db_ui_icons = {
    expanded = {
      db = '▾ ',
      buffers = '▾ ',
      saved_queries = '▾ ',
      schemas = '▾ ',
      schema = '▾ ',
      tables = '▾ ',
      table = '▾ ',
    },
    collapsed = {
      db = '▸ ',
      buffers = '▸ ',
      saved_queries = '▸ ',
      schemas = '▸ ',
      schema = '▸ ',
      tables = '▸ ',
      table = '▸ ',
    },
    saved_query = '',
    new_query = '󰐕',
    tables = '󰓫',
    buffers = '󰈙',
    add_connection = '󰆺',
    connection_ok = '✓',
    connection_error = '✕',
  }
  
  -- Set up key mappings
  local opts = { noremap = true, silent = true }
  
  -- Open DBUI
  vim.api.nvim_set_keymap('n', '<leader>db', '<Cmd>DBUIToggle<CR>', opts)
  
  -- Save query to file
  vim.api.nvim_set_keymap('n', '<leader>ds', '<Cmd>DBUIFindBuffer<CR>', opts)
  
  -- Last used connection
  vim.api.nvim_set_keymap('n', '<leader>dl', '<Cmd>DBUILastQueryInfo<CR>', opts)
  
  -- Set up database completion for SQL files
  vim.api.nvim_create_autocmd("FileType", {
    pattern = {"sql", "mysql", "plsql"},
    callback = function()
      require('cmp').setup.buffer({
        sources = {
          { name = 'vim-dadbod-completion' },
          { name = 'buffer' },
        }
      })
    end
  })
end

return M
