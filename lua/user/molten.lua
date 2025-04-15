

local M = {}

local function setup_options()
    -- Basic options
    vim.g.molten_image_provider = "image.nvim"
    vim.g.molten_output_win_max_height = 40
    vim.g.molten_output_win_max_width = 200  -- Add this line to control width
    vim.g.molten_virt_text_output = true
    vim.g.molten_wrap_output = true
    vim.g.molten_enable_image_popup = true
    vim.g.molten_output_virt_lines_off_by_1 = false
    vim.g.molten_enable_virt_lines_in_output_window = false
    vim.g.molten_image_location = "both"
    -- Fix the border issue
--    vim.g.molten_output_win_border = {
--        "╭", "─", "╮",
--        "│",      "│",
--        "╰", "─", "╯"
--    }
-- 
    
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
    -- Set the open command explicitly for Linux
    vim.g.molten_open_cmd = vim.fn.exepath("feh")
--    vim.g.molten_open_cmd = "xdg-open"

-- Set the specific kernel paths
  vim.g.molten_jupyter_kernels = {
      ["py3.11"] = {
          kernel_path = "/home/james/.local/share/jupyter/kernels/py3.11/kernel.json"
      },
      ["julia-1.11"] = {
          kernel_path = "/home/james/.local/share/jupyter/kernels/julia-1.11/kernel.json"
      },
      ["julia-8-threads"] = {
          kernel_path = "/home/james/.local/share/jupyter/kernels/julia-_8-threads_-1.11/kernel.json"
      }
  }


    -- Set Python host
    vim.g.python3_host_prog = vim.fn.expand('/home/james/miniconda3/envs/py3.11/bin/python')
end

local function setup_keymaps()
    local map = vim.keymap.set
    
    -- Essential mappings
    map("n", "<localleader>mi", ":MoltenInit<CR>", { silent = true, desc = "Initialize Molten" })
    map("n", "<localleader>mr", ":MoltenRestart<CR>", { silent = true, desc = "Restart molten Molten" })

--    map("n", "<localleader>e", ":MoltenEvaluateOperator<CR>", { silent = true, desc = "Run operator selection" })
    map("n", "<localleader>rl", ":MoltenEvaluateLine<CR>", { silent = true, desc = "Evaluate line" })
    map("n", "<localleader>rr", ":MoltenReevaluateCell<CR>", { silent = true, desc = "Re-evaluate cell" })
    map("v", "<localleader>r", ":<C-u>MoltenEvaluateVisual<CR>gv", { silent = true, desc = "Evaluate visual selection" })
  -- Add these to your setup_keymaps() function
    map("n", "<localleader>os", ":noautocmd MoltenEnterOutput<CR>", { silent = true, desc = "Enter output window" })
    map("n", "<localleader>oh", ":MoltenHideOutput<CR>", { silent = true, desc = "Hide output" })

    map("n", "<localleader>ip", ":MoltenImagePopup<CR>", { silent = true, desc = "Open image in popup" })

    vim.api.nvim_create_autocmd("FileType", {
        pattern = "molten_output",
        callback = function()
            -- Existing mappings
            vim.keymap.set("n", "q", ":q<CR>", { buffer = true, silent = true })
            vim.opt_local.wrap = true
            vim.opt_local.number = true
            
            -- Add select all mapping (could use <C-a> or another key you prefer)
            vim.keymap.set("n", "<C-a>", "ggVG", { buffer = true, silent = true, desc = "Select all output" })
        end,
    })

    -- Navigation mappings
    map("n", "]j", ":MoltenNext<CR>", { silent = true, desc = "Next cell" })
    map("n", "[j", ":MoltenPrev<CR>", { silent = true, desc = "Previous cell" })
    map("n", "<localleader>mg", ":MoltenGoto ", { silent = false, desc = "Go to specific cell" })
    
    -- Output management
    map("n", "<localleader>rd", ":MoltenDelete<CR>", { silent = true, desc = "Delete cell" })
    map("n", "<localleader>oh", ":MoltenHideOutput<CR>", { silent = true, desc = "Hide output" })
    map("n", "<localleader>os", ":noautocmd MoltenEnterOutput<CR>", { silent = true, desc = "Show/enter output" })
end

function M.setup()
    setup_options()
    setup_keymaps()
end

return M
