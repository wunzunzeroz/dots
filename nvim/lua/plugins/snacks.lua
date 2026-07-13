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
    -- find (files)
    { "<leader>ff", function() Snacks.picker.files() end, desc = "Find files" },
    { "<leader>fr", function() Snacks.picker.recent() end, desc = "Recent files" },
    { "<leader>fc", function() Snacks.picker.files({ cwd = vim.fn.stdpath("config") }) end, desc = "Find config file" },
    { "<leader>fn", function() vim.cmd("enew") end, desc = "New file" },
    { "<leader>fp", function() Snacks.picker.projects() end, desc = "Projects" },
    -- search (content)
    { "<leader>sg", function() Snacks.picker.grep() end, desc = "Grep" },
    { "<leader>sw", function() Snacks.picker.grep_word() end, desc = "Grep word", mode = { "n", "x" } },
    { "<leader>ss", function() Snacks.picker.lsp_symbols() end, desc = "Symbols" },
    { "<leader>sS", function() Snacks.picker.lsp_workspace_symbols() end, desc = "Workspace symbols" },
    { "<leader>sd", function() Snacks.picker.diagnostics() end, desc = "Diagnostics" },
    { "<leader>sh", function() Snacks.picker.help() end, desc = "Help tags" },
    { "<leader>sr", function() Snacks.picker.resume() end, desc = "Resume last picker" },
    { "<leader>sk", function() Snacks.picker.keymaps() end, desc = "Keymaps" },
    { "<leader>/", function() Snacks.picker.grep() end, desc = "Grep" },
    -- buffers / explorer / scratch
    { "<leader><space>", function() Snacks.picker.buffers() end, desc = "Buffers" },
    { "<leader>e", function() Snacks.explorer() end, desc = "Explorer" },
    { "<leader>.", function() Snacks.scratch() end, desc = "Toggle scratch" },
    { "<leader>S", function() Snacks.scratch.select() end, desc = "Select scratch" },
    -- git
    { "<leader>gg", function() Snacks.lazygit() end, desc = "Lazygit" },
    { "<leader>gl", function() Snacks.picker.git_log() end, desc = "Git log" },
    { "<leader>go", function() Snacks.gitbrowse() end, desc = "Open in browser", mode = { "n", "x" } },
    -- ui
    { "<leader>uz", function() Snacks.zen() end, desc = "Zen mode" },
  },
}
