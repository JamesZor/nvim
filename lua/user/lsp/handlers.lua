local M = {}

-- TODO: backfill this to template
M.setup = function()
  local signs = {
    { name = "DiagnosticSignError", text = "" },
    { name = "DiagnosticSignWarn", text = "" },
    { name = "DiagnosticSignHint", text = "" },
    { name = "DiagnosticSignInfo", text = "" },
  }

  for _, sign in ipairs(signs) do
    vim.fn.sign_define(sign.name, { texthl = sign.name, text = sign.text, numhl = "" })
  end

  local config = {
    -- disable virtual text
    virtual_text = true,
    -- show signs
    signs = {
      active = signs,
    },
    update_in_insert = true,
    underline = true,
    severity_sort = true,
    float = {
      focusable = false,
      style = "minimal",
      border = "rounded",
      source = "always",
      header = "",
      prefix = "",
    },
  }

  vim.diagnostic.config(config)

  vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
    border = "rounded",
    width = 60,
  })

  vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
    border = "rounded",
    width = 60,
  })
  vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
    border = "rounded",
  })

--     vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
--     border = "rounded",
--   })
--  vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
--    border = "rounded",
--    -- Add these settings to make signature help more persistent
--    focusable = true,      -- Allow focusing the floating window
--    close_events = {},     -- Don't automatically close the window
--    auto_close = false,    -- Don't automatically close the signature window
--    update_on_insert = true, -- Update the signature help on insertion
--  })
end



local function lsp_highlight_document(client)
  if client.server_capabilities.documentHighlightProvider then
    vim.api.nvim_create_augroup("lsp_document_highlight", { clear = true })
    vim.api.nvim_create_autocmd("CursorHold", {
      group = "lsp_document_highlight",
      pattern = "<buffer>",
      callback = vim.lsp.buf.document_highlight,
    })
    vim.api.nvim_create_autocmd("CursorMoved", {
      group = "lsp_document_highlight",
      pattern = "<buffer>",
      callback = vim.lsp.buf.clear_references,
    })
  end
end

