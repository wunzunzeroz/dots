return {
  "nvim-lualine/lualine.nvim",
  event = "VeryLazy",
  opts = {
    options = {
      theme = "tokyonight",
      globalstatus = true,
      section_separators = "",
      component_separators = "",
    },
    sections = {
      lualine_a = { "mode" },
      lualine_b = { "branch", "diff", "diagnostics" },
      lualine_c = { "filename" },
      lualine_x = {
        -- Macro-recording indicator + search count, since cmdheight=0 hides
        -- the native "recording @q" / search-count messages.
        {
          function()
            local reg = vim.fn.reg_recording()
            return reg ~= "" and ("REC @" .. reg) or ""
          end,
          color = { fg = "#ff9e64" },
        },
        "searchcount",
        "encoding",
        "fileformat",
        "filetype",
      },
      lualine_y = { "progress" },
      lualine_z = { "location" },
    },
  },
  config = function(_, opts)
    require("lualine").setup(opts)
    -- Refresh immediately when a macro recording starts/stops so the indicator
    -- appears/clears without waiting for lualine's redraw timer.
    local group = vim.api.nvim_create_augroup("lualine_recording", { clear = true })
    vim.api.nvim_create_autocmd("RecordingEnter", {
      group = group,
      callback = function()
        require("lualine").refresh()
      end,
    })
    vim.api.nvim_create_autocmd("RecordingLeave", {
      group = group,
      callback = function()
        -- reg_recording() is still set during RecordingLeave; defer the refresh.
        vim.defer_fn(function()
          require("lualine").refresh()
        end, 50)
      end,
    })
  end,
}
