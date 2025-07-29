-- lua/user/comment.lua
local comment = require('Comment')

-- Configure Comment.nvim with enhanced Python support
comment.setup({
    mappings = false,  -- Disable default mappings so we can set custom ones
    toggler = {
        line = '<leader>cc',
        block = '<leader>bc',
    },
    opleader = {
        line = '<leader>c',
        block = '<leader>b',
    },
    -- Enable extended support for different filetypes
    pre_hook = function(ctx)
        -- For Python files, ensure proper comment string
        if vim.bo.filetype == 'python' then
            return '# %s'
        end
        return nil
    end,
})

-- Universal keybindings that work across all file types
vim.api.nvim_set_keymap('n', '<C-_>', 'gcc', { noremap = false, silent = true, desc = "Toggle line comment" })
vim.api.nvim_set_keymap('v', '<C-_>', 'gc', { noremap = false, silent = true, desc = "Toggle visual block comment" })

-- Alternative keybindings (some terminals might not recognize Ctrl+/)
vim.api.nvim_set_keymap('n', '<leader>/', 'gcc', { noremap = false, silent = true, desc = "Toggle line comment" })
vim.api.nvim_set_keymap('v', '<leader>/', 'gc', { noremap = false, silent = true, desc = "Toggle visual block comment" })

-- Python-specific enhanced keybindings
vim.api.nvim_create_autocmd("FileType", {
    pattern = "python",
    callback = function()
        local opts = { buffer = true, silent = true }
        
        -- Set Python comment string explicitly
        vim.bo.commentstring = "# %s"
        
        -- Python-specific visual block commenting
        vim.keymap.set('v', '<leader>pc', 'gc', vim.tbl_extend('force', opts, { 
            noremap = false, 
            desc = "Toggle Python comment block" 
        }))
        
        -- Quick visual line commenting for Python
        vim.keymap.set('v', '<leader>pl', function()
            -- Get the visual selection
            local start_line = vim.fn.line("'<")
            local end_line = vim.fn.line("'>")
            
            -- Check if the first line is commented
            local first_line = vim.fn.getline(start_line)
            local is_commented = string.match(first_line, "^%s*#")
            
            if is_commented then
                -- Uncomment: remove "# " from the beginning of each line
                for line_num = start_line, end_line do
                    local line = vim.fn.getline(line_num)
                    local uncommented = string.gsub(line, "^(%s*)# ?", "%1")
                    vim.fn.setline(line_num, uncommented)
                end
            else
                -- Comment: add "# " to the beginning of each line
                for line_num = start_line, end_line do
                    local line = vim.fn.getline(line_num)
                    local commented = string.gsub(line, "^(%s*)", "%1# ")
                    vim.fn.setline(line_num, commented)
                end
            end
        end, vim.tbl_extend('force', opts, { desc = "Toggle Python block comment (custom)" }))
        
        -- Function to toggle comment with proper indentation
        vim.keymap.set('v', '<leader>pt', function()
            vim.cmd("'<,'>Commentary")
        end, vim.tbl_extend('force', opts, { desc = "Toggle Python comment (preserves indentation)" }))
        
    end
})

-- Add filetype-specific commenting for LaTeX (keep your existing LaTeX support)
vim.api.nvim_create_autocmd("FileType", {
    pattern = "tex",
    callback = function()
        vim.bo.commentstring = "% %s"
    end
})

-- Additional helper function for custom comment toggling
local function toggle_visual_comment()
    local start_line = vim.fn.line("'<")
    local end_line = vim.fn.line("'>")
    
    -- Get the filetype to determine comment style
    local ft = vim.bo.filetype
    local comment_char = "#"  -- Default for Python
    
    if ft == "lua" then
        comment_char = "--"
    elseif ft == "tex" then
        comment_char = "%"
    elseif ft == "vim" then
        comment_char = "\""
    end
    
    -- Check if first line is commented
    local first_line = vim.fn.getline(start_line)
    local comment_pattern = "^%s*" .. vim.pesc(comment_char)
    local is_commented = string.match(first_line, comment_pattern)
    
    for line_num = start_line, end_line do
        local line = vim.fn.getline(line_num)
        if is_commented then
            -- Uncomment: remove comment character and optional space
            local uncommented = string.gsub(line, "^(%s*)" .. vim.pesc(comment_char) .. " ?", "%1")
            vim.fn.setline(line_num, uncommented)
        else
            -- Comment: add comment character with space
            local commented = string.gsub(line, "^(%s*)", "%1" .. comment_char .. " ")
            vim.fn.setline(line_num, commented)
        end
    end
end

-- Global visual comment toggle that works for any filetype
vim.keymap.set('v', '<leader>tc', toggle_visual_comment, { 
    silent = true, 
    desc = "Toggle visual block comment (universal)" 
})
