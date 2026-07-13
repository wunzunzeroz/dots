# Neovim cheatsheet

Leader is `<Space>`. Press `<Space>` and wait — **which-key** shows every
leader mapping live, so this file is a reference, not something to memorize.

`jk` in insert mode = `<Esc>`.

---

## Finding things (snacks picker)

| Key | Action |
|-----|--------|
| `<leader>ff` | Find files |
| `<leader>ft` | Grep text across project |
| `<leader>fw` | Grep word under cursor |
| `<leader>fr` | Recent files |
| `<leader>fs` | Document symbols |
| `<leader>fd` | Diagnostics |
| `<leader>fc` | Find a file in the nvim config |
| `<leader>fh` | Help tags |
| `<leader>fn` | New file |
| `<leader><Space>` | Switch buffers |

## Files & folders

| Key | Action |
|-----|--------|
| `<leader>e` | Toggle file/folder explorer |

## Motion & jumps

| Key | Action |
|-----|--------|
| `s` + 2 chars | Flash jump to a label |
| `S` | Flash treesitter (jump to a syntax node) |
| `<A-h/j/k/l>` | Move between windows |
| `<A-n>` / `<A-p>` | Next / previous buffer |

## Editing

| Key | Action |
|-----|--------|
| `<leader>c` | Toggle comment (line in normal, selection in visual) |
| `gc` / `gcc` | Comment (native operator / line) |
| `<` / `>` (visual) | Indent left / right, keeping the selection |
| `Q` | Replay the macro in register `q` |
| `sa{motion}{char}` | **Surround add** (e.g. `saiw"` wraps a word in quotes) |
| `sd{char}` | **Surround delete** (e.g. `sd"`) |
| `sr{old}{new}` | **Surround replace** (e.g. `sr"'`) |
| `(`, `[`, `{`, `"` … | Auto-close pairs (mini.pairs) |

## LSP (active when a language server is attached)

| Key | Action |
|-----|--------|
| `gd` | Go to definition |
| `gr` | References |
| `gi` | Go to implementation |
| `gy` | Go to type definition |
| `gD` | Go to declaration |
| `K` | Hover docs |
| `]d` / `[d` | Next / previous diagnostic |
| `<leader>rn` | Rename symbol |
| `<leader>rr` | Code actions |
| `<leader>ro` | Organize imports |
| `<leader>p` | Format buffer (manual only — nothing formats on save) |

## Git

| Key | Action |
|-----|--------|
| `<leader>gg` | Lazygit (full git UI) |
| `<leader>gl` | Git log |
| `]h` / `[h` | Next / previous hunk |
| `<leader>gs` | Stage hunk (works on a visual selection too) |
| `<leader>gr` | Reset hunk |
| `<leader>gp` | Preview hunk |
| `<leader>gb` | Blame line |
| `<leader>gd` | Diff current file |

## Windows

| Key | Action |
|-----|--------|
| `<leader>wv` | Split vertical |
| `<leader>ws` | Split horizontal |
| `<leader>wq` | Close window |
| `<leader>wo` | Only this window |
| `<leader>w=` | Equalize window sizes |
| `<leader>q` | Close buffer |

## Folds (treesitter)

| Key | Action |
|-----|--------|
| `<leader>zc` | Fold all |
| `<leader>zo` | Unfold all |
| `<leader>z1` / `z2` / `z3` | Fold to depth 1 / 2 / 3 |

## Notes & writing

| Key | Action |
|-----|--------|
| `<leader>.` | Toggle a scratch buffer (per-directory, persists) |
| `<leader>S` | Pick from saved scratch buffers |
| `<leader>uz` | Zen mode (distraction-free) |

Opening any `.md` turns on soft-wrap + spellcheck and renders markdown
in-buffer (headings, checkboxes, tables, code blocks). render-markdown
shows the *raw* source on whichever line the cursor is on — move off the
line to see it rendered.

## UI toggles

| Key | Action |
|-----|--------|
| `<leader>uw` | Toggle soft-wrap |
| `<leader>us` | Toggle spellcheck |
| `<leader>ul` | Toggle line numbers |
| `<Esc>` (normal) | Clear search highlight |

## Completion (blink.cmp, in insert mode)

| Key | Action |
|-----|--------|
| `<C-j>` / `<C-k>` | Next / previous item |
| `<CR>` | Accept |

## Useful commands

| Command | Purpose |
|---------|---------|
| `:Lazy` | Manage plugins (install/update/status) |
| `:Mason` | Manage LSP servers & formatters |
| `:checkhealth` | Diagnose config/plugin health |
| `:ConformInfo` | Show formatters for the current buffer |

---

## Known v1 rough edges (to refine)

- `s` (flash) shares a prefix with the `s*` surround operators, so bare `s`
  has a brief timeout pause and visual-mode `sa` can race the jump. First
  candidate for the keymap tuning pass — e.g. move surround to a `gs*`
  prefix, or move flash to another key.
