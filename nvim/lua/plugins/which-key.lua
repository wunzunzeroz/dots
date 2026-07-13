return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {
    preset = "helix",
    spec = {
      { "<leader>f", group = "find" },
      { "<leader>g", group = "git" },
      { "<leader>r", group = "refactor" },
      { "<leader>w", group = "window" },
      { "<leader>z", group = "fold" },
      { "<leader>u", group = "ui toggle" },
    },
  },
}
