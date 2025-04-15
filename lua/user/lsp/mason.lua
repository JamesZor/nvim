local util = require('lspconfig/util')

local servers = {
  "lua_ls",
  "pyright",
  "pylsp",      -- Added for enhanced Python IDE features
  "ruff",   -- Added for fast Python linting/fixing
  "jsonls",
  -- "texlab",
  -- "sqls",
  -- "matlab_ls",
  "julials",
  -- 'marksman',
}

local settings = {
  ui = {
    border = "none",
    icons = {
      package_installed = "◍",
      package_pending = "◍",
      package_uninstalled = "◍",
    },
  },
  log_level = vim.log.levels.INFO,
  max_concurrent_installers = 4,
}

local tools = {
  'mypy',       -- Static type checker
  'black',      -- Code formatter
  'isort',      -- Import sorter
  'debugpy',    -- Debug adapter for nvim-dap
}

-- Add this in your main setup logic to throttle UI updates
vim.diagnostic.config({
  update_in_insert = false,  -- Only update diagnostics after leaving insert mode
  underline = true,
  virtual_text = { spacing = 4 },
  severity_sort = true,
})

require("mason").setup(settings)
require("mason-lspconfig").setup({
  ensure_installed = servers,
  automatic_installation = true,
})

-- Setup Mason tools installer
require("mason-tool-installer").setup({
  ensure_installed = tools,
  auto_update = true,
  run_on_start = true,
})

local lspconfig_status_ok, lspconfig = pcall(require, "lspconfig")
if not lspconfig_status_ok then
  return
end

local opts = {}

for _, server in pairs(servers) do
  opts = {
    on_attach = require("user.lsp.handlers").on_attach,
    capabilities = require("user.lsp.handlers").capabilities,
  }
  
  server = vim.split(server, "@")[1]

  if server == "pyright" then
    -- Let Pyright handle type checking but with better settings
    opts.settings = {
      python = {
        analysis = {
          autoSearchPaths = true,
          useLibraryCodeForTypes = true,
          diagnosticMode = "workspace",
          typeCheckingMode = "basic",  -- Enable basic type checking
          inlayHints = {
            variableTypes = true,      -- Show variable types inline
            functionReturnTypes = true -- Show return types inline
          }
        }
      }
    }
  elseif server == "pylsp" then
    -- Configure python-lsp-server with useful plugins
    opts.settings = {
      pylsp = {
        plugins = {
          flake8 = { enabled = false },  -- Use ruff instead
          pycodestyle = { enabled = false },  -- Use ruff instead
          pyflakes = { enabled = false },  -- Use ruff instead
          pylint = { enabled = false },  -- Use ruff instead
          yapf = { enabled = false },  -- Use black instead
          autopep8 = { enabled = false },  -- Use black instead
          jedi_completion = { 
            enabled = true,
            fuzzy = true,
          },
          jedi_hover = { enabled = true },
          jedi_references = { enabled = true },
          jedi_signature_help = { enabled = true },
          jedi_symbols = { enabled = true, all_scopes = true },
          rope_completion = { enabled = true },
          rope_autoimport = { enabled = true },
        }
      }
    }

  elseif server == "julials" then
    opts.filetypes = {"julia"}
    opts.settings = {
      julia = {
        -- Julia executable settings
        executablePath = "julia",
        
        -- Language server settings
        symbolCacheDownload = true,  -- Enable symbol cache
        
        -- Linting settings
        lint = {
          missingrefs = "all",  -- Report all missing references
          iter = true,          -- Iterative linting
          call = true,          -- Check function calls
          typePropagation = true  -- Enable type propagation
        },
        
        -- Formatting settings
        format = {
          indent = 4,  -- Number of spaces for indentation
        },
        
        -- Completion settings
        completionmode = "qualify",  -- Add module qualifier to completions
        
        -- Environment settings
        environmentPath = vim.fn.expand("~/.julia/environments/v1.11")  -- Point to your Julia env
      }
    }
  opts.single_file_support = true
  opts.root_dir = function(fname)
    return util.find_git_ancestor(fname) or util.path.dirname(fname)
  end


  elseif server == "ruff_lsp" then
    -- Configure ruff-lsp for fast linting and fixing
    opts.init_options = {
      settings = {
        -- Configure ruff linter settings
        lint = {
          run = "onSave",  -- Run on save
        },
        organizeImports = true,
        fixAll = true,
      }
    }
  end
  
  local require_ok, conf_opts = pcall(require, "user.lsp.settings." .. server)
  if require_ok then
    opts = vim.tbl_deep_extend("force", conf_opts, opts)
  end
  
  lspconfig[server].setup(opts)
end

-- Set up formatter
local formatter_status_ok, formatter = pcall(require, "formatter")
if formatter_status_ok then
  formatter.setup({
    filetype = {
      python = {
        -- Use black to format Python code
        function()
          return {
            exe = "black",
            args = {"--quiet", "-"},
            stdin = true,
          }
        end,
        -- Use isort to organize imports
        function()
          return {
            exe = "isort",
            args = {"--profile", "black", "-"},
            stdin = true,
          }
        end,
      },
    }
  })
end

-- Set up automatic formatting on save
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*.py",
  callback = function()
    if formatter_status_ok then
      vim.cmd("FormatWrite")
    end
  end,
})



