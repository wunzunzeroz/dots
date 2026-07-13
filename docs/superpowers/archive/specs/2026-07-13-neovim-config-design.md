# Neovim Config

## Overview

A minimal, hand-rolled Neovim config to replace Zed as the primary editor.
Built from scratch (no distro) so every part is understood and maintainable,
lives in the dots repo, and is symlinked to `~/.config/nvim`. All existing
Neovim-family configs on the machine (NvChad, LunarVim, older nvim) are removed
for a clean slate.

### Design Principles

- **From scratch, understand every part** — no framework hiding config. Each
  plugin is explicitly configured in its own file.
- **Plugins earn their spot** — 12 plugins, each with a clear single job.
- **Fast** — modern, Rust/native-backed tooling (blink.cmp, snacks picker,
  treesitter); lazy-loading where it helps.
- **Nice UI matters** — Tokyo Night Storm, nerd-font icons, a cohesive
  statusline, rendered markdown, a dashboard.
- **Keymap as a language** — a leader-based scheme ported from the existing
  `.ideavimrc` / Zed keymap, discoverable via which-key. This is a **v1**;
  keymap refinement is expected once the config is running day-to-day.

### Requirements (from brainstorming)

Must-haves: fast; nice UI; easy file/folder navigation; git gutters; LSP +
completion + formatting; language support for ts/tsx, json, yaml, bash,
markdown; fuzzy find; a simple flow for jotting notes in a bare directory.

---

## Architecture & File Layout

New top-level `nvim/` dir in dots, symlinked to `~/.config/nvim`. Standard
lazy.nvim layout — each file is one concern.

```
nvim/
├── init.lua                  -- set leader, require core/*, bootstrap lazy
├── stylua.toml               -- formatting rules for the config's own Lua
├── lua/
│   ├── core/
│   │   ├── options.lua       -- vim.opt (numbers, scrolloff, clipboard, tabs…)
│   │   ├── keymaps.lua       -- non-plugin maps (jk, alt-hjkl, visual indent, Q…)
│   │   └── autocmds.lua      -- yank-highlight, markdown writing mode, cursor restore
│   ├── lazy.lua              -- bootstrap lazy.nvim, setup({ import = "plugins" })
│   └── plugins/
│       ├── colorscheme.lua   -- tokyonight (storm)
│       ├── snacks.lua        -- UI shell: picker, explorer, dashboard, zen, scratch, lazygit, notifier, indent
│       ├── treesitter.lua    -- syntax/folds for the languages
│       ├── lsp.lua           -- mason + LSP servers + LSP keymaps
│       ├── completion.lua    -- blink.cmp
│       ├── formatting.lua    -- conform (manual, <leader>p)
│       ├── git.lua           -- gitsigns
│       ├── editor.lua        -- flash, mini.surround, mini.pairs, mini.icons
│       ├── markdown.lua      -- render-markdown.nvim
│       ├── statusline.lua    -- lualine
│       └── which-key.lua     -- which-key + group labels
```

`init.lua` sets `<space>` as leader *before* loading lazy, requires the `core/*`
modules, then bootstraps lazy which auto-imports every spec in `plugins/`.
Adding a plugin = adding one file. The lazy lockfile (`lazy-lock.json`) is
committed for reproducibility.

---

## Plugins

12 plugins, each earning its spot.

| Plugin | Job | Notes |
|---|---|---|
| `folke/lazy.nvim` | plugin manager | lockfile committed |
| `folke/snacks.nvim` | **UI shell** | picker, explorer, dashboard, zen, scratch, lazygit, notifier, indent, statuscolumn, bigfile |
| `folke/tokyonight.nvim` | theme | `storm` style |
| `nvim-treesitter/nvim-treesitter` | syntax + folds | ts, tsx, json, yaml, bash, markdown, lua |
| `williamboman/mason.nvim` + `neovim/nvim-lspconfig` | LSP install + config | servers below |
| `saghen/blink.cmp` | completion | Rust-fast |
| `stevearc/conform.nvim` | formatting | manual via `<leader>p` |
| `lewis6991/gitsigns.nvim` | git gutters + hunks | — |
| `folke/flash.nvim` | jump motions | replaces easymotion/sneak habit |
| `echasnovski/mini.surround` + `mini.pairs` + `mini.icons` | surround, autopairs, icons | icons feed snacks/lualine |
| `MeanderingProgrammer/render-markdown.nvim` | rendered markdown | notes flow |
| `nvim-lualine/lualine.nvim` | statusline | — |
| `folke/which-key.nvim` | keymap discovery | — |

**LSP servers (auto-installed by mason):** `vtsls` (ts/tsx), `eslint` (lint),
`jsonls`, `yamlls`, `bashls`, `marksman` (markdown), `lua_ls` (for editing this
config). JSON/YAML use SchemaStore for schema-aware completion.

**Formatters (mason):** `prettierd` (ts/tsx/json/yaml/md), `stylua` (lua),
`shfmt` (bash).

---

## Keymap Language (v1)

`<leader>` = `<space>`. Ported from the Zed keymap (current source of truth),
pulling in `.ideavimrc` extras. Expected to iterate after first use.

### No-leader (motion / editing)

