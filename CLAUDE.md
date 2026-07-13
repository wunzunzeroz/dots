# CLAUDE.md

Guidance for Claude Code when working in this repo.

## What this is

Personal macOS dotfiles. No build, no tests, no package manager. Each
top-level dir is the config for one tool. `install.sh` symlinks
everything into `$HOME`.

## Layout

| Path | Tool |
|------|------|
| `aerospace/` | Aerospace WM |
| `bin/` | Personal binaries (boot, atlas-* raycast scripts) |
| `claude/` | Claude Code config (symlinked into `~/.claude/`) |
| `docs/superpowers/` | Specs and plans for in-flight work |
| `docs/superpowers/archive/` | Shipped specs/plans — read-only history |
| `ghostty/`, `tmux/`, `zed/`, `zsh/` | Self-explanatory |
| `nvim/` | Neovim (from-scratch, lazy.nvim) |

## Workflow conventions

- For non-trivial config changes, write a spec in
  `docs/superpowers/specs/YYYY-MM-DD-<topic>-design.md` and a plan in
  `docs/superpowers/plans/YYYY-MM-DD-<topic>.md` before touching code.
  When the work ships, move both files under `archive/`.
- After editing the symlink map in `install.sh`, run `./install.sh` to
  verify idempotency.

## Naming

The Obsidian vault was renamed `brain` → `atlas`. The Raycast scripts
in `bin/raycast-scripts/` are named `atlas-*` and target `~/atlas`, but
their user-facing Raycast titles still say "Brain — ..." in some places
intentionally. Don't "fix" the title strings unless asked.

## Don't

- Don't add comments that just restate what the code does. Configs and
  shell scripts here are short — names should be enough.
- Don't introduce new tools (stow, chezmoi, etc.) without asking.
- Don't create new install targets for Linux/Windows. This repo is
  macOS-only.
