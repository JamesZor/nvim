local opts = {}

opts.cmd = { vim.fn.stdpath("data") .. "/mason/bin/sqls", "-config", vim.fn.expand("~/.config/sqls/config.yml") }
opts.filetypes = { "sql" }
opts.root_dir = function()
  return "/home/james/projects/cs50_sql"
end

return opts

