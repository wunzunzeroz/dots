return {
  "saghen/blink.cmp",
  version = "1.*",
  event = "InsertEnter",
  opts = {
    keymap = {
      preset = "default",
      ["<C-j>"] = { "select_next", "fallback" },
      ["<C-k>"] = { "select_prev", "fallback" },
      ["<CR>"] = { "accept", "fallback" },
    },
    appearance = { nerd_font_variant = "mono" },
    sources = { default = { "lsp", "path", "snippets", "buffer" } },
    completion = {
      -- Don't preselect item 1, so <CR> inserts a newline until you explicitly
      -- pick with <C-j>/<C-k> (otherwise Enter hijacks newlines mid-typing).
      list = { selection = { preselect = false, auto_insert = true } },
      documentation = { auto_show = true },
      menu = { border = "rounded" },
    },
    fuzzy = { implementation = "prefer_rust_with_warning" },
  },
}
