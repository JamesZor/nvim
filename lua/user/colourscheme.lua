--
-- gruvbox 
vim.o.background = "dark" -- or "light" for light mode
-- setup must be called before loading the colorscheme
-- Default options:
require("gruvbox").setup({
  undercurl = true,
  underline = true,
  bold = true,
  italic = {
    strings = true,
    comments = true,
    operators = false,
    folds = true,
  },
  strikethrough = true,
  invert_selection = false,
  invert_signs = false,
  invert_tabline = false,
  invert_intend_guides = false,
  inverse = true, -- invert background for search, diffs, statuslines and errors
  contrast = "", -- can be "hard", "soft" or empty string
  palette_overrides = {},
  overrides = {},
  dim_inactive = false,
  transparent_mode = false,
})
vim.cmd("colorscheme gruvbox")


-- Add this AFTER your existing gruvbox setup

local function toggle_boox_mode()
  if vim.o.background == 'dark' then
    -- SWITCH TO BOOX / E-INK MODE
    
    -- 1. Switch to Light Mode
    vim.o.background = 'light'
    
    -- 2. Force "Hard" contrast (Pure white/cream background, darker text)
    -- Note: Some Lua implementations require re-running setup, but setting the global often works for hot-swapping
    vim.g.gruvbox_contrast_light = 'hard'
    vim.cmd("colorscheme gruvbox")

    -- 3. DISABLE GHOSTING CULPRITS (Crucial for E-Ink)
    vim.opt.cursorline = false     -- Disable the horizontal line highlighter (stops constant refreshing)
    vim.opt.cursorcolumn = false   -- Disable vertical line if you use it
    vim.opt.signcolumn = "no"      -- Hide the gutter on the left (removes gray sidebar)
    vim.opt.foldcolumn = "0"       -- Hide fold column
    
    print(" 📖 Boox E-Ink Mode Enabled")
  else
    -- SWITCH BACK TO LAPTOP / DARK MODE
    
    -- 1. Revert to Dark
    vim.o.background = 'dark'
    vim.g.gruvbox_contrast_dark = '' -- Reset to default soft/medium
    vim.cmd("colorscheme gruvbox")

    -- 2. Re-enable your preferred UI candy
    vim.opt.cursorline = true
    vim.opt.signcolumn = "auto" -- or "yes"
    
    print(" 💻 Laptop Dark Mode Restored")
  end
end

-- Create a user command so you can type :BooxMode
vim.api.nvim_create_user_command('BooxMode', toggle_boox_mode, {})

-- OPTIONAL: Map it to <Leader>bx (or whatever key you like)
vim.keymap.set('n', '<leader>bx', toggle_boox_mode, { desc = 'Toggle Boox E-ink Mode' })
