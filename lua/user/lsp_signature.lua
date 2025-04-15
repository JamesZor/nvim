local M = {}

M.setup = function()
  local status_ok, signature = pcall(require, "lsp_signature")
  if not status_ok then
    return
  end

  signature.setup({
    bind = true,
    handler_opts = {
      border = "rounded",
    },
    floating_window = true,
    hint_enable = true,
    hint_prefix = "🔍 ",
    hint_scheme = "String",
    hi_parameter = "Search",
    max_height = 12,
    max_width = 120,
    always_trigger = false, -- Show signature on new line when function is called
    auto_close_after = nil, -- Close floating window after this many ms if cursor doesn't move
    extra_trigger_chars = {}, -- Array of extra characters that will trigger signature completion
    zindex = 200, -- Z-index of the completion popup
    padding = '', -- Character to pad on the left of signature
    transparency = nil, -- Extra opacity for the floating window (0-100)
    shadow_blend = 36, -- Shadow blend value
    shadow_guibg = 'Black', -- Shadow background color
    timer_interval = 200, -- Default timer check interval
    toggle_key = nil, -- Toggle signature key binding
    doc_lines = 10, -- How many lines to show in the documentation
    floating_window_above_cur_line = true, -- Try to place the floating above the current line
    
    -- Python-specific settings
    select_signature_key = nil, -- key for cycling through signatures if multiple are detected
    move_cursor_key = nil, -- key for moving cursor between args if multiple args
  })
end

-- Function to attach to LSP server (will be called in handlers.lua)
M.on_attach = function(client, bufnr)
  local status_ok, signature = pcall(require, "lsp_signature")
  if not status_ok then
    return
  end
  
  signature.on_attach({
    bind = true,
    handler_opts = {
      border = "rounded"
    },
    hint_enable = true,
    floating_window = true,
  }, bufnr)
end

return M
