-- This file now handles Mason, tool installation, AND lspconfig setup

local util = require('lspconfig/util')

-- 1. Setup Mason
require("mason").setup({
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
})

-- 2. Setup Mason Tool Installer
-- These are the tools Mason will ensure are installed
local tools = {
  'mypy',
  'black', 
  'isort',
  'debugpy',
  'stylua',
  'jq',
  'shellcheck',
  -- LSP Servers
  'lua-language-server',
  'python-lsp-server', 
  'ruff',
  'json-lsp',
  'sqls',
  -- 'julia-lsp',
  'efm',
}

require("mason-tool-installer").setup({
  ensure_installed = tools,
  auto_update = true,
  run_on_start = true,
})

-- 3. Setup Mason-LSPConfig
-- This is the bridge that connects Mason-installed servers with nvim-lspconfig
local lspconfig_status_ok, lspconfig = pcall(require, "lspconfig")
if not lspconfig_status_ok then
  return
end

local on_attach = require("user.lsp.handlers").on_attach
local capabilities = require("user.lsp.handlers").capabilities

-- This setup function will automatically call vim.lsp.config() and vim.lsp.enable()
-- for every server you install with Mason.
require("mason-lspconfig").setup({
  -- **THE FIX IS HERE:**
  -- This tells mason-lspconfig NOT to set up any servers automatically.
  -- We will handle all setup inside the 'handlers' block.
  automatic_installation = false,
  
  -- This function is called for each server before it's configured
  -- We use it to merge your default handlers and custom settings
  handlers = {
    -- The default handler for all servers
    function(server_name)
      local opts = {
        on_attach = on_attach,
        capabilities = capabilities,
      }
      
      -- Get and merge server-specific settings
      local require_ok, custom_opts = pcall(require, "user.lsp.settings." .. server_name)
      if require_ok then
        opts = vim.tbl_deep_extend("force", opts, custom_opts or {})
      end

      -- Apply consistent position encoding
      if opts.capabilities and opts.capabilities.general then
        opts.capabilities.general.positionEncodings = { "utf-16" }
      end

      -- Finally, configure the server
      vim.lsp.config(server_name, opts)
      vim.lsp.enable({server_name})
    end,

    -- Custom setup for pylsp (merges with defaults)
    ["pylsp"] = function()
      local conda_prefix = os.getenv("CONDA_PREFIX")
      local project_pylsp = conda_prefix and (conda_prefix .. "/bin/python")
      
      local pylsp_cmd
      -- Check if the conda env python exists and has pylsp
      if project_pylsp and vim.fn.executable(project_pylsp) == 1 then
        pylsp_cmd = { project_pylsp, "-m", "pylsp" }
      else
        -- Fallback to Mason-installed pylsp
        local mason_paths = require("mason-paths")
        pylsp_cmd = { mason_paths.get_package_path("python-lsp-server") .. "/venv/bin/python", "-m", "pylsp" }
      end

      local opts = {
        on_attach = on_attach,
        capabilities = capabilities,
        cmd = pylsp_cmd,
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
              pylsp_mypy = { 
                enabled = true,
                live_mode = true,
                strict = false,
                overrides = {
                  "--no-warn-no-return",
                  "--check-untyped-defs",
                  "--warn-unused-ignores",
                  "--warn-redundant-casts",
                  "--warn-return-any",
                  "--warn-unreachable",
                  "--strict-equality",
                  "--extra-checks",
                  "--follow-imports=normal",
                  "--namespace-packages",
                true}
              },
              jedi_completion = { enabled = true, fuzzy = true, include_params_in_completion = true, include_class_objects = true, include_function_objects = true },
              jedi_hover = { enabled = true },
              jedi_references = { enabled = true },
              jedi_signature_help = { enabled = true },
              jedi_symbols = { enabled = true, all_scopes = true },
            }
          }
        }
      }
      
      vim.lsp.config("pylsp", opts)
      vim.lsp.enable({"pylsp"})
    end,
    
    -- Custom setup for ruff_lsp (merges with defaults)
    -- Note: mason-lspconfig uses the lspconfig server name ('ruff_lsp') as the keymaps
      ["ruff_lsp"] = function()
        local opts = {
          on_attach = on_attach,
          capabilities = capabilities, -- <-- This line is the only change
          general = { positionEncodings = { "utf-16"}},
          init_options = {
            settings = {
              lint = { run = "onSave" },
              organizeImports = true,
              fixAll = true,
            }
          }
        }
        vim.lsp.config("ruff_lsp", opts)
        vim.lsp.enable({ "ruff_lsp" })
      end,

    -- Custom setup for julials (merges with defaults)
    -- ["julials"] = function()
    --    local opts = {
    --     on_attach = on_attach,
    --     capabilities = capabilities,
    --     filetypes = {"julia"},
    --     single_file_support = true,
    --     root_dir = function(fname)
    --       return util.find_git_ancestor(fname) or util.path.dirname(fname)
    --     end,
    --     settings = {
    --       julia = {
    --         symbolCacheDownload = true,
    --         lint = { missingrefs = "all", iter = true, call = true, typePropagation = true },
    --         format = { indent = 4 },
    --         completionmode = "qualify",
    --       }
    --     }
    --   }
    --   vim.lsp.config("julials", opts)
    --   vim.lsp.enable({"julials"})
    -- end,
    
    -- Custom setup for efm (merges with defaults)
    ["efm"] = function()
      local opts = {
        on_attach = on_attach,
        capabilities = capabilities,
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
      }
      vim.lsp.config("efm", opts)
      vim.lsp.enable({"efm"})
    end,

    -- Add handlers for lua_ls, jsonls, sqls, and bashls
    -- These will use the default handler logic
    ["lua_ls"] = function()
      vim.lsp.config("lua_ls", {
        on_attach = on_attach,
        capabilities = capabilities,
        settings = {
          Lua = {
            diagnostics = { globals = { "vim" } },
            workspace = { library = { vim.fn.expand("$VIMRUNTIME/lua") } }
          }
        }
      })
      vim.lsp.enable({"lua_ls"})
    end,

    ["jsonls"] = function()
      vim.lsp.config("jsonls", { on_attach = on_attach, capabilities = capabilities })
      vim.lsp.enable({"jsonls"})
    end,

    ["sqls"] = function()
      vim.lsp.config("sqls", { on_attach = on_attach, capabilities = capabilities })
      vim.lsp.enable({"sqls"})
    end,

    ["bashls"] = function()
      vim.lsp.config("bashls", { on_attach = on_attach, capabilities = capabilities })
      vim.lsp.enable({"bashls"})
    end,
  },
})

-- 4. Setup Formatter (from your old mason.lua)
-- This is separate from LSP
local formatter_status_ok, formatter = pcall(require, "formatter")
if formatter_status_ok then
  formatter.setup({
    logging = false,
    filetype = {
      python = {
        function() return { exe = "black", args = {"--quiet", "-"}, stdin = true } end,
        function() return { exe = "isort", args = {"--profile", "black", "-"}, stdin = true } end,
      },
      lua = {
        function()
          return {
            exe = "stylua",
            args = { "--search-parent-directories", "--stdin-filepath", vim.api.nvim_buf_get_name(0), "--", "-", },
            stdin = true,
          }
        end,
      },
      json = {
        function() return { exe = "jq", args = {"--indent", "4", "."}, stdin = true } end,
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

-- 5. Diagnostic configuration (from your old mason.lua)
vim.diagnostic.config({
  update_in_insert = false,
  underline = true,
  virtual_text = { spacing = 4 },
  severity_sort = true,
})
