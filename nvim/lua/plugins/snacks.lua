return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  opts = {
    bigfile = { enabled = true },
    quickfile = { enabled = true },
    explorer = { enabled = true },
    picker = { enabled = true },
    indent = { enabled = true },
    input = { enabled = true },
    notifier = { enabled = true },
    scope = { enabled = true },
    scratch = { enabled = true },
    statuscolumn = { enabled = true },
    words = { enabled = true },
    zen = { enabled = true },
    dashboard = {
      preset = {
        keys = {
          { icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.dashboard.pick('files')" },
          { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
          { icon = " ", key = ".", desc = "Scratch", action = ":lua Snacks.scratch()" },
          { icon = " ", key = "r", desc = "Recent", action = ":lua Snacks.dashboard.pick('oldfiles')" },
          { icon = " ", key = "g", desc = "Grep", action = ":lua Snacks.dashboard.pick('live_grep')" },
          {
            icon = " ",
            key = "c",
            desc = "Config",
            action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})",
          },
          { icon = " ", key = "q", desc = "Quit", action = ":qa" },
        },
      },
    },
  },
  keys = {
    -- find
    { "<leader>ff", function() Snacks.picker.files() end, desc = "Find files" },
    { "<leader>ft", function() Snacks.picker.grep() end, desc = "Grep text" },
    { "<leader>fr", function() Snacks.picker.recent() end, desc = "Recent files" },
    { "<leader>fs", function() Snacks.picker.lsp_symbols() end, desc = "Document symbols" },
    { "<leader>fn", function() vim.cmd("enew") end, desc = "New file" },
    { "<leader>fw", function() Snacks.picker.grep_word() end, desc = "Grep word", mode = { "n", "x" } },
    { "<leader>fd", function() Snacks.picker.diagnostics() end, desc = "Diagnostics" },
    { "<leader>fc", function() Snacks.picker.files({ cwd = vim.fn.stdpath("config") }) end, desc = "Find config file" },
    { "<leader>fh", function() Snacks.picker.help() end, desc = "Help tags" },
    { "<leader><space>", function() Snacks.picker.buffers() end, desc = "Buffers" },
    -- explorer
    { "<leader>e", function() Snacks.explorer() end, desc = "Explorer" },
    -- scratch
    { "<leader>.", function() Snacks.scratch() end, desc = "Toggle scratch" },
    { "<leader>S", function() Snacks.scratch.select() end, desc = "Select scratch" },
    -- git ui
    { "<leader>gg", function() Snacks.lazygit() end, desc = "Lazygit" },
    { "<leader>gl", function() Snacks.picker.git_log() end, desc = "Git log" },
    -- zen
    { "<leader>uz", function() Snacks.zen() end, desc = "Zen mode" },
  },
}
