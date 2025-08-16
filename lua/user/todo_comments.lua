-- lua/user/todo_comments.lua
local status_ok, todo_comments = pcall(require, "todo-comments")
if not status_ok then
  return
end

todo_comments.setup {
  signs = true,
  sign_priority = 8,
  keywords = {
    FIX = {
      icon = " ",
      color = "error",
      alt = { "FIXME", "BUG", "FIXIT", "ISSUE" },
    },
    TODO = { icon = " ", color = "info" },
    HACK = { icon = " ", color = "hack" },
    WARN = { icon = " ", color = "warning", alt = { "WARNING", "XXX" } },
    PERF = { icon = " ", color = "perf", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
    NOTE = { icon = " ", color = "hint", alt = { "INFO" } },
    TEST = { icon = "⏲ ", color = "default", alt = { "TESTING", "PASSED", "FAILED" } },
    -- Add your custom keywords here
    REVIEW = { icon = " ", color = "review" },
    QUESTION = { icon = " ", color = "question", alt = { "Q" } },
  },
  gui_style = {
    fg = "NONE",
    bg = "BOLD",
  },
  merge_keywords = true,
  highlight = {
    multiline = true,
    multiline_pattern = "^.",
    multiline_context = 10,
    before = "",
    keyword = "wide",
    after = "fg",
    pattern = [[.*<(KEYWORDS)\s*:]],
    comments_only = true,
    max_line_len = 400,
    exclude = {},
  },
  colors = {
  error = { "DiagnosticError", "ErrorMsg", "#DC2626" },      -- Red
  warning = { "DiagnosticWarn", "WarningMsg", "#FBBF24" },   -- Yellow
  info = { "DiagnosticInfo", "#2563EB" },                    -- Blue
  hint = { "DiagnosticHint", "#10B981" },                    -- Green
  default = { "Identifier", "#7C3AED" },                     -- Purple
  test = { "Identifier", "#FF00FF" },                        -- Magenta
  -- Custom colors for distinct keywords
  hack = { "Number", "#FB923C" },                            -- Orange
  perf = { "Statement", "#8B5CF6" },                         -- Violet
  review = { "Function", "#06B6D4" },                        -- Cyan
  question = { "String", "#EC4899" },                        -- Pink
  },
  search = {
    command = "rg",
    args = {
      "--color=never",
      "--no-heading",
      "--with-filename",
      "--line-number",
      "--column",
      "--glob=!docs/",           -- Exclude docs directory
      "--glob=!*.md",            -- Exclude all markdown files
      "--glob=!{docs,notes}/**", -- Exclude multiple directories
    },
    pattern = [[\b(KEYWORDS):]],
  },
}
