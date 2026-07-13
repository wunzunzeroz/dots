return {
  "lewis6991/gitsigns.nvim",
  event = { "BufReadPre", "BufNewFile" },
  opts = {
    on_attach = function(buffer)
      local gs = require("gitsigns")
      local map = function(mode, lhs, rhs, desc)
        vim.keymap.set(mode, lhs, rhs, { buffer = buffer, desc = desc })
      end
      map("n", "]h", function() gs.nav_hunk("next") end, "Next hunk")
      map("n", "[h", function() gs.nav_hunk("prev") end, "Prev hunk")
      map("n", "<leader>ghs", gs.stage_hunk, "Stage hunk")
      map("v", "<leader>ghs", function()
        gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
      end, "Stage hunk")
      map("n", "<leader>ghr", gs.reset_hunk, "Reset hunk")
      map("n", "<leader>ghp", gs.preview_hunk, "Preview hunk")
      map("n", "<leader>gb", function() gs.blame_line({ full = true }) end, "Blame line")
      map("n", "<leader>gd", gs.diffthis, "Diff this")
    end,
  },
}
