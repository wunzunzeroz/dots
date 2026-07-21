#!/usr/bin/env bash
# Symlink dotfiles into their canonical locations on macOS.
# Idempotent: correct symlinks are kept, real files are moved aside as
# <target>.bak.<timestamp> before being replaced.

set -euo pipefail

DOTS="$(cd "$(dirname "$0")" && pwd)"
TS="$(date +%Y%m%d-%H%M%S)"

# Homebrew formulas the shell and editor configs depend on.
BREW_FORMULAS=(
  starship
  zsh-autosuggestions
  zsh-syntax-highlighting
  rbenv
  # Neovim + its runtime deps (pickers, treesitter builds, git UI).
  # Node (via nvm) and the Xcode CLT are assumed present — see README.
  neovim
  ripgrep
  fd
  fzf
  lazygit
)

# Format: "<target relative to $HOME> <source relative to $DOTS>"
LINKS=(
  ".zshrc                    zsh/.zshrc"
  ".tmux.conf                tmux/tmux.conf"
  ".aerospace.toml           aerospace/aerospace.toml"
  ".gitconfig                .gitconfig"
  ".ideavimrc                .ideavimrc"
  ".config/nvim              nvim"
  ".config/starship.toml     zsh/themes/starship.toml"
  ".config/ghostty/config    ghostty/config"
  ".config/zed/keymap.json   zed/keymap.json"
  ".config/zed/settings.json zed/settings.json"
  ".local/bin/boot           bin/boot"
  ".zsh/conf                 zsh/conf"
  ".tmux/conf                tmux/conf"
  ".tmux/scripts             tmux/scripts"
  ".claude/settings.json     claude/settings.json"
  ".claude/agent-memory      claude/agent-memory"
  ".claude/agents            claude/agents"
  ".claude/hooks             claude/hooks"
  ".claude/plugins/claude-hud/config.json claude/plugins/claude-hud/config.json"
)

link() {
  local target="$HOME/$1"
  local source="$DOTS/$2"

  if [[ ! -e "$source" ]]; then
    echo "✗ missing source: $source"
    return
  fi

  mkdir -p "$(dirname "$target")"

  if [[ -L "$target" && "$(readlink "$target")" == "$source" ]]; then
    echo "✓ $target"
    return
  fi

  if [[ -L "$target" || -e "$target" ]]; then
    mv "$target" "$target.bak.$TS"
    echo "→ backed up $target → $target.bak.$TS"
  fi

  ln -s "$source" "$target"
  echo "+ $target → $source"
}

if command -v brew >/dev/null 2>&1; then
  missing=()
  for f in "${BREW_FORMULAS[@]}"; do
    brew list --formula "$f" >/dev/null 2>&1 || missing+=("$f")
  done
  if (( ${#missing[@]} )); then
    echo "→ brew install ${missing[*]}"
    brew install "${missing[@]}"
  fi
else
  echo "✗ brew not found — skipping ${BREW_FORMULAS[*]}"
fi

for entry in "${LINKS[@]}"; do
  read -r tgt src <<< "$entry"
  link "$tgt" "$src"
done
