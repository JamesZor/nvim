--local status_ok, _ = pcall(require, "lspconfig")
--if not status_ok then
--  return
--end
--
--require("user.lsp.mason")
--require("user.lsp.handlers").setup()
----require ("user.lsp.null-ls")
--
local status_ok, _ = pcall(require, "lspconfig")
if not status_ok then
  return
end

-- First set up basic LSP handlers
require("user.lsp.handlers").setup()

-- Load Mason and language servers
require("user.lsp.mason")

-- Set up all plugins that enhance the LSP experience

-- Set up Mason tools installer if available
local mason_tools_ok, _ = pcall(require, "user.mason_tools")
if mason_tools_ok then
  require("user.mason_tools").setup()
end

-- Set up LSP signature help if available
local lsp_signature_ok, _ = pcall(require, "user.lsp_signature")
if lsp_signature_ok then
  require("user.lsp_signature").setup()
end

-- Set up inlay hints if available
--local inlay_hints_ok, _ = pcall(require, "user.inlay_hints")
--if inlay_hints_ok then
--  require("user.inlay_hints").setup()
--end

-- Set up LSP Saga if available
local lspsaga_ok, _ = pcall(require, "user.lspsaga")
if lspsaga_ok then
  require("user.lspsaga").setup()
end

-- Set up formatter if available
local formatter_ok, _ = pcall(require, "user.formatter")
if formatter_ok then
  require("user.formatter").setup()
end

-- Set up null-ls (commented out in your original file)
-- require ("user.lsp.null-ls")
