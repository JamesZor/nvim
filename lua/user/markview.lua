-- lua/user/markview.lua
local M = {}

function M.setup()
  local status_ok, markview = pcall(require, "markview")
  if not status_ok then
    vim.notify("markview.nvim plugin not found.", vim.log.levels.WARN)
    return
  end

  markview.setup({
    -- General plugin settings
    enabled = true,
    throttle = 25,

    -- All markdown-specific rendering options are now under this table
    markdown = {
      -- Use nvim-treesitter for syntax highlighting in code blocks
      code_blocks = {
        enable = true,
        icon_provider = "nvim-web-devicons",
      },

      -- Enable rendering of inline images for your plots
      images = {
        enable = true,
        backend = "image.nvim",
      },

      -- Improve heading display for better document structure
      headings = {
        enable = true,
        style = "pipe",
      },

      -- Enhance the display of LaTeX math equations
      math = {
        enable = true,
        backend = "native",
      },
    },

    -- Keymaps remain at the top level
    keymaps = {
      ["<leader>mt"] = {
        action = "toggle",
        opts = { desc = "Toggle Markview rendering" },
      },
      ["<leader>me"] = {
        action = "toggle_one",
        opts = { desc = "Toggle rendering for current element" },
      },
    },
  })
end

return M
