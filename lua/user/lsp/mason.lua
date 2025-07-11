local util = require('lspconfig/util')

local servers = {
  "lua_ls",
--  "pyright",
  "pylsp",      -- Added for enhanced Python IDE features
  "ruff",   -- Added for fast Python linting/fixing
  "jsonls",
  -- "texlab",
  "sqls",
  -- "matlab_ls",
  "julials",
  "efm",
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

  -- dbml stuff
  efm = {
    init_options = {
      documentFormatting = true,
      documentRangeFormatting = true,
    },
    filetypes = { "dbml", "sql" }, -- Add DBML to efm filetypes
    settings = {
      rootMarkers = { ".git/" },
      languages = {
        dbml = {
          {
            lintCommand = "dbml-validate ${INPUT}",
            lintStdin = false,
            lintFormats = {
              "%f:%l:%c: %m",
            },
            lintIgnoreExitCode = true,
          },
        },
      },
    },
  },
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

  if server == "pylsp" then
    -- Simple debug
    local conda_prefix = os.getenv("CONDA_PREFIX")
    --print("DEBUG: CONDA_PREFIX = " .. (conda_prefix or "NONE"))
    
    -- Configure python-lsp-server with useful plugins  
    opts.settings = {
      pylsp = {
        plugins = {
          flake8 = { enabled = false },
          pycodestyle = { enabled = false },
          pyflakes = { enabled = false },
          pylint = { enabled = false },
          yapf = { enabled = false },
          autopep8 = { enabled = false },
          rope_autoimport = { enabled = false },
          rope_completion = { enabled = false },
          jedi_completion = { 
            enabled = true,
            fuzzy = true,
            include_params_in_completion = true,
            include_class_objects = true,
            include_function_objects = true,
          },
          jedi_hover = { enabled = true },
          jedi_references = { enabled = true },
          jedi_signature_help = { enabled = true },
          jedi_symbols = { enabled = true, all_scopes = true },
        }
      }
    }
    
    -- Set python path
    if conda_prefix then
      opts.cmd = { conda_prefix .. "/bin/python", "-m", "pylsp" }
     -- print("DEBUG: Using python = " .. conda_prefix .. "/bin/python")
    else
      opts.cmd = { "/home/james/miniconda3/envs/webscraper/bin/python", "-m", "pylsp" }
      --print("DEBUG: Using fallback webscraper python")
    end

  elseif server == "julials" then
      -- Use the Mason-installed julia-lsp instead of custom command
      -- Don't override the cmd - let Mason handle it
      opts.filetypes = {"julia"}
      opts.settings = {
        julia = {
          -- Language server settings
          symbolCacheDownload = true,
          
          -- Linting settings
          lint = {
            missingrefs = "all",
            iter = true,
            call = true,
            typePropagation = true
          },
          
          -- Formatting settings
          format = {
            indent = 4,
          },
          
          -- Completion settings
          completionmode = "qualify",
        }
      }
      
      opts.single_file_support = true
      opts.root_dir = function(fname)
        return util.find_git_ancestor(fname) or util.path.dirname(fname)
      end

  elseif server == "ruff" then
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
