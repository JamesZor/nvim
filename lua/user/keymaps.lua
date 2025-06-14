local opts = { noremap = true, silent = true }

local term_opts = { silent = true }

-- Shorten function name
local keymap = vim.api.nvim_set_keymap

--Remap space as leader key
keymap("", "<Space>", "<Nop>", opts)
vim.g.mapleader = " "
vim.g.maplocalleader = " "


-- Spelling 
vim.opt.spelllang = 'en_gb'
vim.opt.spell = true
-- ]s  - go to the next misspelled word 
-- [s  - go to the previous misspelled word 
-- z=  - correct 
keymap('n', '<leader>c', '[sz=', opts)
-- Modes
--   normal_mode = "n",
--   insert_mode = "i",
--   visual_mode = "v",
--   visual_block_mode = "x",
--   term_mode = "t",
--   command_mode = "c",
--
-- Set up copy and paste and the system
-- Use system clipboard
vim.opt.clipboard = 'unnamedplus'

-- Set clipboard provider to use wl-clipboard
vim.g.clipboard = {
  name = 'wl-clipboard',
  copy = {
    ['+'] = 'wl-copy',
    ['*'] = 'wl-copy',
  },
  paste = {
    ['+'] = 'wl-paste',
    ['*'] = 'wl-paste',
  },
  cache_enabled = 0,
}

-- Optional: Set up key mappings for copy and paste
vim.api.nvim_set_keymap('n', '<leader>y', '"+y', { noremap = true })
vim.api.nvim_set_keymap('v', '<leader>y', '"+y', { noremap = true })
vim.api.nvim_set_keymap('n', '<leader>p', '"+p', { noremap = true })
vim.api.nvim_set_keymap('v', '<leader>p', '"+p', { noremap = true })
-- New: Set paste option to false to prevent automatic newline on paste
vim.opt.paste = false


-- Normal --
-- Better window navigation
keymap("n", "<C-h>", "<C-w>h", opts)
keymap("n", "<C-j>", "<C-w>j", opts)
keymap("n", "<C-k>", "<C-w>k", opts)
keymap("n", "<C-l>", "<C-w>l", opts)

keymap("n", "<leader>e", ":Lex 30<cr>", opts)

-- Resize with arrows
keymap("n", "<C-Up>", ":resize +2<CR>", opts)
keymap("n", "<C-Down>", ":resize -2<CR>", opts)
keymap("n", "<C-Left>", ":vertical resize -2<CR>", opts)
keymap("n", "<C-Right>", ":vertical resize +2<CR>", opts)

-- Navigate buffers
keymap("n", "<S-l>", ":bnext<CR>", opts)
keymap("n", "<S-h>", ":bprevious<CR>", opts)

-- New tab controls
keymap("n", "<S-C-m>", ":tabnew<CR>", opts)  -- Create a new tab
keymap("n", "<S-C-j>", ":tabnext<CR>", opts) -- Go to next tab
keymap("n", "<S-C-k>", ":tabprevious<CR>", opts) -- Go to previous tab

-- Insert --
-- Press jk fast to enter
keymap("i", "jk", "<ESC>", opts)

-- Visual --
-- Stay in indent mode
keymap("v", "<", "<gv", opts)
keymap("v", ">", ">gv", opts)

-- Move text up and down
keymap("v", "<A-j>", ":m .+1<CR>==", opts)
keymap("v", "<A-k>", ":m .-2<CR>==", opts)
--keymap("v", "p", '"_dP', opts)

-- remove highlighting when pressing esc 
vim.api.nvim_set_keymap('n', '<Esc>', ':noh<CR>', opts )

-- Visual Block --
-- Move text up and down
keymap("x", "J", ":move '>+1<CR>gv-gv", opts)
keymap("x", "K", ":move '<-2<CR>gv-gv", opts)
keymap("x", "<A-j>", ":move '>+1<CR>gv-gv", opts)
keymap("x", "<A-k>", ":move '<-2<CR>gv-gv", opts)

-- Terminal --
-- Better terminal navigation
keymap("t", "<C-h>", "<C-\\><C-N><C-w>h", term_opts)
keymap("t", "<C-j>", "<C-\\><C-N><C-w>j", term_opts)
keymap("t", "<C-k>", "<C-\\><C-N><C-w>k", term_opts)
keymap("t", "<C-l>", "<C-\\><C-N><C-w>l", term_opts)

 keymap("n", "<leader>f", "<cmd>Telescope find_files<cr>", opts)
--keymap("n", "<leader>f", "<cmd>lua require'telescope.builtin'.find_files(require('telescope.themes').get_dropdown({ previewer = True }))<cr>", opts)
keymap("n", "<c-t>", "<cmd>Telescope live_grep<cr>", opts)


keymap("n", "<c-x>", "", {
  callback = function()
    local filetype = vim.bo.filetype
    if filetype == "sql" then
      vim.cmd("lua _SQL_RUN()")
    else
      print("No run command for filetype: " .. filetype)
    end
  end,
  noremap = true,
  silent = true
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "python",
  callback = function()
    -- LSP features
    vim.keymap.set("n", "<leader>pd", vim.lsp.buf.definition, {buffer=0, desc="Go to definition"})
    vim.keymap.set("n", "<leader>pi", vim.lsp.buf.implementation, {buffer=0, desc="Go to implementation"})
    vim.keymap.set("n", "<leader>pr", vim.lsp.buf.references, {buffer=0, desc="Find references"})
    vim.keymap.set("n", "<leader>pn", vim.lsp.buf.rename, {buffer=0, desc="Rename symbol"})
    vim.keymap.set("n", "<leader>pa", vim.lsp.buf.code_action, {buffer=0, desc="Code action"})
    
    -- Formatting
    vim.keymap.set("n", "<leader>pf", "<cmd>FormatWrite<CR>", {buffer=0, desc="Format file"})
    
    -- Testing (if you add a test framework plugin)
    vim.keymap.set("n", "<leader>pt", "<cmd>TestNearest<CR>", {buffer=0, desc="Test nearest"})
    vim.keymap.set("n", "<leader>pT", "<cmd>TestFile<CR>", {buffer=0, desc="Test file"})
  end
})