local function lsp_keymaps(bufnr)
  local opts = { noremap = true, silent = true }
  
  -- Check if lspsaga is available
  local has_lspsaga = pcall(require, "lspsaga")
  
  if has_lspsaga then
    -- If lspsaga is available, use its keymaps
    local lspsaga_setup = require("user.lspsaga")
    lspsaga_setup.set_keymaps(bufnr)
  else
    -- Otherwise use standard LSP keymaps
    vim.api.nvim_buf_set_keymap(bufnr, "n", "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>", opts)
    vim.api.nvim_buf_set_keymap(bufnr, "n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", opts)
    vim.api.nvim_buf_set_keymap(bufnr, "n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", opts)
    vim.api.nvim_buf_set_keymap(bufnr, "n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", opts)
    vim.api.nvim_buf_set_keymap(bufnr, "n", "<C-k>", "<cmd>lua vim.lsp.buf.signature_help()<CR>", opts)
    vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>rn", "<cmd>lua vim.lsp.buf.rename()<CR>", opts)
    vim.api.nvim_buf_set_keymap(bufnr, "n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>", opts)
    vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>ca", "<cmd>lua vim.lsp.buf.code_action()<CR>", opts)
  end
  
  -- Common keymaps regardless of lspsaga
  vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>df", "<cmd>lua vim.diagnostic.open_float()<CR>", opts)
  vim.api.nvim_buf_set_keymap(bufnr, "n", "[d", '<cmd>lua vim.diagnostic.goto_prev({ border = "rounded" })<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, "n", "]d", '<cmd>lua vim.diagnostic.goto_next({ border = "rounded" })<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>q", "<cmd>lua vim.diagnostic.setloclist()<CR>", opts)
  
  vim.cmd [[ command! Format execute 'lua vim.lsp.buf.format({ async = true })' ]]
end

-- This function attaches all the necessary handlers when an LSP connects
M.on_attach = function(client, bufnr)
  -- Attach lsp_signature
  local signature_ok, _ = pcall(require, "user.lsp_signature")
  if signature_ok then
    require("user.lsp_signature").on_attach(client, bufnr)
  end
  
  -- Attach inlay_hints
  local inlay_hints_ok, _ = pcall(require, "user.inlay_hints")
  if inlay_hints_ok then
    require("user.inlay_hints").on_attach(client, bufnr)
  end
  
  -- If formatting is handled by null-ls or formatter.nvim, disable it in the LSP
  if client.name == "pyright" or client.name == "pylsp" or client.name == "ruff_lsp" then
    client.server_capabilities.documentFormattingProvider = false
    client.server_capabilities.documentRangeFormattingProvider = false
  end
  
  lsp_keymaps(bufnr)
  lsp_highlight_document(client)
end

-- capabilities setup for LSP and nvim-cmp integration
local capabilities = vim.lsp.protocol.make_client_capabilities()

-- Set up inlay hints support (for newer LSP servers that support it)
capabilities.textDocument.inlayHint = {
  dynamicRegistration = true,
}

-- If available, use cmp_nvim_lsp for enhanced capabilities
local status_ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
if status_ok then
  M.capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
else
  M.capabilities = capabilities
end

return M

--local function lsp_highlight_document(client)
--  -- Set autocommands conditional on server_capabilities
--  if client.server_capabilities.documentHighlight then
--    vim.api.nvim_exec(
--      [[
--      augroup lsp_document_highlight
--        autocmd! * <buffer>
--        autocmd CursorHold <buffer> lua vim.lsp.buf.document_highlight()
--        autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()
--      augroup END
--    ]],
--      false
--    )
--  end
--end
--
--local function lsp_keymaps(bufnr)
--  local opts = { noremap = true, silent = true }
--  vim.api.nvim_buf_set_keymap(bufnr, "n", "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>", opts)
--  vim.api.nvim_buf_set_keymap(bufnr, "n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", opts)
--  vim.api.nvim_buf_set_keymap(bufnr, "n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", opts)
--  vim.api.nvim_buf_set_keymap(bufnr, "n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", opts)
--  vim.api.nvim_buf_set_keymap(bufnr, "n", "<C-k>", "<cmd>lua vim.lsp.buf.signature_help()<CR>", opts)
--  -- vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>rn", "<cmd>lua vim.lsp.buf.rename()<CR>", opts)
--  vim.api.nvim_buf_set_keymap(bufnr, "n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>", opts)
--  -- vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>ca", "<cmd>lua vim.lsp.buf.code_action()<CR>", opts)
--  -- vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>f", "<cmd>lua vim.diagnostic.open_float()<CR>", opts)
--  vim.api.nvim_buf_set_keymap(bufnr, "n", "[d", '<cmd>lua vim.diagnostic.goto_prev({ border = "rounded" })<CR>', opts)
--  vim.api.nvim_buf_set_keymap(
--    bufnr,
--    "n",
--    "gl",
--    '<cmd>lua vim.diagnostic.open_float()<CR>',
--    opts
--  )
--  vim.api.nvim_buf_set_keymap(bufnr, "n", "]d", '<cmd>lua vim.diagnostic.goto_next({ border = "rounded" })<CR>', opts)
--  vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>q", "<cmd>lua vim.diagnostic.setloclist()<CR>", opts)
--  vim.cmd [[ command! Format execute 'lua vim.lsp.buf.formatting()' ]]
--end
--
--M.on_attach = function(client, bufnr)
--  if client.name == "tsserver" then
--    client.server_capabilities.documentFormattingProvider = false
--  end
--  lsp_keymaps(bufnr)
--  lsp_highlight_document(client)
--end
--
--local status_ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
--if status_ok then
--  M.capabilities = cmp_nvim_lsp.default_capabilities()
--end
--
--return M
