local map = vim.keymap.set

-- Escape insert mode
map("i", "jk", "<Esc>", { desc = "Escape insert mode" })

-- Clear search highlight
map("n", "<Esc>", "<cmd>nohlsearch<cr>", { desc = "Clear search highlight" })

-- Window navigation (Alt + hjkl)
map("n", "<A-h>", "<C-w>h", { desc = "Window left" })
map("n", "<A-j>", "<C-w>j", { desc = "Window down" })
map("n", "<A-k>", "<C-w>k", { desc = "Window up" })
map("n", "<A-l>", "<C-w>l", { desc = "Window right" })

-- Buffer navigation + close (Alt + n/p/q)
map("n", "<A-n>", "<cmd>bnext<cr>", { desc = "Next buffer" })
map("n", "<A-p>", "<cmd>bprevious<cr>", { desc = "Previous buffer" })
map("n", "<A-q>", "<cmd>bdelete<cr>", { desc = "Close buffer" })

-- Keep visual selection while indenting
map("v", "<", "<gv", { desc = "Indent left" })
map("v", ">", ">gv", { desc = "Indent right" })

-- Replay macro from register q
map("n", "Q", "@q", { desc = "Replay @q macro" })

-- Comment line/selection (built-in gc; remap so <leader>c triggers it)
map("n", "<leader>c", "gcc", { desc = "Comment line", remap = true })
map("v", "<leader>c", "gc", { desc = "Comment selection", remap = true })

-- Close buffer
map("n", "<leader>q", "<cmd>bdelete<cr>", { desc = "Close buffer" })

-- Window group
map("n", "<leader>wv", "<cmd>vsplit<cr>", { desc = "Split vertical" })
map("n", "<leader>ws", "<cmd>split<cr>", { desc = "Split horizontal" })
map("n", "<leader>wq", "<cmd>close<cr>", { desc = "Close window" })
map("n", "<leader>wo", "<cmd>only<cr>", { desc = "Only this window" })
map("n", "<leader>w=", "<C-w>=", { desc = "Equalize windows" })

-- Fold group (treesitter folds; works after Task 5)
map("n", "<leader>zc", "<cmd>set foldlevel=0<cr>", { desc = "Fold all" })
map("n", "<leader>zo", "<cmd>set foldlevel=99<cr>", { desc = "Unfold all" })
map("n", "<leader>z1", "<cmd>set foldlevel=1<cr>", { desc = "Fold to level 1" })
map("n", "<leader>z2", "<cmd>set foldlevel=2<cr>", { desc = "Fold to level 2" })
map("n", "<leader>z3", "<cmd>set foldlevel=3<cr>", { desc = "Fold to level 3" })

-- UI toggles (zen lives in snacks.lua)
map("n", "<leader>uw", "<cmd>set wrap!<cr>", { desc = "Toggle wrap" })
map("n", "<leader>us", "<cmd>set spell!<cr>", { desc = "Toggle spell" })
map("n", "<leader>ul", "<cmd>set relativenumber! number!<cr>", { desc = "Toggle line numbers" })
