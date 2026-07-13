-- Leader must be set before lazy so plugin mappings pick it up.
vim.g.mapleader = " "
vim.g.maplocalleader = " "

require("core.options")
require("core.keymaps")
require("core.autocmds")
require("core.lazy")