| Key | Action |
|---|---|
| `jk` | Esc (insert) |
| `<A-h/j/k/l>` | move between windows |
| `<A-n>` / `<A-p>` | next / prev buffer |
| `<A-q>` | close buffer |
| `<` / `>` (visual) | indent, keep selection |
| `Q` | replay macro `q` |
| `<Esc>` (normal) | clear search highlight |
| `s` | flash jump |
| `gd` `gr` `gi` `gy` `K` | LSP: definition, references, implementation, type-def, hover |
| `]d` `[d` | next / prev diagnostic |
| `]h` `[h` | next / prev git hunk |
| `gc` `gcc` | comment (native) |

### Leader groups

| Prefix | Group | Keys |
|---|---|---|
| `<leader><space>` | buffers | quick buffer switcher |
| `<leader>f` | **find** | `ff` files · `ft` grep · `fr` recent · `fs` symbols · `fn` new file · `fw` grep-word · `fd` diagnostics · `fc` config · `fh` help |
| `<leader>e` | explorer | toggle file/folder tree |
| `<leader>w` | window | `wv` vsplit · `ws` split · `wq` close · `wo` only · `w=` equalize |
| `<leader>g` | **git** | `gg` lazygit · `gs` stage hunk · `gr` reset hunk · `gp` preview · `gb` blame · `gd` diff · `gl` log |
| `<leader>r` | refactor | `rn` rename · `rr` code actions · `ro` organize imports |
| `<leader>z` | fold | `zc` fold all · `zo` unfold all · `z1/z2/z3` fold at level |
| `<leader>u` | UI toggle | `uz` zen · `uw` wrap · `us` spell · `ul` line numbers |
| `<leader>c` | comment line | (single mapping) |
| `<leader>p` | format | conform (single mapping) |
| `<leader>.` | scratch | snacks scratch buffer |
| `<leader>q` | close buffer | (single mapping) |

### Deliberate divergences from the Zed scheme

1. **LSP goto → bare `gd`/`gr`/`gi`/`gy`** (Neovim-native) instead of
   `<leader>g d/t/u`, freeing `<leader>g` for **git** (nvim convention; git was
   already its own dock in Zed).
2. **flash on `s`** instead of `<leader>j` (flash's native trigger).
3. **explorer on `<leader>e`** instead of `<leader>x` (nvim convention).

---

## Behavior & Options

**Options:** relative + absolute line numbers; `scrolloff=10`; system clipboard
(`unnamedplus`); `ignorecase` + `smartcase`; `hlsearch`; `termguicolors`;
`signcolumn=yes` (stable gutter); 2-space indent (`expandtab`, `shiftwidth=2`,
`tabstop=2`); persistent undo (`undofile`); `splitright` / `splitbelow`;
`cursorline`; global statusline (`laststatus=3`); `timeoutlen=300` (which-key
pops fast); `conceallevel=2` (rendered markdown).

**Autocmds:** highlight-on-yank; markdown/text filetypes → soft-wrap +
`linebreak` + spell; restore last cursor position on file open.

**Notes flow:** `<leader>.` → per-cwd snacks scratch buffer (ephemeral jots);
opening any `.md` → writing mode (wrap/spell) + rendered markdown; `<leader>uz`
→ zen mode for distraction-free writing.

**Startup:** `nvim` with no file → snacks dashboard (find file, new file,
scratch, recent, config).

**Deliberately omitted:** Zed's `inactive_opacity: 0.5` (dimmed inactive panes)
— no clean native nvim equivalent without an extra plugin. Easy to add later.

---

## Nuke & Install

**Clean slate (remove before install):**

- `~/.config/nvim` (NvChad fork)
- `~/.config/nvim.old`
- `~/.config/lvim`
- `~/.local/share/nvim`
- `~/.local/state/nvim`
- `~/.cache/nvim`
- `~/.local/share/lunarvim`
- `~/.local/bin/lvim` (binary)

**install.sh changes:**

- Add symlink entry: `.config/nvim   nvim`
- Add `lazygit` to `BREW_FORMULAS` (snacks' git UI needs the binary)
- LSP servers and formatters are auto-installed by mason on first launch — no
  brew entries needed for them.
- Re-run `./install.sh` afterward to confirm idempotency (repo convention).

**Docs:** add an `nvim/` row to the layout tables in `CLAUDE.md` and `README.md`.

**Tool prerequisites already present:** nvim 0.11.2, `rg`, `fd`, `node` (nvm),
`git`, `make`, `fzf`, `cc`. Only `lazygit` needs installing (via brew, above).

---

## Verification

No test framework — this is dotfiles. Manual checklist after first launch:

- `:Lazy` — all 12 plugins install clean, no errors
- `:checkhealth` — green (nvim, treesitter, mason, snacks)
- `:Mason` — all servers + formatters installed
- Open a `.tsx` file → LSP attaches (`gd`, `K`, diagnostics work); `<leader>p`
  formats it
- Open a `.md` file → renders in-buffer + writing mode active
- In a git repo → gutter signs appear; `]h`/`[h` navigate hunks; `<leader>gg`
  opens lazygit
- Picker (`<leader>ff`), explorer (`<leader>e`), dashboard (bare `nvim`), and
  scratch (`<leader>.`) all open correctly

---

## Out of Scope (v1)

- DAP / debugging (no `<leader>d` debug group yet)
- Inactive-pane dimming
- Multiple colorschemes / theme switching
- Session management beyond persistent undo
- Non-macOS support
