--local null_ls_status_ok, null_ls = pcall(require, "null-ls")
--if not null_ls_status_ok then
--	return
--end
--
---- https://github.com/jose-elias-alvarez/null-ls.nvim/tree/main/lua/null-ls/builtins/formatting
--local formatting = null_ls.builtins.formatting
---- https://github.com/jose-elias-alvarez/null-ls.nvim/tree/main/lua/null-ls/builtins/diagnostics
--local diagnostics = null_ls.builtins.diagnostics
--
--null_ls.setup({
--	debug = false,
--	sources = {
--		formatting.prettier.with({ extra_args = { "--no-semi", "--single-quote", "--jsx-single-quote" } }),
--		formatting.black.with({ extra_args = { "--fast" } }),
--		formatting.stylua,
--    -- diagnostics.flake8
--	},
--})

local null_ls_status_ok, null_ls = pcall(require, "null-ls")
if not null_ls_status_ok then
	return
end

-- https://github.com/jose-elias-alvarez/null-ls.nvim/tree/main/lua/null-ls/builtins/formatting
local formatting = null_ls.builtins.formatting
-- https://github.com/jose-elias-alvarez/null-ls.nvim/tree/main/lua/null-ls/builtins/diagnostics
local diagnostics = null_ls.builtins.diagnostics
local helpers = require("null-ls.helpers")

-- Custom source for DBML validation
local dbml_validate = {
  name = "dbml-validate",
  method = null_ls.methods.DIAGNOSTICS,
  filetypes = { "dbml" },
  generator = helpers.make_command_generator({
    command = "dbml-validate",
    args = { "$FILENAME" },
    format = "line",
    check_exit_code = function(code)
      return code <= 1  -- 0 = success, 1 = validation errors
    end,
    on_output = function(line, params)
      -- Sample output: "Syntax error at line 10 column 15. References with same endpoints exist"
      local row, col, message = line:match("line (%d+) column (%d+)%. (.+)")
      
      if row and col and message then
        return {
          row = tonumber(row),
          col = tonumber(col),
          message = message,
          severity = helpers.diagnostics.severities["error"],
        }
      end
    end,
  }),
}

-- Add command for converting SQL to DBML
local sql_to_dbml = {
  name = "sql2dbml",
  method = null_ls.methods.FORMATTING,
  filetypes = { "sql" },
  generator = helpers.make_command_generator({
    command = "sql2dbml",
    args = { "--postgres", "-" }, -- stdin/stdout mode
    to_stdin = true,
  }),
}

-- Add command for converting DBML to SQL
local dbml_to_sql = {
  name = "dbml2sql",
  method = null_ls.methods.FORMATTING,
  filetypes = { "dbml" },
  generator = helpers.make_command_generator({
    command = "dbml2sql",
    args = { "--postgres", "-" }, -- stdin/stdout mode
    to_stdin = true,
  }),
}

null_ls.setup({
	debug = false,
	sources = {
		formatting.prettier.with({ extra_args = { "--no-semi", "--single-quote", "--jsx-single-quote" } }),
		formatting.black.with({ extra_args = { "--fast" } }),
		formatting.stylua,
		-- diagnostics.flake8,
		
		-- DBML support
		dbml_validate,
		-- Uncomment these if you want format-on-save to convert between SQL and DBML
		-- Note: usually you want these as explicit commands rather than auto-formatting
		-- sql_to_dbml,
		-- dbml_to_sql,
	},
})
