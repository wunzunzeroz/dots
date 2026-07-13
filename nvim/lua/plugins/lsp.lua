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
        -- Formatters (used by conform)
        "prettierd",
        "stylua",
        "shfmt",
      },
    })

    -- Per-server settings (merged over lspconfig's shipped defaults).
    local ts_inlay_hints = {
      parameterNames = { enabled = "literals" },
      parameterTypes = { enabled = true },
      variableTypes = { enabled = true },
      propertyDeclarationTypes = { enabled = true },
      functionLikeReturnTypes = { enabled = true },
      enumMemberValues = { enabled = true },
    }

    local servers = {
      vtsls = {
        settings = {
          typescript = { inlayHints = ts_inlay_hints },
          javascript = { inlayHints = ts_inlay_hints },
        },
      },
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

    -- Advertise blink.cmp's extended completion capabilities to every server
    -- (import-source labels, insert-replace, lazy doc resolution, etc.).
    vim.lsp.config("*", { capabilities = require("blink.cmp").get_lsp_capabilities() })

    for name, cfg in pairs(servers) do
      vim.lsp.config(name, cfg)
      vim.lsp.enable(name)
    end

    -- Buffer-local keymaps when a server attaches
    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("lsp_attach", { clear = true }),
      callback = function(ev)
        local map = function(keys, fn, desc)
          -- nowait: bare `gr`/`gi`/etc. are prefixes of nvim 0.11's default gr*
          -- maps, so without this they'd wait `timeoutlen` before firing.
          vim.keymap.set("n", keys, fn, { buffer = ev.buf, desc = desc, nowait = true })
        end
        map("gd", vim.lsp.buf.definition, "Go to definition")
        map("gr", vim.lsp.buf.references, "References")
        map("gi", vim.lsp.buf.implementation, "Go to implementation")
        map("gy", vim.lsp.buf.type_definition, "Go to type definition")
        map("gD", vim.lsp.buf.declaration, "Go to declaration")
        map("K", vim.lsp.buf.hover, "Hover")
        map("<leader>cr", vim.lsp.buf.rename, "Rename")
        map("<leader>ca", vim.lsp.buf.code_action, "Code action")
        map("<leader>co", function()
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
