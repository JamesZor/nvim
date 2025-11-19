--
-- local status_ok, _ = pcall(require, "lspconfig")
-- if not status_ok then
--   return
-- end
--
-- require("user.lsp.handlers").setup()
-- require("user.lsp.mason")  -- This now includes formatter setup
--
-- -- Keep lspsaga if you want
-- local lspsaga_ok, _ = pcall(require, "user.lspsaga")
-- if lspsaga_ok then
--   require("user.lspsaga").setup()
-- end
--

local status_ok, _ = pcall(require, "lspconfig")
if not status_ok then
  return
end

require("user.lsp.handlers").setup()
require("user.lsp.mason")

local lspsaga_ok, _ = pcall(require, "user.lspsaga")
if lspsaga_ok then
  require("user.lspsaga").setup()
end

--------------------------------------------------------------------------------
-- JULIA SETUP (Based on the 'aris' solution you found)
--------------------------------------------------------------------------------
-- This uses the native vim.lsp.config as required by Neovim 0.11
-- and manually bootstraps the server code to avoid the "executable" error.

vim.lsp.config('julials', {
    cmd = {
        "julia",
        -- We use the environment we created: ~/.julia/environments/nvim-lsp
        "--project=" .. vim.fn.expand("~/.julia/environments/nvim-lsp"),
        "--startup-file=no",
        "--history-file=no",
        "-e", [[
            using Pkg
            Pkg.instantiate()
            using LanguageServer
            
            depot_path = get(ENV, "JULIA_DEPOT_PATH", "")
            project_path = let
                dirname(something(
                    ## 1. Finds an explicitly set project (JULIA_PROJECT)
                    Base.load_path_expand((
                        p = get(ENV, "JULIA_PROJECT", nothing);
                        p === nothing ? nothing : isempty(p) ? nothing : p
                    )),
                    ## 2. Look for a Project.toml file in the current working directory,
                    ##    or parent directories, with $HOME as an upper boundary
                    Base.current_project(),
                    ## 3. First entry in the load path
                    get(Base.load_path(), 1, nothing),
                    ## 4. Fallback to default global environment,
                    ##    this is more or less unreachable
                    Base.load_path_expand("@v#.#"),
                ))
            end
            
            @info "Running language server" VERSION pwd() project_path depot_path
            server = LanguageServer.LanguageServerInstance(stdin, stdout, project_path, depot_path)
            server.runlinter = true
            run(server)
        ]]
    },
    filetypes = { 'julia' },
    root_markers = { "Project.toml", "JuliaProject.toml", ".git" },
    -- Add the handlers you defined elsewhere so keymaps work
    on_attach = require("user.lsp.handlers").on_attach,
    capabilities = require("user.lsp.handlers").capabilities,
})

-- Enable the server
vim.lsp.enable('julials')
