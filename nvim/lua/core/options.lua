local opt = vim.opt

-- Line numbers (absolute + relative)
opt.number = true
opt.relativenumber = true

-- Keep context around the cursor
opt.scrolloff = 10

-- Use the system clipboard for all yank/delete/paste
opt.clipboard = "unnamedplus"

-- Search
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true

-- Appearance
opt.termguicolors = true
opt.signcolumn = "yes" -- stable gutter; no shift when signs appear
opt.cursorline = true
opt.laststatus = 3 -- one global statusline
opt.showmode = false -- mode is shown in lualine; hide the native "-- INSERT --"
opt.cmdheight = 0 -- reclaim the command line row; lualine sits flush at the bottom

-- Indentation: 2-space, web-friendly
opt.expandtab = true
opt.shiftwidth = 2
opt.tabstop = 2
opt.softtabstop = 2

-- Splits open to the right / below
opt.splitright = true
opt.splitbelow = true

-- Persistent undo, no swap
opt.undofile = true
opt.swapfile = false

-- which-key pops quickly
opt.timeoutlen = 300

-- Snappier CursorHold (snacks word-highlight, gitsigns) than the 4s default
opt.updatetime = 250

-- (conceallevel is set per-buffer for prose in autocmds.lua; render-markdown
--  manages it in markdown windows.)

-- Treesitter-based folding, everything unfolded by default
opt.foldmethod = "expr"
opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
opt.foldtext = ""
opt.foldlevel = 99
opt.foldlevelstart = 99

opt.mouse = "a"
