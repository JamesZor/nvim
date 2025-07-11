-- ~/.config/nvim/lua/user/iron.lua

local status_ok, iron = pcall(require, "iron.core")
if not status_ok then
  return
end

iron.setup({
  config = {
    -- Whether a repl should be discarded or not
    scratch_repl = true,
    -- Your repl definitions come here
    repl_definition = {
      julia = {
        command = {"julia", "--project"}
      },
      python = {
        command = {"python3"}
      }
    },
    -- How the repl window will be displayed
    repl_open_cmd = require('iron.view').right(80),
  },
  -- Iron doesn't set keymaps by default anymore.
  keymaps = {
    send_motion = "<leader>sc",
    visual_send = "<leader>sc",
    send_file = "<leader>sf",
    send_line = "<leader>sl",
    send_until_cursor = "<leader>su",
    send_mark = "<leader>sm",
    mark_motion = "<leader>mc",
    mark_visual = "<leader>mc",
    remove_mark = "<leader>md",
    cr = "<leader>s<cr>",
    interrupt = "<leader>s<space>",
    exit = "<leader>sq",
    clear = "<leader>cl",
  },
  -- If the highlight is on, you can change how it looks
  highlight = {
    italic = true
  },
  ignore_blank_lines = true, -- ignore blank lines when sending visual select lines
})

-- Julia-specific keymaps
local function setup_julia_keymaps()
  local opts = { buffer = true, silent = true }
  
  -- Send code blocks (between ## markers)
  vim.keymap.set('n', '<leader>jc', function()
    -- Find current cell (between ## markers)
    local current_line = vim.fn.line('.')
    local start_line = current_line
    local end_line = current_line
    
    -- Find start of cell
    for i = current_line, 1, -1 do
      local line_content = vim.fn.getline(i)
      if line_content:match('^##') then
        start_line = i + 1
        break
      end
      if i == 1 then start_line = 1 end
    end
    
    -- Find end of cell
    for i = current_line + 1, vim.fn.line('$') do
      local line_content = vim.fn.getline(i)
      if line_content:match('^##') then
        end_line = i - 1
        break
      end
      if i == vim.fn.line('$') then end_line = i end
    end
    
    -- Send the cell
    vim.cmd(start_line .. ',' .. end_line .. 'IronSend')
  end, vim.tbl_extend('force', opts, { desc = 'Send Julia cell' }))
  
  -- Quick evaluate expression under cursor
  vim.keymap.set('n', '<leader>je', 'yiw:IronSend @show <C-r>"<CR>', 
    vim.tbl_extend('force', opts, { desc = 'Evaluate expression' }))
    
  -- Start Julia REPL
  vim.keymap.set('n', '<leader>jr', ':IronRepl julia<CR>', 
    vim.tbl_extend('force', opts, { desc = 'Start Julia REPL' }))
end

-- Auto-setup Julia keymaps for .jl files
vim.api.nvim_create_autocmd("FileType", {
  pattern = "julia",
  callback = setup_julia_keymaps,
})
