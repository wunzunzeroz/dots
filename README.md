# dots

Matt's macOS dotfiles.

## Stack

- **Shell**: zsh + Starship prompt
- **Terminal**: Ghostty
- **Multiplexer**: tmux
- **Window manager**: Aerospace
- **Editor**: Zed (with IdeaVim for JetBrains, when used)
- **Launcher / scripts**: Raycast
- **AI**: Claude Code

## Layout

| Path | What |
|------|------|
| `aerospace/` | Aerospace window manager config + dock toggle |
| `bin/` | Personal binaries on `$PATH` (`boot`) |
| `docs/superpowers/` | Live specs and plans (shipped work archived under `archive/`) |
| `ghostty/` | Ghostty terminal config |
| `nvim/` | Neovim config (from-scratch, lazy.nvim) |
| `tmux/` | Modular tmux config (`tmux.conf` + `conf/` + `scripts/`) |
| `zed/` | Zed keymap and settings |
| `zsh/` | Modular zsh config (`.zshrc` + `conf/` + Starship theme) |
| `install.sh` | Symlinks every config to its canonical home |

Top-level `.gitconfig` and `.ideavimrc` link directly to `$HOME`.

## Setup

```sh
git clone <repo> ~/dots
cd ~/dots
./install.sh
```

`install.sh` is idempotent. Existing real files are moved aside as
`<file>.bak.<timestamp>` before being replaced with a symlink.

### Neovim prerequisites

`install.sh` installs nvim + its brew-able deps (ripgrep, fd, fzf, lazygit).
The Neovim config additionally assumes **Node.js** (via nvm) for the
TypeScript/ESLint/Prettier tooling and the **Xcode command-line tools**
(`xcode-select --install`) so nvim-treesitter can compile parsers. On first
launch, `:Lazy` installs plugins and Mason installs the LSP servers/formatters.
