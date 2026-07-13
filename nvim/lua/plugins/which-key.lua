return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {
    preset = "helix",
    spec = {
      { "<leader>b", group = "buffer" },
      { "<leader>c", group = "code" },
      { "<leader>f", group = "find" },
      { "<leader>s", group = "search" },
      { "<leader>g", group = "git" },
      { "<leader>gh", group = "hunks" },
      { "<leader>w", group = "window" },
      { "<leader>z", group = "fold" },
      { "<leader>u", group = "ui" },
      { "<leader>q", group = "quit" },
      { "gs", group = "surround" },
    },
  },
}
