local util = require('lspconfig/util')

local function get_python_path(workspace)
    -- Try to find a virtual environment in the workspace
    local venv_path = util.path.join(workspace, 'venv', 'bin', 'python')
    if vim.fn.executable(venv_path) == 1 then
        return venv_path
    end
    
    venv_path = util.path.join(workspace, '.venv', 'bin', 'python')
    if vim.fn.executable(venv_path) == 1 then
        return venv_path
    end
    
    -- Check if we're in a Conda environment
    local conda_prefix = os.getenv("CONDA_PREFIX")
    if conda_prefix then
        return util.path.join(conda_prefix, 'bin', 'python')
    end
    
    -- Fall back to system Python
    return vim.fn.exepath("python3") or vim.fn.exepath("python") or "python"
end

return {
    on_init = function(client)
        client.config.settings.python.pythonPath = get_python_path(client.config.root_dir)
    end,
    settings = {
        python = {
            analysis = {
                typeCheckingMode = "on",
                autoSearchPaths = true,
                useLibraryCodeForTypes = true,
                diagnosticMode = "workspace"
            }
        }
    },
    root_dir = function(fname)
        return util.root_pattern("pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", "Pipfile")(fname) or util.path.dirname(fname)
    end
}
