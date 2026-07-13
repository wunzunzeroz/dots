# Neovim Config Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a minimal, hand-rolled Neovim config in the dots repo (symlinked to `~/.config/nvim`) that replaces Zed, after nuking all existing nvim-family configs.

**Architecture:** A `nvim/` top-level dir using lazy.nvim. `init.lua` sets the leader, loads `core/*` (options, keymaps, autocmds), then bootstraps lazy which auto-imports each spec file in `lua/plugins/`. Every plugin is configured in its own file, one concern per file. Snacks.nvim provides the UI shell (picker, explorer, dashboard, zen, scratch, lazygit); the rest are single-purpose plugins.

**Tech Stack:** Neovim 0.11.2, Lua, lazy.nvim, folke/snacks.nvim, tokyonight, nvim-treesitter, mason + nvim-lspconfig (native `vim.lsp` API), blink.cmp, conform.nvim, gitsigns, flash.nvim, mini.{surround,pairs,icons}, render-markdown.nvim, lualine, which-key.

## Verification Model (read first)

This is a dotfiles repo — **there is no unit-test framework**, so tasks do not use red/green TDD. Instead each task ends with:

1. A **headless check**: a `nvim --headless` command that prints a value or exits cleanly, with expected stdout. General form used throughout:
   ```bash
   nvim --headless "+lua io.write(<expr>)" +qa 2>/dev/null
   ```
   (`--headless` + `+qa` runs non-interactively and quits; `io.write` sends the value to stdout; `2>/dev/null` drops nvim's startup chatter on stderr.)
2. A **manual check**: launch `nvim` interactively and observe the described result.
3. A **commit**.

Plugins install via `nvim --headless "+Lazy! sync" +qa` (the `!` runs lazy synchronously, as folke documents for CI/headless).

## Global Constraints

- **Neovim 0.11.2** — use the native `vim.lsp.config`/`vim.lsp.enable` and `vim.diagnostic.jump`/`vim.hl.on_yank` APIs (not the deprecated `vim.lsp.buf`-only setup or `vim.highlight`).
- **macOS only** — no Linux/Windows install paths.
- **Symlink convention** — the config lives in `dots/nvim/` and is symlinked to `~/.config/nvim` by `install.sh`. Never edit `~/.config/nvim` directly.
- **Leader is `<space>`** — set in `init.lua` before lazy loads.
- **Manual formatting only** — never configure format-on-save. Formatting happens via `<leader>p`.
- **Commit the lazy lockfile** (`nvim/lazy-lock.json`) for reproducibility.
- **Commit message trailer** — end every commit body with:
  `Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>`
- **Indentation of config Lua** — 2 spaces (matches `stylua.toml`).

## File Structure

```
nvim/
├── init.lua                  -- leader + require core/* + require core.lazy
├── stylua.toml               -- 2-space Lua formatting for this config
├── lazy-lock.json            -- committed lockfile (generated)
├── lua/
│   ├── core/
│   │   ├── options.lua       -- vim.opt settings
│   │   ├── keymaps.lua       -- non-plugin keymaps
│   │   ├── autocmds.lua      -- yank highlight, writing mode, cursor restore
│   │   └── lazy.lua          -- bootstrap lazy.nvim (NOT lua/lazy.lua — avoids shadowing the `lazy` module)
│   └── plugins/
│       ├── colorscheme.lua   -- tokyonight
│       ├── which-key.lua     -- which-key + group labels
│       ├── editor.lua        -- mini.icons, mini.surround, mini.pairs, flash
│       ├── snacks.lua        -- UI shell + its keymaps
│       ├── treesitter.lua    -- nvim-treesitter
│       ├── lsp.lua           -- mason, mason-tool-installer, lspconfig, schemastore, keymaps
│       ├── completion.lua    -- blink.cmp
│       ├── formatting.lua    -- conform
│       ├── git.lua           -- gitsigns
│       ├── markdown.lua      -- render-markdown
│       └── statusline.lua    -- lualine
```

---

## Task 1: Clean slate, scaffold, core, colorscheme

Stand up a loadable config: nuke old configs, create the skeleton + core settings + Tokyo Night, wire and run `install.sh`, update docs.

**Files:**
- Delete (on machine, not in repo): `~/.config/nvim`, `~/.config/nvim.old`, `~/.config/lvim`, `~/.local/share/nvim`, `~/.local/state/nvim`, `~/.cache/nvim`, `~/.local/share/lunarvim`, `~/.local/bin/lvim`
- Create: `nvim/init.lua`, `nvim/stylua.toml`, `nvim/lua/core/options.lua`, `nvim/lua/core/keymaps.lua`, `nvim/lua/core/autocmds.lua`, `nvim/lua/core/lazy.lua`, `nvim/lua/plugins/colorscheme.lua`
- Modify: `install.sh` (add symlink), `CLAUDE.md` (layout table), `README.md` (layout table)

**Interfaces:**
- Produces: a symlink `~/.config/nvim -> dots/nvim`; leader = `<space>`; lazy bootstrapped importing `plugins/`; the `tokyonight` colorscheme active.

- [ ] **Step 1: Nuke existing nvim-family configs and state**

The old `~/.config/nvim` is a standalone git repo already pushed to `github.com/wunzunzeroz/n`, so it is recoverable — no local backup needed.

```bash
rm -rf ~/.config/nvim ~/.config/nvim.old ~/.config/lvim \
       ~/.local/share/nvim ~/.local/state/nvim ~/.cache/nvim \
       ~/.local/share/lunarvim
rm -f ~/.local/bin/lvim
echo "nuked"
```
Expected: `nuked`, and `ls ~/.config/nvim` errors (No such file).

- [ ] **Step 2: Create `nvim/stylua.toml`**

```toml
column_width = 100
indent_type = "Spaces"
indent_width = 2
quote_style = "AutoPreferDouble"
```

- [ ] **Step 3: Create `nvim/lua/core/options.lua`**

```lua
local opt = vim.opt

-- Line numbers (absolute + relative)
opt.number = true
opt.relativenumber = true

-- Keep context around the cursor
opt.scrolloff = 10

-- Use the system clipboard for all yank/delete/paste
opt.clipboard = "unnamedplus"

-- Search
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true

-- Appearance
opt.termguicolors = true
opt.signcolumn = "yes" -- stable gutter; no shift when signs appear
opt.cursorline = true
opt.laststatus = 3 -- one global statusline

-- Indentation: 2-space, web-friendly
opt.expandtab = true
opt.shiftwidth = 2
opt.tabstop = 2
opt.softtabstop = 2
opt.smartindent = true

-- Splits open to the right / below
opt.splitright = true
opt.splitbelow = true

-- Persistent undo, no swap
opt.undofile = true
opt.swapfile = false

-- which-key pops quickly
opt.timeoutlen = 300

-- Rendered markdown needs concealing
opt.conceallevel = 2

-- Treesitter-based folding, everything unfolded by default
opt.foldmethod = "expr"
opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
opt.foldtext = ""
opt.foldlevel = 99
opt.foldlevelstart = 99

opt.mouse = "a"
```

- [ ] **Step 4: Create `nvim/lua/core/keymaps.lua`**

```lua
local map = vim.keymap.set

-- Escape insert mode
map("i", "jk", "<Esc>", { desc = "Escape insert mode" })

-- Clear search highlight
map("n", "<Esc>", "<cmd>nohlsearch<cr>", { desc = "Clear search highlight" })

-- Window navigation (Alt + hjkl)
map("n", "<A-h>", "<C-w>h", { desc = "Window left" })
map("n", "<A-j>", "<C-w>j", { desc = "Window down" })
map("n", "<A-k>", "<C-w>k", { desc = "Window up" })
map("n", "<A-l>", "<C-w>l", { desc = "Window right" })

-- Buffer navigation + close (Alt + n/p/q)
map("n", "<A-n>", "<cmd>bnext<cr>", { desc = "Next buffer" })
map("n", "<A-p>", "<cmd>bprevious<cr>", { desc = "Previous buffer" })
map("n", "<A-q>", "<cmd>bdelete<cr>", { desc = "Close buffer" })

-- Keep visual selection while indenting
map("v", "<", "<gv", { desc = "Indent left" })
map("v", ">", ">gv", { desc = "Indent right" })

-- Replay macro from register q
map("n", "Q", "@q", { desc = "Replay @q macro" })

-- Comment line/selection (built-in gc; remap so <leader>c triggers it)
map("n", "<leader>c", "gcc", { desc = "Comment line", remap = true })
map("v", "<leader>c", "gc", { desc = "Comment selection", remap = true })

-- Close buffer
map("n", "<leader>q", "<cmd>bdelete<cr>", { desc = "Close buffer" })

-- Window group
map("n", "<leader>wv", "<cmd>vsplit<cr>", { desc = "Split vertical" })
map("n", "<leader>ws", "<cmd>split<cr>", { desc = "Split horizontal" })
map("n", "<leader>wq", "<cmd>close<cr>", { desc = "Close window" })
map("n", "<leader>wo", "<cmd>only<cr>", { desc = "Only this window" })
map("n", "<leader>w=", "<C-w>=", { desc = "Equalize windows" })

-- Fold group (treesitter folds; works after Task 5)
map("n", "<leader>zc", "<cmd>set foldlevel=0<cr>", { desc = "Fold all" })
map("n", "<leader>zo", "<cmd>set foldlevel=99<cr>", { desc = "Unfold all" })
map("n", "<leader>z1", "<cmd>set foldlevel=1<cr>", { desc = "Fold to level 1" })
map("n", "<leader>z2", "<cmd>set foldlevel=2<cr>", { desc = "Fold to level 2" })
map("n", "<leader>z3", "<cmd>set foldlevel=3<cr>", { desc = "Fold to level 3" })

-- UI toggles (zen lives in snacks.lua)
map("n", "<leader>uw", "<cmd>set wrap!<cr>", { desc = "Toggle wrap" })
map("n", "<leader>us", "<cmd>set spell!<cr>", { desc = "Toggle spell" })
map("n", "<leader>ul", "<cmd>set relativenumber! number!<cr>", { desc = "Toggle line numbers" })
```

- [ ] **Step 5: Create `nvim/lua/core/autocmds.lua`**

```lua
local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- Briefly highlight yanked text
autocmd("TextYankPost", {
  group = augroup("highlight_yank", { clear = true }),
  callback = function()
    vim.hl.on_yank({ timeout = 200 })
  end,
})

-- Writing mode for prose filetypes
autocmd("FileType", {
  group = augroup("writing_mode", { clear = true }),
  pattern = { "markdown", "text", "gitcommit" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
    vim.opt_local.spell = true
  end,
})

-- Restore last cursor position when reopening a file
autocmd("BufReadPost", {
  group = augroup("restore_cursor", { clear = true }),
  callback = function(args)
    local mark = vim.api.nvim_buf_get_mark(args.buf, '"')
    local lcount = vim.api.nvim_buf_line_count(args.buf)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})
```

- [ ] **Step 6: Create `nvim/lua/core/lazy.lua` (bootstrap)**

```lua
-- Bootstrap lazy.nvim. This file is core/lazy.lua (not lua/lazy.lua) so it does
-- not shadow the `lazy` module on the runtimepath.
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  spec = { { import = "plugins" } },
  install = { colorscheme = { "tokyonight" } },
  checker = { enabled = false },
  change_detection = { notify = false },
})
```

- [ ] **Step 7: Create `nvim/init.lua`**

```lua
-- Leader must be set before lazy so plugin mappings pick it up.
vim.g.mapleader = " "
vim.g.maplocalleader = " "

require("core.options")
require("core.keymaps")
require("core.autocmds")
require("core.lazy")
```

- [ ] **Step 8: Create `nvim/lua/plugins/colorscheme.lua`**

```lua
return {
  "folke/tokyonight.nvim",
  lazy = false,
  priority = 1000,
  opts = { style = "storm" },
  config = function(_, opts)
    require("tokyonight").setup(opts)
    vim.cmd.colorscheme("tokyonight")
  end,
}
```

- [ ] **Step 9: Wire `install.sh`**

In `install.sh`, add `lazygit` to `BREW_FORMULAS` (needed by the snacks git UI in Task 4) and add the nvim symlink to `LINKS`.

Change the `BREW_FORMULAS` array from:
```bash
BREW_FORMULAS=(
  starship
  zsh-autosuggestions
  zsh-syntax-highlighting
  rbenv
)
```
to:
```bash
BREW_FORMULAS=(
  starship
  zsh-autosuggestions
  zsh-syntax-highlighting
  rbenv
  lazygit
)
```

Add this line inside the `LINKS=(` array (after the `.ideavimrc` line):
```bash
  ".config/nvim              nvim"
```

- [ ] **Step 10: Run `install.sh` and verify the symlink**

```bash
cd ~/dots && ./install.sh
readlink ~/.config/nvim
```
Expected: install output includes `+ /Users/mattchapman/.config/nvim → /Users/mattchapman/dots/nvim`, and `readlink` prints `/Users/mattchapman/dots/nvim`.

- [ ] **Step 11: Install plugins headless and verify config loads**

```bash
nvim --headless "+Lazy! sync" +qa
nvim --headless "+lua io.write(vim.g.colors_name or 'NONE')" +qa 2>/dev/null; echo
nvim --headless "+lua io.write(tostring(vim.o.scrolloff))" +qa 2>/dev/null; echo
nvim --headless "+lua io.write(vim.fn.maparg('jk','i'))" +qa 2>/dev/null; echo
```
Expected: lazy sync completes with no errors; then prints `tokyonight`, then `10`, then `<Esc>`.

- [ ] **Step 12: Manual check**

Run `nvim`. Expected: Tokyo Night Storm colors, relative line numbers in the gutter, no error messages. `:q` to exit.

- [ ] **Step 13: Update docs**

In both `CLAUDE.md` and `README.md`, add a row to the layout table for the new dir. In `CLAUDE.md` the table is under "## Layout"; add:
```
| `nvim/` | Neovim (from-scratch, lazy.nvim) |
```
Add an equivalent row to the `README.md` layout table (match its existing column format).

- [ ] **Step 14: Commit**

```bash
cd ~/dots
git add nvim install.sh CLAUDE.md README.md
git commit -m "$(cat <<'EOF'
feat(nvim): scaffold from-scratch config with core settings + theme

Nuke old nvim/lvim configs. Add nvim/ dir: lazy bootstrap, core
options/keymaps/autocmds, tokyonight. Wire install.sh symlink + lazygit.

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

## Task 2: which-key

Add keymap discovery + register the leader group labels (some groups' keys arrive in later tasks; the labels can be registered ahead).

**Files:**
- Create: `nvim/lua/plugins/which-key.lua`

**Interfaces:**
- Consumes: leader groups defined across tasks (`<leader>f`, `<leader>g`, `<leader>r`, `<leader>w`, `<leader>z`, `<leader>u`).
- Produces: a which-key popup on leader with labelled groups.

- [ ] **Step 1: Create `nvim/lua/plugins/which-key.lua`**

```lua
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
```

- [ ] **Step 2: Install and verify headless**

```bash
nvim --headless "+Lazy! sync" +qa
nvim --headless "+lua io.write(tostring(pcall(require, 'which-key')))" +qa 2>/dev/null; echo
```
Expected: sync installs `which-key.nvim`; prints `true`.

- [ ] **Step 3: Manual check**

Run `nvim`, press `<space>`, wait ~300ms. Expected: which-key popup appears showing groups (find, git, refactor, window, fold, ui toggle) plus the single mappings (comment, close buffer). `<Esc>` then `:q`.

- [ ] **Step 4: Commit**

```bash
cd ~/dots
git add nvim/lua/plugins/which-key.lua nvim/lazy-lock.json
git commit -m "$(cat <<'EOF'
feat(nvim): add which-key with leader group labels

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

## Task 3: Editor niceties (icons, surround, pairs, flash)

`mini.icons` loads eagerly so later UI plugins (snacks, lualine) get file icons. `mini.surround`, `mini.pairs`, and `flash` provide editing/motion.

**Files:**
- Create: `nvim/lua/plugins/editor.lua`

**Interfaces:**
- Produces: `MiniIcons` global with `nvim-web-devicons` mocked (so any plugin expecting devicons works); `s` triggers a flash jump.

- [ ] **Step 1: Create `nvim/lua/plugins/editor.lua`**

```lua
return {
  {
    "echasnovski/mini.icons",
    lazy = false,
    priority = 900,
    config = function()
      require("mini.icons").setup()
      MiniIcons.mock_nvim_web_devicons()
    end,
  },
  {
    "echasnovski/mini.surround",
    event = "VeryLazy",
    opts = {},
  },
  {
    "echasnovski/mini.pairs",
    event = "InsertEnter",
    opts = {},
  },
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {},
    keys = {
      {
        "s",
        mode = { "n", "x", "o" },
        function()
          require("flash").jump()
        end,
        desc = "Flash jump",
      },
      {
        "S",
        mode = { "n", "x", "o" },
        function()
          require("flash").treesitter()
        end,
        desc = "Flash treesitter",
      },
    },
  },
}
```

- [ ] **Step 2: Install and verify headless**

```bash
nvim --headless "+Lazy! sync" +qa
nvim --headless "+lua io.write(tostring(MiniIcons ~= nil))" +qa 2>/dev/null; echo
nvim --headless "+lua io.write(vim.fn.maparg('s','n'))" +qa 2>/dev/null; echo
```
Expected: sync installs `mini.icons`, `mini.surround`, `mini.pairs`, `flash.nvim`; prints `true`; then prints a non-empty mapping string (the flash lua callback).

- [ ] **Step 3: Manual check**

Run `nvim` on any multi-line file. Press `s` then two characters — flash labels appear; pick one to jump. In a line with `hello`, `ciw"` then `ysiw"`-style surround via `mini.surround` (`sa` add, `sd` delete, `sr` replace on a text object). Type `(` in insert mode — a matching `)` is auto-added. `:q!`.

- [ ] **Step 4: Commit**

```bash
cd ~/dots
git add nvim/lua/plugins/editor.lua nvim/lazy-lock.json
git commit -m "$(cat <<'EOF'
feat(nvim): add mini.icons/surround/pairs and flash jumps

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

## Task 4: Snacks UI shell

The centrepiece: picker, explorer, dashboard, scratch, zen, lazygit, notifier, indent, statuscolumn, bigfile — plus all their keymaps.

**Files:**
- Create: `nvim/lua/plugins/snacks.lua`

**Interfaces:**
- Consumes: `MiniIcons` (Task 3) for file icons; `lazygit` binary (installed via `install.sh` in Task 1).
- Produces: global `Snacks`; keymaps `<leader>ff/ft/fr/fs/fn/fw/fd/fc/fh`, `<leader><space>`, `<leader>e`, `<leader>.`, `<leader>S`, `<leader>gg`, `<leader>gl`, `<leader>uz`; a dashboard on empty startup.

- [ ] **Step 1: Confirm the lazygit binary is installed**

```bash
command -v lazygit || brew install lazygit
command -v lazygit
```
Expected: prints a path like `/opt/homebrew/bin/lazygit`.

- [ ] **Step 2: Create `nvim/lua/plugins/snacks.lua`**

```lua
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
```

- [ ] **Step 3: Install and verify headless**

```bash
nvim --headless "+Lazy! sync" +qa
nvim --headless "+lua io.write(tostring(Snacks ~= nil))" +qa 2>/dev/null; echo
nvim --headless "+lua io.write(vim.fn.maparg('<leader>ff','n') ~= '' and 'mapped' or 'MISSING')" +qa 2>/dev/null; echo
```
Expected: sync installs `snacks.nvim`; prints `true`; prints `mapped`.

- [ ] **Step 4: Manual check**

Run `nvim` in a git repo directory with no file argument. Expected: the snacks dashboard appears with the f/n/./r/g/c/q entries and recent files. Test:
- `<leader>ff` → file picker opens, type to fuzzy-filter, `<CR>` opens a file.
- `<leader>e` → explorer opens on the left.
- `<leader>.` → scratch buffer toggles open; type; toggle again to hide.
- `<leader>uz` → zen mode centres the buffer.
- `<leader>gg` → lazygit opens in a float; `q` closes it.

- [ ] **Step 5: Commit**

```bash
cd ~/dots
git add nvim/lua/plugins/snacks.lua nvim/lazy-lock.json
git commit -m "$(cat <<'EOF'
feat(nvim): add snacks UI shell (picker, explorer, dashboard, zen, scratch, lazygit)

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

## Task 5: Treesitter

Syntax highlighting, indentation, and folds for the target languages. Pinned to the `master` branch to use the stable classic config API.

**Files:**
- Create: `nvim/lua/plugins/treesitter.lua`

**Interfaces:**
- Produces: installed parsers for typescript/tsx/json/yaml/bash/markdown/lua; enables the `foldexpr` set in `options.lua`.

- [ ] **Step 1: Create `nvim/lua/plugins/treesitter.lua`**

```lua
return {
  "nvim-treesitter/nvim-treesitter",
  branch = "master",
  build = ":TSUpdate",
  event = { "BufReadPre", "BufNewFile" },
  main = "nvim-treesitter.configs",
  opts = {
    ensure_installed = {
      "typescript",
      "tsx",
      "javascript",
      "json",
      "jsonc",
      "yaml",
      "bash",
      "markdown",
      "markdown_inline",
      "lua",
      "vim",
      "vimdoc",
    },
    highlight = { enable = true },
    indent = { enable = true },
  },
}
```

- [ ] **Step 2: Install parsers and verify headless**

```bash
nvim --headless "+Lazy! sync" +qa
nvim --headless "+TSUpdateSync" +qa 2>/dev/null
nvim --headless "+lua io.write(tostring(require('nvim-treesitter.parsers').has_parser('typescript')))" +qa 2>/dev/null; echo
```
Expected: sync installs `nvim-treesitter`; `:TSUpdateSync` installs parsers synchronously; prints `true`.

- [ ] **Step 3: Manual check**

Create a scratch TS file: `nvim /tmp/check.tsx`, type:
```tsx
const greet = (name: string): string => `hi ${name}`;
```
Expected: syntax highlighting (keywords, strings, template literal all coloured). Press `zc` on the function line — it folds; `zo` unfolds. `:q!`.

- [ ] **Step 4: Commit**

```bash
cd ~/dots
git add nvim/lua/plugins/treesitter.lua nvim/lazy-lock.json
git commit -m "$(cat <<'EOF'
feat(nvim): add treesitter highlighting + folds for target languages

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

## Task 6: LSP

mason (binary installer) + mason-tool-installer (declarative install of servers *and* formatters) + nvim-lspconfig (ships the `lsp/<server>.lua` base configs consumed by `vim.lsp.enable`) + schemastore (JSON/YAML schemas). Servers enabled via the native 0.11 API. LSP keymaps set on `LspAttach`.

**Files:**
- Create: `nvim/lua/plugins/lsp.lua`

**Interfaces:**
- Consumes: nothing from earlier tasks.
- Produces: on `LspAttach`, buffer-local maps `gd`, `gr`, `gi`, `gy`, `gD`, `K`, `<leader>rn`, `<leader>rr`, `<leader>ro`, `]d`, `[d`. Formatters `prettierd`, `stylua`, `shfmt` installed for Task 8.

- [ ] **Step 1: Create `nvim/lua/plugins/lsp.lua`**

```lua
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
```

- [ ] **Step 2: Install servers/formatters and verify headless**

```bash
nvim --headless "+Lazy! sync" +qa
# mason-tool-installer installs on startup; give it a run to complete, then check binaries:
nvim --headless "+lua vim.defer_fn(function() vim.cmd('qa') end, 20000)"
ls ~/.local/share/nvim/mason/bin/ | tr '\n' ' '; echo
```
Expected: sync installs `mason.nvim`, `mason-tool-installer.nvim`, `schemastore.nvim`, `nvim-lspconfig`. The `ls` lists (among others) `vtsls`, `eslint-lsp`/`vscode-eslint-language-server`, `bash-language-server`, `marksman`, `lua-language-server`, `vscode-json-language-server`, `yaml-language-server`, `prettierd`, `stylua`, `shfmt`. If any are missing, run `nvim` and `:MasonToolsInstall`, wait, re-check.

- [ ] **Step 3: Manual check**

`nvim /tmp/check.tsx`, type an obvious type error:
```tsx
const n: number = "not a number";
```
Expected: after ~1-2s an eslint/vtsls diagnostic underlines the string with virtual text. `gd` on a symbol jumps to its definition; `K` shows hover docs; `]d`/`[d` move between diagnostics; `<leader>rn` prompts to rename. `:q!`.

- [ ] **Step 4: Commit**

```bash
cd ~/dots
git add nvim/lua/plugins/lsp.lua nvim/lazy-lock.json
git commit -m "$(cat <<'EOF'
feat(nvim): add LSP (mason + native vim.lsp) for ts/json/yaml/bash/md/lua

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

## Task 7: Completion (blink.cmp)

Fast completion with LSP/path/snippet/buffer sources. Adds the C-j/C-k popup navigation from the old ideavim habit and Enter-to-accept.

**Files:**
- Create: `nvim/lua/plugins/completion.lua`

**Interfaces:**
- Consumes: LSP (Task 6) as the primary completion source.
- Produces: an insert-mode completion menu.

- [ ] **Step 1: Create `nvim/lua/plugins/completion.lua`**

```lua
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
      documentation = { auto_show = true },
      menu = { border = "rounded" },
    },
    fuzzy = { implementation = "prefer_rust_with_warning" },
  },
}
```

- [ ] **Step 2: Install and verify headless**

```bash
nvim --headless "+Lazy! sync" +qa
nvim --headless "+lua io.write(tostring(pcall(require, 'blink.cmp')))" +qa 2>/dev/null; echo
```
Expected: sync installs `blink.cmp` (downloads its prebuilt binary); prints `true`.

- [ ] **Step 3: Manual check**

`nvim /tmp/check.tsx`. Enter insert mode and type `const x = "".` — a completion menu of string methods appears. `<C-j>`/`<C-k>` move the selection; `<CR>` accepts. `:q!`.

- [ ] **Step 4: Commit**

```bash
cd ~/dots
git add nvim/lua/plugins/completion.lua nvim/lazy-lock.json
git commit -m "$(cat <<'EOF'
feat(nvim): add blink.cmp completion with C-j/C-k navigation

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

## Task 8: Formatting (conform)

Manual formatting on `<leader>p` only — no format-on-save.

**Files:**
- Create: `nvim/lua/plugins/formatting.lua`

**Interfaces:**
- Consumes: formatters `prettierd`, `stylua`, `shfmt` installed in Task 6.
- Produces: `<leader>p` formats the buffer.

- [ ] **Step 1: Create `nvim/lua/plugins/formatting.lua`**

```lua
return {
  "stevearc/conform.nvim",
  cmd = "ConformInfo",
  keys = {
    {
      "<leader>p",
      function()
        require("conform").format({ async = true, lsp_format = "fallback" })
      end,
      mode = { "n", "v" },
      desc = "Format buffer",
    },
  },
  opts = {
    formatters_by_ft = {
      typescript = { "prettierd" },
      typescriptreact = { "prettierd" },
      javascript = { "prettierd" },
      javascriptreact = { "prettierd" },
      json = { "prettierd" },
      jsonc = { "prettierd" },
      yaml = { "prettierd" },
      markdown = { "prettierd" },
      lua = { "stylua" },
      sh = { "shfmt" },
      bash = { "shfmt" },
    },
    -- Deliberately NO format_on_save: manual only via <leader>p
  },
}
```

- [ ] **Step 2: Install and verify headless**

```bash
nvim --headless "+Lazy! sync" +qa
nvim --headless "+lua io.write(tostring(pcall(require, 'conform')))" +qa 2>/dev/null; echo
```
Expected: sync installs `conform.nvim`; prints `true`.

- [ ] **Step 3: Manual check**

Create a badly-formatted file: `nvim /tmp/check.json`, type `{"a":1,   "b":  2}` and save (`:w`). Press `<leader>p`. Expected: prettierd reformats it to indented multi-line JSON. Try a `.lua` file with odd spacing → stylua tidies it. `:q!`.

- [ ] **Step 4: Commit**

```bash
cd ~/dots
git add nvim/lua/plugins/formatting.lua nvim/lazy-lock.json
git commit -m "$(cat <<'EOF'
feat(nvim): add conform manual formatting on <leader>p

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

## Task 9: Git signs (gitsigns)

Gutter signs + hunk navigation and operations under `<leader>g`.

**Files:**
- Create: `nvim/lua/plugins/git.lua`

**Interfaces:**
- Produces: buffer-local maps `]h`, `[h`, `<leader>gs`, `<leader>gr`, `<leader>gp`, `<leader>gb`, `<leader>gd` (complementing `<leader>gg`/`<leader>gl` from snacks). Gutter signs in tracked files.

- [ ] **Step 1: Create `nvim/lua/plugins/git.lua`**

```lua
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
      map("n", "<leader>gs", gs.stage_hunk, "Stage hunk")
      map("v", "<leader>gs", function()
        gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
      end, "Stage hunk")
      map("n", "<leader>gr", gs.reset_hunk, "Reset hunk")
      map("n", "<leader>gp", gs.preview_hunk, "Preview hunk")
      map("n", "<leader>gb", function() gs.blame_line({ full = true }) end, "Blame line")
      map("n", "<leader>gd", gs.diffthis, "Diff this")
    end,
  },
}
```

- [ ] **Step 2: Install and verify headless**

```bash
nvim --headless "+Lazy! sync" +qa
nvim --headless "+lua io.write(tostring(pcall(require, 'gitsigns')))" +qa 2>/dev/null; echo
```
Expected: sync installs `gitsigns.nvim`; prints `true`.

- [ ] **Step 3: Manual check**

In the dots repo, edit a tracked file (e.g. add a line to `README.md`) and open it in `nvim`. Expected: a green/`+` sign in the gutter for the added line. `]h`/`[h` jump between hunks; `<leader>gp` previews the hunk; `<leader>gb` shows blame for the line. Discard the edit with `<leader>gr` (reset hunk). `:q!`.

- [ ] **Step 4: Commit**

```bash
cd ~/dots
git add nvim/lua/plugins/git.lua nvim/lazy-lock.json
git commit -m "$(cat <<'EOF'
feat(nvim): add gitsigns gutter signs + hunk keymaps

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

## Task 10: Rendered markdown

In-buffer rendering of headings, checkboxes, code blocks, tables.

**Files:**
- Create: `nvim/lua/plugins/markdown.lua`

**Interfaces:**
- Consumes: treesitter `markdown`/`markdown_inline` parsers (Task 5); `mini.icons` (Task 3).
- Produces: rendered markdown in `.md` buffers.

- [ ] **Step 1: Create `nvim/lua/plugins/markdown.lua`**

```lua
return {
  "MeanderingProgrammer/render-markdown.nvim",
  ft = { "markdown" },
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "echasnovski/mini.icons",
  },
  opts = {},
}
```

- [ ] **Step 2: Install and verify headless**

```bash
nvim --headless "+Lazy! sync" +qa
nvim --headless "+lua io.write(tostring(pcall(require, 'render-markdown')))" +qa 2>/dev/null; echo
```
Expected: sync installs `render-markdown.nvim`; prints `true`.

- [ ] **Step 3: Manual check**

`nvim /tmp/check.md`, type:
```markdown
# Title
## Section
- [ ] todo
- [x] done

