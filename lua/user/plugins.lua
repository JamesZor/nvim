local fn = vim.fn
-- Automatically install packer
local install_path = fn.stdpath "data" .. "/site/pack/packer/start/packer.nvim"
if fn.empty(fn.glob(install_path)) > 0 then
  PACKER_BOOTSTRAP = fn.system {
    "git",
    "clone",
    "--depth",
    "1",
    "https://github.com/wbthomason/packer.nvim",
    install_path,
  }
  print "Installing packer close and reopen Neovim..."
  vim.cmd [[packadd packer.nvim]]
end

-- Autocommand that reloads neovim whenever you save the plugins.lua file
vim.cmd [[
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost plugins.lua source <afile> | PackerSync
  augroup end
]]

-- Use a protected call so we don't error out on first use
local status_ok, packer = pcall(require, "packer")
if not status_ok then
  return
end

-- Have packer use a popup window
packer.init {
  display = {
    open_fn = function()
      return require("packer.util").float { border = "rounded" }
    end,
  },
}

-- Install your plugins here
return packer.startup(function(use)
  use {
    "Vigemus/iron.nvim",
    config = function()
      require("user.iron")
    end
  }

  -- LSP signature - shows function signatures as you type
  -- use "ray-x/lsp_signature.nvim"

  -- Alternative to nvim-lsp-inlayhints - Official neovim inlay hints
  use 'felpafel/inlay-hint.nvim'

  -- Lspsaga for comprehensive UI enhancements
  use {
    "glepnir/lspsaga.nvim",
    branch = "main",
    requires = {
      {"nvim-tree/nvim-web-devicons"},
      {"nvim-treesitter/nvim-treesitter"}
    }
  }

  -- formatter.nvim for code formatting
  use "mhartington/formatter.nvim"

  -- WhoIsSethDaniel/mason-tool-installer.nvim for auto-installing tools
  use "WhoIsSethDaniel/mason-tool-installer.nvim"
  -- My plugins here
  use "wbthomason/packer.nvim" -- Have packer manage itself
  use "nvim-lua/popup.nvim" -- An implementation of the Popup API from vim in Neovim
  use "nvim-lua/plenary.nvim" -- Useful lua functions used ny lots of plugins


  -- Dadbod for database management
  use "tpope/vim-dadbod" -- Core database interface
  use "kristijanhusak/vim-dadbod-ui" -- UI for vim-dadbod
  use "kristijanhusak/vim-dadbod-completion" -- Completion for vim-dadbod

  -- TreeSitter DBML Grammar
  use "dynamotn/tree-sitter-dbml"
  -- DBML syntax highlighting and support
  use "jidn/vim-dbml"


  -- CMP plugins
  use "hrsh7th/nvim-cmp"    -- The completion plugin 
  use "hrsh7th/cmp-buffer"  -- Buffer Completions 
  use "hrsh7th/cmp-path"    -- Path completions 
  use "hrsh7th/cmp-cmdline" -- CMD line Completions 
  use "hrsh7th/cmp-nvim-lsp" -- lsp Completions 
  use "saadparwaiz1/cmp_luasnip" -- snippet completions


  -- LSP 
  use "williamboman/mason.nvim"   -- Simple to use laguage server installer
  use "williamboman/mason-lspconfig.nvim"   -- Simple to use laguage server installer
  use "neovim/nvim-lspconfig"   -- enable LSP
  use 'jose-elias-alvarez/null-ls.nvim' -- LSP diagnostics and code actions

  -- sql thing 
  use 'nanotee/sqls.nvim'

  -- Markdown Preview
  use {
    "OXY2DEV/markview.nvim",
    requires = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
      "3rd/image.nvim",
    },
    config = function()
      require("user.markview").setup()
    end,
  }
  -- TODO Comments plugin
  use {
    "folke/todo-comments.nvim",
    requires = "nvim-lua/plenary.nvim",
    config = function()
      require("user.todo_comments")
    end
  }

  -- Optional: Trouble.nvim for a nice TODO panel
  use {
    "folke/trouble.nvim",
    requires = "nvim-tree/nvim-web-devicons",
    config = function()
      require("trouble").setup {}
    end
  }

  -- Treesitter
  use {
      'nvim-treesitter/nvim-treesitter',
      run = function()
          local ts_update = require('nvim-treesitter.install').update({ with_sync = true })
          ts_update()
      end,
  }

  -- comment plug 
  use {
    'numToStr/Comment.nvim',
    config = function()
        require('Comment').setup()
    end
}

  use "p00f/nvim-ts-rainbow"

  -- Latex 
  use 'lervag/vimtex'

  -- Snippets
  use {"L3MON4D3/LuaSnip", run = "make install_jsregexp"}-- Snippet engine
  use "rafamadriz/friendly-snippets" -- a bunch of snippets to use

  -- Telescope
  use "nvim-telescope/telescope.nvim"

  -- toggle term 
  use "akinsho/toggleterm.nvim"

  -- Colour schemes
  use "ellisonleao/gruvbox.nvim" -- gruvbox
  use "lunarvim/colorschemes"

    -- Your existing plugins...
  use {
    "3rd/image.nvim",
    config = function()
      require('image').setup({
        backend = "kitty",  -- Keep this if you're using kitty terminal
        
        integrations = {
          markdown = {
            enabled = true,
            clear_in_insert_mode = false,
            download_remote_images = true,
            only_render_image_at_cursor = false,
            filetypes = { "markdown", "vimwiki" },
          },
          neorg = {
            enabled = true,
            clear_in_insert_mode = false,
            download_remote_images = true,
            only_render_image_at_cursor = false,
          },
          -- Removed the molten integration that was causing errors
        },
        
        -- Increase max dimensions for better visualization of plots and graphs
        max_width = 150,      -- Increased from 100
        max_height = 20,      -- Increased from 12
        
        max_height_window_percentage = math.huge,
        max_width_window_percentage = math.huge,
        window_overlap_clear_enabled = true,
        window_overlap_clear_ft_ignore = { "cmp_menu", "cmp_docs", "" },
        
        -- Add rendering options section for better image quality
        render = {
          min_padding = 5,
          show_label = true,
          use_dither = true,
          foreground_color = false,
          background_color = false
        },
      })
    end,
  }
  use {
    "benlubas/molten-nvim",
    version = "^1.0.0",
    run = ":UpdateRemotePlugins",
    dependencies = { "3rd/image.nvim" },
    config = function()
      require("user.molten").setup() -- Note the added .setup()
    end,
  }


  use {
    "jghauser/kitty-runner.nvim",
    config = function()
      require("kitty-runner").setup()
    end
  }


   -- Automatically set up your configuration after cloning packer.nvim
  -- Put this at the end after all plugins
  if PACKER_BOOTSTRAP then
    require("packer").sync()
  end
end)
