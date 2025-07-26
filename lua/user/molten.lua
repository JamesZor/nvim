local M = {}

local function setup_options()
    -- Basic options
    vim.g.molten_image_provider = "image.nvim"  -- This connects molten with image.nvim
    vim.g.molten_output_win_max_height = 40
    vim.g.molten_output_win_max_width = 200
    vim.g.molten_virt_text_output = true
    vim.g.molten_wrap_output = true
    
    -- Disable image popup functionality since it's causing issues
    vim.g.molten_enable_image_popup = true
    vim.g.molten_auto_image_popup = false
    
    -- Use both float and virtual text for images
    vim.g.molten_image_location = "both"
    
    -- Fix the border issue
    vim.g.molten_output_win_border = {
        " ", "─", " ",
        " ",      " ",
        " ", "─", " "
    }
    
    -- Other window settings
    vim.g.molten_output_crop_border = true
    vim.g.molten_output_win_hide_on_leave = false
    vim.g.molten_output_virt_lines = true
    
    -- Enable debug mode to see more information if needed
    -- vim.g.molten_show_mimetype_debug = true

    -- Set all available kernels based on the jupyter kernelspec list output
--    vim.g.molten_jupyter_kernels = {
--        ["py3.11"] = {
--            kernel_path = "/home/james/.local/share/jupyter/kernels/py3.11/kernel.json"
--        },
--        ["webscraper"] = {
--            kernel_path = "/home/james/.local/share/jupyter/kernels/webscraper/kernel.json"
--        },
--        ["python3"] = {
--            kernel_path = "/home/james/miniconda3/share/jupyter/kernels/python3/kernel.json"
--        }
--    }
        -- Set Python host
    vim.g.python3_host_prog = vim.fn.expand('/home/james/miniconda3/envs/py3.11/bin/python')
end

local function setup_keymaps()
    local map = vim.keymap.set
    
    -- Essential mappings
    map("n", "<localleader>mi", ":MoltenInit<CR>", { silent = true, desc = "Initialize Molten" })
    map("n", "<localleader>mr", ":MoltenRestart<CR>", { silent = true, desc = "Restart molten Molten" })

    map("n", "<localleader>rl", ":MoltenEvaluateLine<CR>", { silent = true, desc = "Evaluate line" })
    map("n", "<localleader>rr", ":MoltenReevaluateCell<CR>", { silent = true, desc = "Re-evaluate cell" })
    map("v", "<localleader>r", ":<C-u>MoltenEvaluateVisual<CR>gv", { silent = true, desc = "Evaluate visual selection" })
    
    -- Output management
    map("n", "<localleader>os", ":noautocmd MoltenEnterOutput<CR>", { silent = true, desc = "Enter output window" })
    map("n", "<localleader>oh", ":MoltenHideOutput<CR>", { silent = true, desc = "Hide output" })

    -- Remove the image popup mapping since we're disabling that functionality
    map("n", "<localleader>ip", ":MoltenImagePopup<CR>", { silent = true, desc = "Open image in popup" })
    map("n", "<localleader>ob", ":MoltenOpenInBrowser<CR>", { silent = true, desc = "Open output in browser" })
    vim.api.nvim_create_autocmd("FileType", {
        pattern = "molten_output",
        callback = function()
            -- Existing mappings
            vim.keymap.set("n", "q", ":q<CR>", { buffer = true, silent = true })
            vim.opt_local.wrap = true
            vim.opt_local.number = true
            
            -- Add select all mapping
            vim.keymap.set("n", "<C-a>", "ggVG", { buffer = true, silent = true, desc = "Select all output" })
        end,
    })

    -- Navigation mappings
    map("n", "]j", ":MoltenNext<CR>", { silent = true, desc = "Next cell" })
    map("n", "[j", ":MoltenPrev<CR>", { silent = true, desc = "Previous cell" })
    map("n", "<localleader>mg", ":MoltenGoto ", { silent = false, desc = "Go to specific cell" })
    
    -- Output management
    map("n", "<localleader>rd", ":MoltenDelete<CR>", { silent = true, desc = "Delete cell" })
end

function M.setup()
    setup_options()
    setup_keymaps()
end

return M

