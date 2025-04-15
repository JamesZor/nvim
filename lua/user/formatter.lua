local M = {}

M.setup = function()
  local status_ok, formatter = pcall(require, "formatter")
  if not status_ok then
    return
  end

  formatter.setup({
    logging = false,
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
      lua = {
        -- Use stylua for lua formatting
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
      -- Add more filetypes as needed
    },
  })

  -- Create autocmd group for formatting
  vim.api.nvim_create_augroup("FormatAutogroup", { clear = true })
  
  -- Set up auto-formatting on save for Python files
  vim.api.nvim_create_autocmd("BufWritePost", {
    pattern = "*.py",
    group = "FormatAutogroup",
    callback = function()
      vim.cmd("FormatWrite")
    end,
  })
end

return M
