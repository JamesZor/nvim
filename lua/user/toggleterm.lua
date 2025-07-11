local status_ok, toggleterm = pcall(require, "toggleterm")
if not status_ok then
	return
end

toggleterm.setup({
	size = 20,
	open_mapping = [[<C-\>]],  -- Ctrl+\ to toggle terminal
	hide_numbers = true,
	shade_filetypes = {},
	shade_terminals = true,
	shading_factor = 2,
	start_in_insert = true,
	insert_mappings = true,
	persist_size = true,
	direction = "float",  -- Terminal opens as floating window
	close_on_exit = true,
	shell = vim.o.shell,
	float_opts = {
		border = "curved",
		winblend = 0,
		highlights = {
			border = "Normal",
			background = "Normal",
		},
	},
})

-- Terminal navigation keymaps - allows you to move between windows while in terminal mode
function _G.set_terminal_keymaps()
  local opts = {noremap = true}
  vim.api.nvim_buf_set_keymap(0, 't', '<esc>', [[<C-\><C-n>]], opts)     -- Escape to normal mode
  vim.api.nvim_buf_set_keymap(0, 't', 'jk', [[<C-\><C-n>]], opts)       -- jk to normal mode
  vim.api.nvim_buf_set_keymap(0, 't', '<C-h>', [[<C-\><C-n><C-W>h]], opts) -- Navigate left
  vim.api.nvim_buf_set_keymap(0, 't', '<C-j>', [[<C-\><C-n><C-W>j]], opts) -- Navigate down
  vim.api.nvim_buf_set_keymap(0, 't', '<C-k>', [[<C-\><C-n><C-W>k]], opts) -- Navigate up
  vim.api.nvim_buf_set_keymap(0, 't', '<C-l>', [[<C-\><C-n><C-W>l]], opts) -- Navigate right
end

vim.cmd('autocmd! TermOpen term://* lua set_terminal_keymaps()')

local Terminal = require("toggleterm.terminal").Terminal

-- SQL Runner - runs SQL files through sqlite3
local sql_run = Terminal:new({
  cmd = function()
    local file = vim.fn.expand('%:p')  -- Get current file path
    local db_file = vim.fn.fnamemodify(file, ':r') .. '.db'  -- Create .db filename
    -- Currently just echoes the command, uncomment first line to actually run
    --return string.format("sqlite3 %s < %s", db_file, file)
    return string.format("echo 'sqlite3 %s < %s '", db_file, file)
  end,
  direction = "float",
  hidden = true,  -- Doesn't show in terminal list
  close_on_exit = false,
  on_open = function(term)
    vim.cmd("startinsert!")
    vim.api.nvim_buf_set_keymap(term.bufnr, "n", "q", "<cmd>close<CR>", {noremap = true, silent = true})
  end,
})

function _SQL_RUN()
  sql_run:toggle()
end

-- System monitoring with htop
local htop = Terminal:new({ 
  cmd = "htop", 
  hidden = true,
  direction = "float",
})

function _HTOP_TOGGLE()
	htop:toggle()
end

-- Python REPL
local python = Terminal:new({ 
  cmd = "python", 
  hidden = true,
  direction = "float",
})

function _PYTHON_TOGGLE()
	python:toggle()
end

-- NEW: Julia REPL with project support
local julia = Terminal:new({
  cmd = "julia --project",  -- Starts Julia with local project environment
  dir = "git_dir",  -- Uses git root as working directory
  direction = "vertical",  -- Opens as vertical split (better for REPL work)
  hidden = true,
  close_on_exit = false,  -- Keep terminal open when Julia exits
  float_opts = {
    border = "double",
  },
  on_open = function(term)
    vim.cmd("startinsert!")  -- Start in insert mode
    -- Press 'q' in normal mode to close
    vim.api.nvim_buf_set_keymap(term.bufnr, "n", "q", "<cmd>close<CR>", {noremap = true, silent = true})
  end,
  on_close = function(term)
    vim.cmd("startinsert!")
  end,
})

function _JULIA_TOGGLE()
  julia:toggle()
end

-- Key mappings for easy access
vim.api.nvim_set_keymap("n", "<leader>jt", "<cmd>lua _JULIA_TOGGLE()<CR>", {noremap = true, silent = true, desc = "Toggle Julia REPL"})
vim.api.nvim_set_keymap("n", "<leader>pt", "<cmd>lua _PYTHON_TOGGLE()<CR>", {noremap = true, silent = true, desc = "Toggle Python REPL"})
vim.api.nvim_set_keymap("n", "<leader>ht", "<cmd>lua _HTOP_TOGGLE()<CR>", {noremap = true, silent = true, desc = "Toggle htop"})
vim.api.nvim_set_keymap("n", "<leader>sr", "<cmd>lua _SQL_RUN()<CR>", {noremap = true, silent = true, desc = "Run SQL file"})
