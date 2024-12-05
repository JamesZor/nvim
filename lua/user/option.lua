-- :help options
local vo = vim.opt 	                       -- Set local name to save retyping
vo.backup   = false 	                     -- Creates a backup
vo.clipboard		= "unnamedplus"            -- Allows neavim to access the sys clipboard 
vo.cmdheight 		= 2		                     -- More space in the nvim cmd line for disply messages
vo.completeopt = {"menuone", "noselect"}   -- mostly for cmp
vo.conceallevel 		= 0 		               -- so that `` is vis in markdown files
vo.fileencoding 	= "utf-8"              	 -- Encoding written to a file
vo.hlsearch = true                         -- highlight all matches on previous search pattern
vo.ignorecase = true                       -- ignore case in search patterns
vo.mouse = "a"                             -- allow the mouse to be used in neovim
vo.pumheight = 10                          -- pop up menu height
vo.showmode = false                        -- we don't need to see things like -- INSERT -- anymore
vo.showtabline = 2                         -- always show tabs
vo.smartcase = true                        -- smart case
vo.smartindent = true                      -- make indenting smarter again
vo.splitbelow = true                       -- force all horizontal splits to go below current window
vo.splitright = true                       -- force all vertical splits to go to the right of current window
vo.swapfile = false                        -- creates a swapfile
vo.termguicolors = true                    -- set term gui colors (most terminals support this)
vo.timeoutlen = 1000                       -- time to wait for a mapped sequence to complete (in milliseconds)
vo.undofile = true                         -- enable persistent undo
vo.updatetime = 300                        -- faster completion (4000ms default)
vo.writebackup = false                     -- if a file is being edited by another program (or was written to file while editing with another program), it is not allowed to be edited
vo.expandtab = true                        -- convert tabs to spaces
vo.shiftwidth = 2                          -- the number of spaces inserted for each indentation
vo.tabstop = 2                             -- insert 2 spaces for a tab
vo.cursorline = true                       -- highlight the current line
vo.number = true                           -- set numbered lines
vo.relativenumber 	=	true                  -- set relative numbered lines
vo.numberwidth = 4                         -- set number column width to 2 {default 4}
vo.signcolumn = "yes"                      -- always show the sign column, otherwise it would shift the text each time
vo.wrap = false                            -- display lines as one long line
vo.scrolloff = 8                           -- is one of my fav
vo.sidescrolloff = 8
vo.guifont = "monospace:h17"               -- the font used in graphical neovim applications
vo.colorcolumn = "100"                      -- Add a vertical line at 80 characters
vim.cmd[[highlight ColorColumn ctermbg=lightgrey guibg=lightgrey]]  -- Set the color of the line to light grey
vim.cmd "set whichwrap+=<,>,[,],h,l"
vim.cmd [[set iskeyword+=-]]


vim.opt.clipboard = "unnamedplus"

--vim.g.python3_host_prog = '/home/james/.conda/envs/ml_tf/bin/python'
vim.g.python3_host_prog = '/home/james/.conda/envs/gt/bin/python'
--vim.g.python3_host_prog = vim.fn.expand('')

--
--vim.api.nvim_create_user_command('PyrightInfo', function()
--  local clients = vim.lsp.get_active_clients({name = 'pyright'})
--  if #clients > 0 then
--    local config = clients[1].config
--    print("Pyright is using Python at: " .. (config.settings.python.pythonPath or "Unknown"))
--  else
--    print("Pyright is not attached to this buffer")
--  end
--end, {})
