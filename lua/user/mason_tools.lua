local M = {}

M.setup = function()
  local status_ok, mason_tool_installer = pcall(require, "mason-tool-installer")
  if not status_ok then
    return
  end

  -- Define tools to be installed
  local tools = {
    -- Python tools
    'mypy',        -- Static type checker
    'black',       -- Code formatter
    'isort',       -- Import sorter
    'debugpy',     -- Debug adapter for nvim-dap
    'ruff',        -- Fast Python linter

    'julia-lsp', -- julia tool 

    -- Lua tools
    'stylua',      -- Lua formatter
    
    -- JSON tools
    'jq',          -- JSON processor/formatter
    
    -- General tools
    'shellcheck',  -- Shell script linter

    'efm', -- dbml
  }

  mason_tool_installer.setup({
    ensure_installed = tools,
    auto_update = true,
    run_on_start = true,
    start_delay = 3000, -- 3 second delay
    debounce_hours = 24, -- Only check for updates once per day
  })
  
  -- Set up an event to notify when tools are installed
  vim.api.nvim_create_autocmd('User', {
    pattern = 'MasonToolsUpdateCompleted',
    callback = function(e)
      vim.schedule(function()
        if e.data then
          for _, tool_name in ipairs(e.data) do
            vim.notify(tool_name .. " has been installed/updated", vim.log.levels.INFO)
          end
        end
      end)
    end,
  })
end

return M
