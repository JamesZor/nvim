
local status_ok, _ = pcall(require, "lspconfig")
if not status_ok then
  return
end

require("user.lsp.handlers").setup()
require("user.lsp.mason")  -- This now includes formatter setup

-- Keep lspsaga if you want
local lspsaga_ok, _ = pcall(require, "user.lspsaga")
if lspsaga_ok then
  require("user.lspsaga").setup()
end
