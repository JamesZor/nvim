-- PDF Viewer settings
vim.g.vimtex_view_method = 'zathura'
vim.g.vimtex_view_general_viewer = 'zathura'

-- Compiler settings
vim.g.vimtex_compiler_method = 'latexmk'

-- Enable syntax highlighting
vim.g.vimtex_syntax_enabled = 1

-- Enable syntax concealment
vim.g.vimtex_syntax_conceal_enabled = 1

-- Disable custom warnings
vim.g.vimtex_quickfix_ignore_filters = {
    'Underfull',
    'Overfull',
}

-- Set compiler options
vim.g.vimtex_compiler_latexmk = {
    build_dir = '',
    callback = 1,
    continuous = 1,
    executable = 'latexmk',
    options = {
        '-verbose',
        '-file-line-error',
        '-synctex=1',
        '-interaction=nonstopmode',
    },
}
