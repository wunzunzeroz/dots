# Neovim cheatsheet

Leader is `<Space>`. Press `<Space>` and wait — **which-key** shows every
leader mapping live, so this file is a reference, not something to memorize.

`jk` in insert mode = `<Esc>`.

## The leader groups

One letter = one domain. Derivable without looking:

| Prefix | Domain |
|--------|--------|
| `<leader>b` | **buffer** |
| `<leader>c` | **code** (LSP actions) |
| `<leader>f` | **find** (files) |
| `<leader>s` | **search** (content) |
| `<leader>g` | **git** (hunks under `gh`) |
| `<leader>w` | **window** |
| `<leader>z` | **fold** |
| `<leader>u` | **ui / toggle** |
| `<leader>q` | **quit** |

Leaves: `<leader>e` explorer · `<leader>.` scratch · `<leader><Space>` buffers · `<leader>/` grep. Reserved: `<leader>d` for a debugger if ever added.

---

## Bare keys (no leader)

### Motion & jumps

| Key | Action |
|-----|--------|
| `s` + 2 chars | Flash jump to a label |
| `S` | Flash treesitter (jump to a syntax node) |
| `<A-h/j/k/l>` | Move between windows |
| `<A-n>` / `<A-p>` | Next / previous buffer |
| `<A-q>` | Close buffer (keeps the window) |
| `<Esc>` (normal) | Clear search highlight |
| `Q` | Replay the macro in register `q` |

### LSP navigation (when a server is attached)

| Key | Action |
|-----|--------|
| `gd` | Go to definition |
| `gr` | References |
| `gi` | Go to implementation |
| `gy` | Go to type definition |
| `gD` | Go to declaration |
| `K` | Hover docs |
| `]d` / `[d` | Next / previous diagnostic |
| `]h` / `[h` | Next / previous git hunk |

### Editing operators

| Key | Action |
|-----|--------|
| `gc` / `gcc` | Comment (operator / line) |
| `gsa{motion}{char}` | **Surround add** (e.g. `gsaiw"` wraps a word in quotes) |
| `gsd{char}` | **Surround delete** (e.g. `gsd"`) |
| `gsr{old}{new}` | **Surround replace** (e.g. `gsr"'`) |
| `gsf` / `gsF` | Surround find (right / left) |
| `<` / `>` (visual) | Indent left / right, keeping the selection |
| `(`, `[`, `{`, `"` … | Auto-close pairs (mini.pairs) |

---

## `<leader>b` — buffer

| Key | Action |
|-----|--------|
| `bd` | Delete buffer (keeps window) |
| `bo` | Delete other buffers |
| `bn` / `bp` | Next / previous buffer |
| `bb` | Last (alternate) buffer |

## `<leader>c` — code (LSP)

| Key | Action |
|-----|--------|
| `ca` | Code action |
| `cr` | Rename symbol |
| `cf` | Format buffer (also `<leader>p`) |
| `co` | Organize imports |
| `cd` | Line diagnostics (float) |

Formatting is **manual only** — nothing formats on save.

## `<leader>f` — find (files)

| Key | Action |
|-----|--------|
| `ff` | Find files |
| `fr` | Recent files |
| `fc` | Find a file in the nvim config |
| `fn` | New file |
| `fp` | Projects |

## `<leader>s` — search (content)

| Key | Action |
|-----|--------|
| `sg` | Grep across project (also `<leader>/`) |
| `sw` | Grep word under cursor |
| `ss` | Document symbols |
| `sd` | Diagnostics list |
| `sh` | Help tags |
| `sr` | Resume last picker |
| `sk` | Search keymaps |

## `<leader>g` — git

| Key | Action |
|-----|--------|
| `gg` | Lazygit (full git UI) |
| `gl` | Git log |
| `gb` | Blame line |
| `gd` | Diff current file |
| `ghs` | Stage hunk (works on a visual selection too) |
| `ghr` | Reset hunk |
| `ghp` | Preview hunk |

## `<leader>w` — window

| Key | Action |
|-----|--------|
| `wv` | Split vertical |
| `ws` | Split horizontal |
| `wq` | Close window |
| `wo` | Only this window |
| `w=` | Equalize window sizes |

## `<leader>z` — fold

| Key | Action |
|-----|--------|
| `zc` | Fold all |
| `zo` | Unfold all |
| `z1` / `z2` / `z3` | Fold to depth 1 / 2 / 3 |

## `<leader>u` — ui / toggle

| Key | Action |
|-----|--------|
| `uw` | Toggle soft-wrap |
| `us` | Toggle spellcheck |
| `ul` | Toggle line numbers |
| `uz` | Zen mode (distraction-free) |
| `ur` | Toggle markdown render |
| `ud` | Toggle diagnostics |

## `<leader>q` — quit

| Key | Action |
|-----|--------|
| `qq` | Quit all |

---

## Notes & writing

| Key | Action |
|-----|--------|
| `<leader>.` | Toggle a scratch buffer (per-directory, persists) |
| `<leader>S` | Pick from saved scratch buffers |
| `<leader>uz` | Zen mode |

Opening any `.md` turns on soft-wrap + spellcheck and renders markdown
in-buffer (headings, checkboxes, tables, code blocks). render-markdown shows
the *raw* source on whichever line the cursor is on — move off the line to see
it rendered; toggle rendering entirely with `<leader>ur`.

## Completion (blink.cmp, insert mode)

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