```lua
print("hi")
```

| a | b |
|---|---|
| 1 | 2 |
```
Expected: headings styled with icons/colour, checkboxes rendered as glyphs, the code block bordered with a language label, the table aligned. Wrap + spell are on (from the writing-mode autocmd). `:q!`.

- [ ] **Step 4: Commit**

```bash
cd ~/dots
git add nvim/lua/plugins/markdown.lua nvim/lazy-lock.json
git commit -m "$(cat <<'EOF'
feat(nvim): add render-markdown for in-buffer markdown

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

## Task 11: Statusline (lualine) + final verification

Add the statusline and run the full end-to-end verification checklist from the spec.

**Files:**
- Create: `nvim/lua/plugins/statusline.lua`

**Interfaces:**
- Consumes: `mini.icons` (Task 3) for filetype icons; tokyonight theme.
- Produces: a global statusline.

- [ ] **Step 1: Create `nvim/lua/plugins/statusline.lua`**

```lua
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
  },
}
```

- [ ] **Step 2: Install and verify headless**

```bash
nvim --headless "+Lazy! sync" +qa
nvim --headless "+lua io.write(tostring(pcall(require, 'lualine')))" +qa 2>/dev/null; echo
```
Expected: sync installs `lualine.nvim`; prints `true`.

- [ ] **Step 3: Full spec verification checklist (manual)**

