lvim.plugins = {
	"Mofiqul/dracula.nvim",
  {
    "ggandor/leap.nvim",
    name = "leap",
    config = function()
    require("leap").add_default_mappings()
    end,
  },
}

lvim.colorscheme = 'dracula'

-- VIM MAPPINGS ----------

vim.opt.foldmethod = 'indent'

-- Open which-key faster
vim.opt.timeoutlen = 100

-- Remapping 'jk' to Escape in Insert mode
lvim.keys.insert_mode["jk"] = "<ESC>"

-- Centers cursor when moving 1/2 page down
lvim.keys.normal_mode["<C-d>"] = "<C-d>zz"


-- Tab Navigation (Alt + n/p)
lvim.keys.normal_mode["<A-n>"] = ":bnext<CR>"
lvim.keys.normal_mode["<A-p>"] = ":bprevious<CR>"

-- Pane Navigation (Alt + h/j/k/l)
lvim.keys.normal_mode["<A-h>"] = "<C-w>h"
lvim.keys.normal_mode["<A-l>"] = "<C-w>l"
lvim.keys.normal_mode["<A-k>"] = "<C-w>k"
lvim.keys.normal_mode["<A-j>"] = "<C-w>j"

-- Easy Visual Indentation
-- For visual mode, it's a bit different, as lvim.keys.visual_mode is the correct table to use:
lvim.keys.visual_mode["<"] = "<gv"
lvim.keys.visual_mode[">"] = ">gv"

-- Execute Macro Saved in 'q' Register
lvim.keys.normal_mode["qj"] = "@q"



lvim.builtin.which_key.mappings["P"] = {
  "<cmd>Telescope projects<CR>",
  "Projects"
}

-- Split Vertically
lvim.builtin.which_key.mappings["v"] = {
  "<cmd>vsplit<CR>",
  "Split Vertically"
}

-- Split Horizontally
lvim.builtin.which_key.mappings["s"] = {
  "<cmd>split<CR>",
  "Split Horizontally"
}
