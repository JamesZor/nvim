local configs = require("nvim-treesitter.configs")
require("nvim-treesitter.install").prefer_git = true

configs.setup {
  ensure_installed = {}, -- Start with no parsers to avoid errors
  sync_install = false, 
  auto_install = false, -- Disable auto-install to prevent unexpected behavior
  
  highlight = {
    enable = true,
    disable = function(lang, buf)
      -- Disable for large files to improve performance
      local max_filesize = 100 * 1024 -- 100 KB
      local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
      if ok and stats and stats.size > max_filesize then
        return true
      end
      
      -- Create a safe list of languages that work reliably
      local safe_langs = {
        "lua", "vim", "vimdoc", "python", "bash","sql", "dbml"
      }
      
      local is_safe = false
      for _, safe_lang in ipairs(safe_langs) do
        if safe_lang == lang then
          is_safe = true
          break
        end
      end
      
      -- Only enable highlighting for languages we know work well
      return not is_safe
    end,
    
    additional_vim_regex_highlighting = false,
  },
  
  indent = { 
    enable = false, -- Disable indentation initially
  },

  rainbow = {
    enable = false, -- Disable rainbow initially
  }
}

-- Add error recovery
vim.api.nvim_create_autocmd("BufEnter", {
  callback = function()
    local buf = vim.api.nvim_get_current_buf()
    -- Use pcall to safely attempt highlighting
    pcall(function()
      if vim.treesitter.highlighter.active[buf] then
        return
      end
      
      local ft = vim.bo[buf].filetype
      -- Only try to highlight for known good filetypes
      local safe_filetypes = {
        "lua", "python", "sh", "bash", "vim"
      }
      
      for _, safe_ft in ipairs(safe_filetypes) do
        if safe_ft == ft then
          vim.cmd("TSBufEnable highlight")
          break
        end
      end
    end)
  end,
  group = vim.api.nvim_create_augroup("SafeTreesitterInit", { clear = true })
})

-- Add command to safely toggle highlighting
vim.api.nvim_create_user_command("TSToggleSafe", function()
  pcall(function()
    vim.cmd("TSBufToggle highlight")
  end)
end, {})
