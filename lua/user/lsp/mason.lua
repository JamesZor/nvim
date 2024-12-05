local util = require('lspconfig/util')

local servers = {
  "lua_ls",
  "pyright",
  "jsonls",
  "texlab",
  "sqlls",
  "matlab_ls",
  "julials",
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
require("mason").setup(settings)
require("mason-lspconfig").setup({
  ensure_installed = servers,
  automatic_installation = true,
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
    opts.before_init = function(_, config)
      config.settings.python.pythonPath = util.path.join(vim.env.CONDA_PREFIX, "bin", "python")
    end
    opts.settings = {
      python = {
        analysis = {
          autoSearchPaths = true,
          useLibraryCodeForTypes = true,
          diagnosticMode = "workspace"
        }
      }
    }
  elseif server == "matlab_ls" then
    opts.filetypes = {"matlab"}
    opts.settings = {
      matlab = {
        installPath = "/home/james/matlab/r2024/"  -- Update this path to your MATLAB installation
      }
    }
    opts.single_file_support = true
  elseif server == "julials" then
    opts.filetypes = {"julia"}
    opts.on_new_config = function(new_config, _)
      local julia = vim.fn.expand("~/.julia/environments/nvim-lspconfig/bin/julia")
      if util.path.is_file(julia) then
        new_config.cmd[1] = julia
      end
    end
    opts.settings = {
      julia = {
        format = {
          indent = 2  -- Number of spaces for indentation
        }
      }
    }
    opts.single_file_support = true
    opts.root_dir = util.find_git_ancestor
  end
  
  local require_ok, conf_opts = pcall(require, "user.lsp.settings." .. server)
  if require_ok then
    opts = vim.tbl_deep_extend("force", conf_opts, opts)
  end
  
  lspconfig[server].setup(opts)
end
