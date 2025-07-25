-- inlay_hints.lua for Neovim 0.10.0

local M = {}

-- Set up the inlay-hint.nvim plugin if it's available
local function setup_plugin()
  local status_ok, inlay_hint = pcall(require, 'inlay-hint')
  if status_ok then
    inlay_hint.setup({
      -- Position of virtual text. Possible values:
      -- 'eol': right after eol character (default).
      -- 'right_align': display right aligned in the window.
      -- 'inline': display at the specified column, and shift the buffer
      -- text to the right as needed.
      virt_text_pos = 'right_align',
      
      -- Can be supplied either as a string or as an integer,
      -- the latter which can be obtained using |nvim_get_hl_id_by_name()|.
      highlight_group = 'LspInlayHint',
      
      -- Control how highlights are combined with the
      -- highlights of the text.
      -- 'combine': combine with background text color. (default)
      -- 'replace': only show the virt_text color.
      hl_mode = 'combine',
      
      -- Display callback to control how inlay hints are shown
      display_callback = function(line_hints, options, bufnr)
        if options.virt_text_pos == 'inline' then
          local lhint = {}
          for _, hint in pairs(line_hints) do
            local text = ''
            local label = hint.label
            if type(label) == 'string' then
              text = label
            else
              for _, part in ipairs(label) do
                text = text .. part.value
              end
            end
            if hint.paddingLeft then
              text = ' ' .. text
            end
            if hint.paddingRight then
              text = text .. ' '
            end
            lhint[#lhint + 1] = { text = text, col = hint.position.character }
          end
          return lhint
        elseif options.virt_text_pos == 'eol' or options.virt_text_pos == 'right_align' then
          local k1 = {}
          local k2 = {}
          table.sort(line_hints, function(a, b)
            return a.position.character < b.position.character
          end)
          for _, hint in pairs(line_hints) do
            local label = hint.label
            local kind = hint.kind
            local text = ''
            if type(label) == 'string' then
              text = label
            else
              for _, part in ipairs(label) do
                text = text .. part.value
              end
            end
            if kind == 1 then
              k1[#k1 + 1] = text:gsub('^:%s*', '')
            else
              k2[#k2 + 1] = text:gsub(':$', '')
            end
          end
          local text = ''
          if #k2 > 0 then
            text = '<- (' .. table.concat(k2, ',') .. ')'
          end
          if #text > 0 then
            text = text .. ' '
          end
          if #k1 > 0 then
            text = text .. '=> ' .. table.concat(k1, ',')
          end

          return text
        end
        return nil
      end,
    })
    return true
  end
  return false
end

-- Initialize the module
M.setup = function()
  -- Try to set up the plugin
  local plugin_setup = setup_plugin()
  
  -- If plugin setup failed, we can still set up native inlay hints
  if not plugin_setup then
    vim.notify("inlay-hint.nvim plugin not found. Using native inlay hints only.", vim.log.levels.INFO)
  end
end

-- Function to be called on LSP attach
M.on_attach = function(client, bufnr)
  -- Check if the LSP client supports inlay hints
  if client.server_capabilities.inlayHintProvider then
    -- Enable inlay hints
    vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
    
    -- Add a toggle keymap
    vim.keymap.set('n', '<leader>i', function()
      vim.lsp.inlay_hint.enable(
        not vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr }),
        { bufnr = bufnr }
      )
    end, { buffer = bufnr, desc = "Toggle inlay hints" })
    
    vim.notify("Inlay hints enabled for " .. client.name, vim.log.levels.INFO)
  end
end

return M

--local M = {}
--
--M.setup = function()
--  local status_ok, inlay_hint = pcall(require, "inlay-hint")
--  if not status_ok then
--    return
--  end
--
--  inlay_hint.setup({
--    -- Set this to 'right_align' for right-aligned hints
--    virt_text_pos = 'right_align',
--    
--    -- Highlighting options
--    highlight_group = 'LspInlayHint',
--    hl_mode = 'combine',
--    
--    -- The display callback determines how hints are formatted
--    display_callback = function(line_hints, options, bufnr)
--      if options.virt_text_pos == 'inline' then
--        local lhint = {}
--        for _, hint in pairs(line_hints) do
--          local text = ''
--          local label = hint.label
--          if type(label) == 'string' then
--            text = label
--          else
--            for _, part in ipairs(label) do
--              text = text .. part.value
--            end
--          end
--          if hint.paddingLeft then
--            text = ' ' .. text
--          end
--          if hint.paddingRight then
--            text = text .. ' '
--          end
--          lhint[#lhint + 1] = { text = text, col = hint.position.character }
--        end
--        return lhint
--      elseif options.virt_text_pos == 'eol' or options.virt_text_pos == 'right_align' then
--        local k1 = {}
--        local k2 = {}
--        table.sort(line_hints, function(a, b)
--          return a.position.character < b.position.character
--        end)
--        for _, hint in pairs(line_hints) do
--          local label = hint.label
--          local kind = hint.kind
--          local text = ''
--          if type(label) == 'string' then
--            text = label
--          else
--            for _, part in ipairs(label) do
--              text = text .. part.value
--            end
--          end
--          if kind == 1 then
--            k1[#k1 + 1] = text:gsub('^:%s*', '')
--          else
--            k2[#k2 + 1] = text:gsub(':$', '')
--          end
--        end
--        local text = ''
--        if #k2 > 0 then
--          text = '<- (' .. table.concat(k2, ',') .. ')'
--        end
--        if #text > 0 then
--          text = text .. ' '
--        end
--        if #k1 > 0 then
--          text = text .. '=> ' .. table.concat(k1, ',')
--        end
--        return text
--      end
--      return nil
--    end
--  })
--end
--
--M.on_attach = function(client, bufnr)
--  if client.server_capabilities.inlayHintProvider then
--    vim.lsp.inlay_hint.enable(bufnr, {
--      enabled = true,
--      -- Include a basic filter that accepts all hints
--      filter = function(hint)
--        return true
--      end
--    })
--  end
--end
--
--return M
