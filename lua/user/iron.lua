-- ~/.config/nvim/lua/user/iron.lua

local status_ok, iron = pcall(require, "iron.core")
if not status_ok then
  return
end

-- Fixed iron.nvim setup with vertical split
iron.setup({
  config = {
    scratch_repl = true,
    repl_definition = {
      julia = {
        command = {"julia", "--project", "--threads=auto"}
      },
      -- python = {
      --   command = {"python3"}
      -- }
    },
    -- Use vertical split (40% of screen width)
    repl_open_cmd = require('iron.view').split.vertical.botright(0.4),

    repl_close_command = "exit()",
    send = {
      mark = {
        open_luasnip = true,
        close_luasnip = true,
      },
    },
  },
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
  highlight = {
    italic = true
  },
  ignore_blank_lines = true,
})

-- Enhanced window management for iron REPL
local function setup_iron_window_navigation()
  -- Easy navigation to iron REPL window
  vim.keymap.set('n', '<leader>jr', function()
    local iron = require("iron.core")
    iron.repl_for(vim.bo.filetype)
    -- Small delay to let the REPL open, then jump to it
    vim.defer_fn(function()
      -- Find the iron REPL buffer
      for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
        local buf_name = vim.api.nvim_buf_get_name(bufnr)
        if string.match(buf_name, "iron://") then
          local repl_win = vim.fn.bufwinid(bufnr)
          if repl_win ~= -1 then
            vim.api.nvim_set_current_win(repl_win)
            vim.cmd("startinsert")
            break
          end
        end
      end
    end, 100)
  end, { desc = "Open and jump to Julia REPL" })

  -- Toggle REPL visibility
  vim.keymap.set('n', '<leader>jt', function()
    local iron = require("iron.core")
    
    -- Find iron REPL buffer
    local repl_bufnr = nil
    for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
      local buf_name = vim.api.nvim_buf_get_name(bufnr)
      if string.match(buf_name, "iron://") and vim.api.nvim_buf_is_loaded(bufnr) then
        repl_bufnr = bufnr
        break
      end
    end
    
    if repl_bufnr then
      -- REPL buffer exists, check if window is visible
      local repl_win = vim.fn.bufwinid(repl_bufnr)
      if repl_win ~= -1 then
        -- REPL window is visible, hide it
        vim.api.nvim_win_close(repl_win, false)
      else
        -- REPL buffer exists but window is hidden, show it
        vim.cmd("vertical rightbelow sbuffer " .. repl_bufnr)
        vim.api.nvim_win_set_width(0, math.floor(vim.o.columns * 0.4))
      end
    else
      -- No REPL exists, create one
      iron.repl_for(vim.bo.filetype)
    end
  end, { desc = "Toggle Julia REPL window" })

  -- Quick jump to REPL window
  vim.keymap.set('n', '<leader>jw', function()
    -- Find iron REPL buffer
    for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
      local buf_name = vim.api.nvim_buf_get_name(bufnr)
      if string.match(buf_name, "iron://") and vim.api.nvim_buf_is_loaded(bufnr) then
        local repl_win = vim.fn.bufwinid(bufnr)
        if repl_win ~= -1 then
          vim.api.nvim_set_current_win(repl_win)
          vim.cmd("startinsert")
          return
        end
      end
    end
    vim.notify("No REPL window is currently visible", vim.log.levels.WARN)
  end, { desc = "Jump to REPL window" })

  -- Send and stay in current window
  vim.keymap.set('n', '<leader>js', function()
    local current_win = vim.api.nvim_get_current_win()
    vim.cmd("IronSend")
    vim.api.nvim_set_current_win(current_win)
  end, { desc = "Send line and stay in current window" })
end

-- Julia-specific enhanced keymaps
local function setup_julia_keymaps()
  local opts = { buffer = true, silent = true }
  
  -- Send code blocks (between ## markers) - enhanced version
  vim.keymap.set('n', '<leader>jc', function()
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
    
    -- Store current window
    local current_win = vim.api.nvim_get_current_win()
    
    -- Send the cell
    vim.cmd(start_line .. ',' .. end_line .. 'IronSend')
    
    -- Return to original window
    vim.api.nvim_set_current_win(current_win)
  end, vim.tbl_extend('force', opts, { desc = 'Send Julia cell and stay' }))
  
  -- Quick evaluate expression under cursor
  vim.keymap.set('n', '<leader>je', function()
    local current_win = vim.api.nvim_get_current_win()
    vim.cmd('normal! yiw')
    local word = vim.fn.getreg('"')
    local iron = require("iron.core")
    iron.send(vim.bo.filetype, "@show " .. word)
    vim.api.nvim_set_current_win(current_win)
  end, vim.tbl_extend('force', opts, { desc = 'Evaluate expression and stay' }))
    
  -- Enhanced REPL management
  vim.keymap.set('n', '<leader>jr', function()
    local iron = require("iron.core")
    iron.repl_for(vim.bo.filetype)
    -- Automatically resize the window
    vim.defer_fn(function()
      -- Find the iron REPL buffer and resize its window
      for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
        local buf_name = vim.api.nvim_buf_get_name(bufnr)
        if string.match(buf_name, "iron://") and vim.api.nvim_buf_is_loaded(bufnr) then
          local repl_win = vim.fn.bufwinid(bufnr)
          if repl_win ~= -1 then
            vim.api.nvim_win_set_width(repl_win, math.floor(vim.o.columns * 0.4))
            break
          end
        end
      end
    end, 100)
  end, vim.tbl_extend('force', opts, { desc = 'Start Julia REPL with proper size' }))
end

-- Auto-setup keymaps
vim.api.nvim_create_autocmd("FileType", {
  pattern = "julia",
  callback = setup_julia_keymaps,
})

-- Setup window navigation for all filetypes
setup_iron_window_navigation()

-- Optional: Auto-resize REPL window when it opens
vim.api.nvim_create_autocmd("BufWinEnter", {
  pattern = "*",
  callback = function()
    local buf_name = vim.api.nvim_buf_get_name(0)
    if string.match(buf_name, "iron://") then
      -- This is an iron REPL buffer, resize it
      vim.defer_fn(function()
        local win = vim.api.nvim_get_current_win()
        if vim.api.nvim_win_is_valid(win) then
          vim.api.nvim_win_set_width(win, math.floor(vim.o.columns * 0.4))
        end
      end, 50)
    end
  end,
})
