# Zsh Config Overhaul -- Design Spec

**Date:** 2026-04-02
**Goal:** Modular, clean zsh config with Starship prompt (Tokyo Night themed), autosuggestions, syntax highlighting, and better completions. Drop all stale tooling.

## File Structure

Source of truth: `~/dots/zsh/`
Symlinks:
- `~/dots/zsh/.zshrc` -> `~/.zshrc`
- `~/dots/zsh/conf/` -> `~/.zsh/conf/`
- `~/dots/zsh/themes/starship.toml` -> `~/.config/starship.toml`

```
~/dots/zsh/
  .zshrc                # Entry point -- sources conf files in order
  conf/
    options.conf        # History, editor, shell options, vim mode
    path.conf           # All PATH additions (clean, no hardcoded usernames)
    aliases.conf        # All aliases (git, docker, utility, tmux)
    functions.conf      # Shell functions (killport, listport, gclone, pretty_diff)
    plugins.conf        # Autosuggestions, syntax highlighting, completions setup
    tools.conf          # Tool inits (nvm, rbenv, gcloud, terraform)
  themes/
    starship.toml       # Starship prompt config (Tokyo Night)
```

### Source Order

`.zshrc` sources in this order:
1. `options.conf` -- shell behavior first
2. `path.conf` -- PATH before anything that depends on it
3. `aliases.conf` -- aliases
4. `functions.conf` -- functions
5. `plugins.conf` -- plugins (autosuggestions, syntax highlighting, completions)
6. `tools.conf` -- tool initializations last (slowest, depends on PATH)

Starship init goes in `.zshrc` itself after sourcing everything (must be last to set up prompt hooks).

## Dropped (Stale)

- LunarVim (`lvim`) references -- user switched to nvim
- `ccat` alias for `cat`
- Hardcoded `/Users/matthew.chapman/` paths
- Dotnet SDK/tools PATH
- Doom Emacs PATH
- Android SDK PATH
- oh-my-posh (replaced by Starship)

## options.conf

```
export EDITOR=nvim

# History
HISTFILE=~/.zsh_history
HISTSIZE=1000000
SAVEHIST=1000000
setopt HIST_IGNORE_ALL_DUPS   # No duplicate entries
setopt HIST_SAVE_NO_DUPS      # Don't save duplicates
setopt HIST_REDUCE_BLANKS     # Remove extra blanks
setopt SHARE_HISTORY          # Share history across sessions
setopt APPEND_HISTORY         # Append, don't overwrite

# Shell behavior
setopt AUTO_CD                # cd by typing directory name
setopt CORRECT                # Suggest corrections for commands
setopt INTERACTIVE_COMMENTS   # Allow comments in interactive shell

# Vim mode
bindkey -v
export KEYTIMEOUT=1           # Reduce mode switch delay (10ms)
```

## path.conf

Only paths that are still active. Uses `$HOME` not hardcoded usernames.

```
# Homebrew
export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"

# User local binaries
export PATH="$HOME/.local/bin:$PATH"

# Ruby (rbenv)
export PATH="$HOME/.rbenv/bin:$PATH"
```

## aliases.conf

Kept from current config (dropping stale ones):

**Utility:**
- `n='nvim'`, `h='history 1'`, `c='clear'`, `r='reset'`, `x='exit'`
- `la='ls -a'`, `ll='ls -FGalh --color=auto'`
- `ts='tree -CshF -L 2'`, `duh='du -h --max-depth=1'`, `dfh='df -h'`
- `cp='cp -v'`, `rm='rm -i'`, `cgrep='grep -Hn --color=always'`
- `zshrc='nvim ~/.zshrc'`, `sz='source ~/.zshrc'`

**Docker:** All kept as-is (dps, dsa, dra, drf, dsp, dspv, dst, dlt)

**Git:** All kept as-is (gs, ga, gap, gd, gdc, gc, gl, grl, gco, gcb, gpu, gpd, grm, gsps, gu)

**Tmux:** All kept as-is (tx, tls, tns, tas, tks, tka)

**Dropped:**
- `bashrc` alias (references lvim and .bashrc)
- `zshrc` alias pointed to .vimrc (bug) -- fixed to point to .zshrc with nvim
- `vimrc` alias (referenced lvim)
- `v='lvim'` -- dropped
- `s=...` using `ag` and `lvim` -- dropped
- `cat='ccat'` -- dropped
- `pip='pip3'` -- dropped (modern systems alias this already)
- REPL aliases (dotnet, node) -- dropped

## functions.conf

Kept:
```
listport()    -- lsof -i :$1
killport()    -- kill $(lsof -t -i :$1)
pretty_diff() -- git diff with diff-so-fancy fallback
gclone()      -- git clone shorthand for github repos
```

## plugins.conf

All installed via Homebrew (no plugin manager needed):

```
brew install zsh-autosuggestions zsh-syntax-highlighting
```

Config:
```
# Autosuggestions (ghost text from history)
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#414868"   # Tokyo Night dim
ZSH_AUTOSUGGEST_STRATEGY=(history completion)

# Syntax highlighting (green=valid, red=invalid)
source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Completions
autoload -Uz compinit && compinit
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'   # Case insensitive
zstyle ':completion:*' menu select                            # Menu selection
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"       # Colored completions
```

Note: syntax-highlighting source MUST be last in plugins.conf (it wraps ZLE widgets).

## tools.conf

Tool initializations (lazy where possible):

```
# NVM (lazy-loaded to avoid slow startup)
export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"
[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"

# rbenv
eval "$(rbenv init - zsh)"

# Google Cloud SDK
[ -f "$HOME/google-cloud-sdk/path.zsh.inc" ] && . "$HOME/google-cloud-sdk/path.zsh.inc"
[ -f "$HOME/google-cloud-sdk/completion.zsh.inc" ] && . "$HOME/google-cloud-sdk/completion.zsh.inc"

# Terraform
autoload -U +X bashcompinit && bashcompinit
complete -o nospace -C /opt/homebrew/bin/terraform terraform
```

## Starship Theme (Tokyo Night)

`themes/starship.toml`:

Minimal, fast, informative. Matches tmux Tokyo Night palette.

**Left prompt segments:**
- Directory (truncated to 3 levels, Tokyo Night blue)
- Git branch + status (green = clean, yellow = dirty, red = conflicts)
- Language context (node, python, ruby -- only when relevant files detected)

**Right prompt:**
- Command duration (only if > 2s)
- Time (dimmed)

**Colors mapped to Tokyo Night:**
- Blue `#7aa2f7` -- directory
- Green `#9ece6a` -- git clean, success
- Yellow `#e0af68` -- git dirty, warnings
- Red `#f7768e` -- errors, conflicts
- Magenta `#bb9af7` -- language versions
- Cyan `#7dcfff` -- info/secondary

**Prompt character:** `❯` (green on success, red on error)

## Dependencies to Install

```bash
brew install starship zsh-autosuggestions zsh-syntax-highlighting
```

## Symlink Setup

```bash
ln -sf ~/dots/zsh/.zshrc ~/.zshrc
mkdir -p ~/.zsh
ln -sfn ~/dots/zsh/conf ~/.zsh/conf
mkdir -p ~/.config
ln -sf ~/dots/zsh/themes/starship.toml ~/.config/starship.toml
```

## Migration

- Current `~/dots/macos/.zshrc` is replaced by `~/dots/zsh/`
- Old file kept for reference or removed
- All active functionality preserved, stale items dropped
