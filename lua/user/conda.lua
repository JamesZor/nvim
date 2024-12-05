local util = require('lspconfig/util')

require('lspconfig').pyright.setup{
  on_attach = on_attach,  -- Assuming you have an on_attach function defined
  settings = {
    python = {
      analysis = {
        autoSearchPaths = true,
        useLibraryCodeForTypes = true,
        diagnosticMode = "workspace"
      }
    }
  },
  before_init = function(_, config)
    config.settings.python.pythonPath = util.path.join(vim.env.CONDA_PREFIX, "bin", "python")
  end,
}
