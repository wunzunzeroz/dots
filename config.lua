-- Read the docs: https://www.lunarvim.org/docs/configuration
-- Example configs: https://github.com/LunarVim/starter.lvim
-- Video Tutorials: https://www.youtube.com/watch?v=sFA9kX-Ud_c&list=PLhoH5vyxr6QqGu0i7tt_XoVK9v-KvZ3m6
-- Forum: https://www.reddit.com/r/lunarvim/
-- Discord: https://discord.com/invite/Xb9B4Ny
-- Example: Adding a new which-key binding
lvim.builtin.which_key.mappings["P"] = {
  "<cmd>Telescope projects<CR>",
  "Projects"
}

-- Example: Changing a vim keybinding
vim.api.nvim_set_keymap('n', '<New-Key>', '<Command>', { noremap = true, silent = true })

-- Remapping 'jk' to Escape in Insert mode
vim.api.nvim_set_keymap('i', 'jk', '<ESC>', {noremap = true, silent = true})

lvim.plugins = {
	"Mofiqul/dracula.nvim",
}

lvim.colorscheme = 'dracula'

vim.opt.foldmethod = 'indent'
