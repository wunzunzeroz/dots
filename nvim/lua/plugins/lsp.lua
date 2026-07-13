return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "williamboman/mason.nvim",
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    "b0o/schemastore.nvim",
  },
  config = function()
    require("mason").setup()
    require("mason-tool-installer").setup({
      ensure_installed = {
        -- LSP servers (mason package names)
        "vtsls",
        "eslint-lsp",
        "bash-language-server",
        "marksman",
        "lua-language-server",
        "json-lsp",
        "yaml-language-server",
        -- Formatters (used by conform in Task 8)
        "prettierd",
        "stylua",
        "shfmt",
      },
    })

    -- Per-server settings (merged over lspconfig's shipped defaults).
    local servers = {
      vtsls = {},
      eslint = {},
      bashls = {},
      marksman = {},
      lua_ls = {
        settings = {
          Lua = {
            diagnostics = { globals = { "vim", "Snacks", "MiniIcons" } },
          },
        },
      },
      jsonls = {
        settings = {
          json = {
            schemas = require("schemastore").json.schemas(),
            validate = { enable = true },
          },
        },
      },
      yamlls = {
        settings = {
          yaml = {
            schemaStore = { enable = false, url = "" },
            schemas = require("schemastore").yaml.schemas(),
          },
        },
      },
    }

    for name, cfg in pairs(servers) do
      vim.lsp.config(name, cfg)
      vim.lsp.enable(name)
    end

    -- Buffer-local keymaps when a server attaches
    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("lsp_attach", { clear = true }),
      callback = function(ev)
        local map = function(keys, fn, desc)
          vim.keymap.set("n", keys, fn, { buffer = ev.buf, desc = desc })
        end
        map("gd", vim.lsp.buf.definition, "Go to definition")
        map("gr", vim.lsp.buf.references, "References")
        map("gi", vim.lsp.buf.implementation, "Go to implementation")
        map("gy", vim.lsp.buf.type_definition, "Go to type definition")
        map("gD", vim.lsp.buf.declaration, "Go to declaration")
        map("K", vim.lsp.buf.hover, "Hover")
        map("<leader>rn", vim.lsp.buf.rename, "Rename")
        map("<leader>rr", vim.lsp.buf.code_action, "Code action")
        map("<leader>ro", function()
          vim.lsp.buf.code_action({
            context = { only = { "source.organizeImports" } },
            apply = true,
          })
        end, "Organize imports")
        map("]d", function()
          vim.diagnostic.jump({ count = 1, float = true })
        end, "Next diagnostic")
        map("[d", function()
          vim.diagnostic.jump({ count = -1, float = true })
        end, "Prev diagnostic")
      end,
    })

    vim.diagnostic.config({
      virtual_text = true,
      signs = true,
      severity_sort = true,
      float = { border = "rounded" },
    })
  end,
}
