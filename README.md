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
| `bin/` | Personal binaries on `$PATH` (`boot`, raycast scripts) |
| `claude/` | Claude Code agent memory and agent definitions |
| `docs/superpowers/` | Live specs and plans (shipped work archived under `archive/`) |
| `ghostty/` | Ghostty terminal config |
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
