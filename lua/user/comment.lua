-- Add this near the top of the file with your other requires
local comment = require('Comment')

-- Configure Comment.nvim for LaTeX files
comment.setup({
    mappings = false,  -- Disable default mappings
    toggler = {
        line = '<leader>cc',
        block = '<leader>bc',
    },
    opleader = {
        line = '<leader>c',
        block = '<leader>b',
    },
})

-- Add custom keybinding for Ctrl+/
vim.api.nvim_set_keymap('n', '<C-_>', 'gcc', { noremap = false, silent = true })
vim.api.nvim_set_keymap('v', '<C-_>', 'gc', { noremap = false, silent = true })

-- Add filetype-specific commenting for LaTeX
vim.api.nvim_create_autocmd("FileType", {
    pattern = "tex",
    callback = function()
        vim.bo.commentstring = "% %s"
    end
})
