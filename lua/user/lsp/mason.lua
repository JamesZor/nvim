local util = require('lspconfig/util')

-- Disable lspconfig's automatic server detection
vim.g.lspconfig_automatic_setup = false

-- Tools to install (but NOT auto-configure)
local tools_only = {
  'mypy',
  'black', 
  'isort',
  'debugpy',
  'stylua',
  'jq',
  'shellcheck',
  -- LSP binaries (we'll configure manually)
  'lua-language-server',
  'python-lsp-server', 
  'ruff',
  'json-lsp',
  'sqls',
  'julia-lsp',
  'efm',
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

vim.diagnostic.config({
  update_in_insert = false,
  underline = true,
  virtual_text = { spacing = 4 },
  severity_sort = true,
})

-- Only setup Mason for installing tools, NO auto-configuration
require("mason").setup(settings)

-- Install tools via mason-tool-installer ONLY (no mason-lspconfig)
require("mason-tool-installer").setup({
  ensure_installed = tools_only,
  auto_update = true,
  run_on_start = true,
})

local lspconfig_status_ok, lspconfig = pcall(require, "lspconfig")
if not lspconfig_status_ok then
  return
end

-- Clear any existing configurations to prevent conflicts
local configs = require('lspconfig.configs')
for server_name, _ in pairs(configs) do
  configs[server_name] = nil
end

-- MANUAL LSP configuration ONLY - explicit control
local function setup_server(server_name, custom_opts)
  local default_opts = {
    on_attach = require("user.lsp.handlers").on_attach,
    capabilities = require("user.lsp.handlers").capabilities,
  }
  
  -- Ensure consistent position encoding for all servers
  if default_opts.capabilities and default_opts.capabilities.general then
    default_opts.capabilities.general.positionEncodings = { "utf-16" }
  end
  
  local opts = vim.tbl_deep_extend("force", default_opts, custom_opts or {})
  
  -- Check if server-specific config exists
  local require_ok, conf_opts = pcall(require, "user.lsp.settings." .. server_name)
  if require_ok then
    opts = vim.tbl_deep_extend("force", opts, conf_opts)
  end
  
  lspconfig[server_name].setup(opts)
end

-- Setup ONLY the servers you want - nothing else
setup_server("lua_ls")
setup_server("jsonls") 
setup_server("sqls")

-- Custom pylsp - YOUR version only
local conda_prefix = os.getenv("CONDA_PREFIX")
setup_server("pylsp", {
  cmd = conda_prefix and { conda_prefix .. "/bin/python", "-m", "pylsp" } or 
        { "/home/james/miniconda3/envs/webscraper/bin/python", "-m", "pylsp" },
  settings = {
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
})

-- Custom ruff - single instance with UTF-16 encoding
setup_server("ruff", {
  capabilities = vim.tbl_deep_extend("force", require("user.lsp.handlers").capabilities, {
    general = {
      positionEncodings = { "utf-16" }
    }
  }),
  init_options = {
    settings = {
      lint = { run = "onSave" },
      organizeImports = true,
      fixAll = true,
    }
  }
})

-- Custom julia setup
setup_server("julials", {
  filetypes = {"julia"},
  single_file_support = true,
  root_dir = function(fname)
    return util.find_git_ancestor(fname) or util.path.dirname(fname)
  end,
  settings = {
    julia = {
      symbolCacheDownload = true,
      lint = {
        missingrefs = "all",
        iter = true,
        call = true,
        typePropagation = true
      },
      format = { indent = 4 },
      completionmode = "qualify",
    }
  }
})

-- Custom efm setup
setup_server("efm", {
  init_options = {
    documentFormatting = true,
    documentRangeFormatting = true,
  },
  filetypes = { "dbml", "sql" },
  settings = {
    rootMarkers = { ".git/" },
    languages = {
      dbml = {
        {
          lintCommand = "dbml-validate ${INPUT}",
          lintStdin = false,
          lintFormats = { "%f:%l:%c: %m" },
          lintIgnoreExitCode = true,
        },
      },
    },
  }
})

-- Formatter setup (moved here to avoid duplication)
local formatter_status_ok, formatter = pcall(require, "formatter")
if formatter_status_ok then
  formatter.setup({
    logging = false,
    filetype = {
      python = {
        function()
          return {
            exe = "black",
            args = {"--quiet", "-"},
            stdin = true,
          }
        end,
        function()
          return {
            exe = "isort",
            args = {"--profile", "black", "-"},
            stdin = true,
          }
        end,
      },
      lua = {
        function()
          return {
            exe = "stylua",
            args = {
              "--search-parent-directories",
              "--stdin-filepath",
              vim.api.nvim_buf_get_name(0),
              "--",
              "-",
            },
            stdin = true,
          }
        end,
      },
      json = {
        function()
          return {
            exe = "jq",
            args = {"--indent", "4", "."},
            stdin = true,
          }
        end,
      },
    },
  })

  -- Auto-format on save
  vim.api.nvim_create_augroup("FormatAutogroup", { clear = true })
  vim.api.nvim_create_autocmd("BufWritePost", {
    pattern = "*.py",
    group = "FormatAutogroup",
    callback = function()
      vim.cmd("FormatWrite")
    end,
  })
end
