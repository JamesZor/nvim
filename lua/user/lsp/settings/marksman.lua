return {
  -- Add any marksman-specific settings here
  cmd = { "marksman", "server" },
  filetypes = { "markdown" },
  root_dir = require("lspconfig/util").find_git_ancestor,
  single_file_support = true
}