Run each and confirm:
- `nvim` then `:Lazy` → all plugins show installed, no errors. `:checkhealth` → nvim/treesitter/mason/snacks green.
- `:Mason` → all servers + formatters show installed.
- Open a `.tsx` → LSP attaches (`gd`, `K`, diagnostics work); `<leader>p` formats.
- Open a `.md` → renders in-buffer + wrap/spell on.
- In a git repo → gutter signs appear; `]h`/`[h` navigate; `<leader>gg` opens lazygit.
- Bare `nvim` → dashboard; `<leader>ff` picker; `<leader>e` explorer; `<leader>.` scratch all open.
- Statusline shows mode/branch/filename/diagnostics.

- [ ] **Step 4: Confirm install.sh idempotency**

```bash
cd ~/dots && ./install.sh
```
Expected: the nvim line shows `✓ /Users/mattchapman/.config/nvim` (already correct), not a re-link or backup.

- [ ] **Step 5: Commit**

```bash
cd ~/dots
git add nvim/lua/plugins/statusline.lua nvim/lazy-lock.json
git commit -m "$(cat <<'EOF'
feat(nvim): add lualine statusline

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>
EOF
)"
```

- [ ] **Step 6: Archive spec + plan (repo convention)**

Per CLAUDE.md, move both docs under `archive/` when the work ships:
```bash
cd ~/dots
git mv docs/superpowers/specs/2026-07-13-neovim-config-design.md docs/superpowers/archive/specs/
git mv docs/superpowers/plans/2026-07-13-neovim-config.md docs/superpowers/archive/plans/
git commit -m "$(cat <<'EOF'
docs(nvim): archive shipped neovim config spec + plan

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>
EOF
)"
```

---

## Notes for the implementer

- **Run every `nvim --headless "+Lazy! sync" +qa` from a normal shell**, not inside nvim.
- **If a plugin fails to install**, open `nvim`, run `:Lazy` (`S` to sync, `L` to view log), read the error, fix the spec file, re-sync.
- **mason binaries are async**: after Task 6, if `:Mason` shows a tool still installing, wait for it before the formatting/LSP manual checks.
- **Do not add format-on-save** anywhere — it's an explicit product decision.
- **Keymap is v1** — expect to refine it in a follow-up session once it's in daily use.
```
