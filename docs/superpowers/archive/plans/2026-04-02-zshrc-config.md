# Zsh Config Overhaul Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the monolithic `macos/.zshrc` with a modular zsh config in `~/dots/zsh/` with Starship prompt (Tokyo Night themed), autosuggestions, syntax highlighting, and better completions.

**Architecture:** Entry-point `.zshrc` sources six conf files in order (options -> path -> aliases -> functions -> plugins -> tools), then initializes Starship last. Starship theme lives in `themes/starship.toml`.

**Tech Stack:** zsh, Starship prompt, zsh-autosuggestions (brew), zsh-syntax-highlighting (brew)

---

### Task 1: Install Dependencies

- [ ] **Step 1: Install starship, zsh-autosuggestions, zsh-syntax-highlighting**

```bash
brew install starship zsh-autosuggestions zsh-syntax-highlighting
```

- [ ] **Step 2: Verify installations**

```bash
starship --version
ls $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
ls $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
```

Expected: version output and both files exist.

- [ ] **Step 3: Commit** (nothing to commit -- brew installs are system-level)

---

### Task 2: Create Directory Structure and Entry Point

**Files:**
- Create: `zsh/.zshrc`
- Create: `zsh/conf/` (directory)
- Create: `zsh/themes/` (directory)

- [ ] **Step 1: Create the directory structure**

```bash
mkdir -p ~/dots/zsh/conf ~/dots/zsh/themes
```

- [ ] **Step 2: Write the entry-point .zshrc**

Create `~/dots/zsh/.zshrc`:

```zsh
#  mttchpmn          _
#          ____ ___ | |__  _ __ ___
#         |_  // __|| '_ \| '__/ __|
#          / / \__ \| | | | | | (__
#         /___||___/|_| |_|_|  \___|
#
# Modular zsh config -- sources conf files in order.

ZSH_CONF_DIR="$HOME/.zsh/conf"

source "$ZSH_CONF_DIR/options.conf"
source "$ZSH_CONF_DIR/path.conf"
source "$ZSH_CONF_DIR/aliases.conf"
source "$ZSH_CONF_DIR/functions.conf"
source "$ZSH_CONF_DIR/plugins.conf"
source "$ZSH_CONF_DIR/tools.conf"

# Starship prompt (must be last -- sets up precmd hooks)
eval "$(starship init zsh)"
```

- [ ] **Step 3: Commit**

```bash
git add zsh/.zshrc
git commit -m "feat(zsh): add modular entry point and directory structure"
```

---

### Task 3: Options File

**Files:**
- Create: `zsh/conf/options.conf`

- [ ] **Step 1: Write options.conf**

Create `~/dots/zsh/conf/options.conf`:

```zsh
# Shell options -- behavior, not appearance.

export EDITOR=nvim

# History
HISTFILE=~/.zsh_history
HISTSIZE=1000000
SAVEHIST=1000000
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_SAVE_NO_DUPS
setopt HIST_REDUCE_BLANKS
setopt SHARE_HISTORY
setopt APPEND_HISTORY

# Shell behavior
setopt AUTO_CD
setopt CORRECT
setopt INTERACTIVE_COMMENTS

# Vim mode
bindkey -v
export KEYTIMEOUT=1
```

- [ ] **Step 2: Commit**

```bash
git add zsh/conf/options.conf
git commit -m "feat(zsh): add shell options config"
```

---

### Task 4: Path File

**Files:**
- Create: `zsh/conf/path.conf`

- [ ] **Step 1: Write path.conf**

Create `~/dots/zsh/conf/path.conf`:

```zsh
# PATH -- all additions in one place. Uses $HOME, never hardcoded usernames.

# Homebrew
export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"

# User local binaries
export PATH="$HOME/.local/bin:$PATH"

# Ruby (rbenv)
export PATH="$HOME/.rbenv/bin:$PATH"
```

- [ ] **Step 2: Commit**

```bash
git add zsh/conf/path.conf
git commit -m "feat(zsh): add PATH config (cleaned up stale entries)"
```

---

### Task 5: Aliases File

**Files:**
- Create: `zsh/conf/aliases.conf`

- [ ] **Step 1: Write aliases.conf**

Create `~/dots/zsh/conf/aliases.conf`:

```zsh
# Aliases -- grouped by tool.

##################################################
# UTILITY

alias zshrc='nvim ~/.zshrc'
alias sz='source ~/.zshrc'

alias n='nvim'
alias h='history 1'
alias c='clear'
alias r='reset'
alias x='exit'
alias la='ls -a'
alias ll='ls -FGalh --color=auto'
alias ts='tree -CshF -L 2'
alias duh='du -h --max-depth=1'
alias dfh='df -h'
alias cp='cp -v'
alias rm='rm -i'
alias cgrep='grep -Hn --color=always'

##################################################
# DOCKER

alias dps='docker ps --all --format "table {{.ID}}\t{{.Names}}\t| {{.RunningFor}}\t{{.Status}}\t| {{.Ports}}"'
alias dsa='docker stop $(docker ps -aq)'
alias dra='docker rm $(docker ps -aq)'
alias drf='docker rm $(docker ps --all --quiet --filter "name=$@")'
alias dsp='docker system prune --all'
alias dspv='docker system prune --all --volumes'
alias dst='docker stats --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}"'
alias dlt='docker logs -f "$@"'

##################################################
# GIT

alias gu="gitui"
alias gs='git status'
alias ga='git add'
alias gap='git add -p'
alias gd='git diff'
alias gdc='git diff --compact-summary'
alias gc='git commit -m'
alias gl="git log --pretty=format:'%C(yellow)%h %Cred%ad %Cblue%an%Cgreen%d %Creset%s' --date=short"
alias grl="git reflog --date=local"
alias gco='git checkout $1'
alias gcb='git checkout -b $1'
alias gpu='git push'
alias gpd='git pull'
alias grm='git restore --staged'
alias gsps='git stash && git pull && git stash apply'

##################################################
# TMUX

alias tx='tmuxinator'
alias tls='tmux ls'
alias tns='tmux new -s $1'
alias tas='tmux attach-session -t $1'
alias tks='tmux kill-session -t $1'
alias tka='tmux kill-session -a'
```

- [ ] **Step 2: Commit**

```bash
git add zsh/conf/aliases.conf
git commit -m "feat(zsh): add aliases config (dropped stale lvim/ccat/dotnet)"
```

---

### Task 6: Functions File

**Files:**
- Create: `zsh/conf/functions.conf`

- [ ] **Step 1: Write functions.conf**

Create `~/dots/zsh/conf/functions.conf`:

```zsh
# Shell functions.

listport() {
    lsof -i :"$1"
}

killport() {
    kill $(lsof -t -i :"$1")
}

pretty_diff() {
    if command -v diff-so-fancy &>/dev/null; then
        git diff --color | diff-so-fancy
    else
        git diff --color-words
    fi
}

gclone() {
    git clone "git@github.com:$1/$2.git" "$3"
}
```

- [ ] **Step 2: Commit**

```bash
git add zsh/conf/functions.conf
git commit -m "feat(zsh): add shell functions config"
```

---

### Task 7: Plugins File

**Files:**
- Create: `zsh/conf/plugins.conf`

- [ ] **Step 1: Write plugins.conf**

Create `~/dots/zsh/conf/plugins.conf`:

```zsh
# Plugins -- sourced via Homebrew, no plugin manager needed.

# Completions (must be before plugins that use compdef)
autoload -Uz compinit && compinit
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# Autosuggestions (ghost text from history)
source "$(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#414868"
ZSH_AUTOSUGGEST_STRATEGY=(history completion)

# Syntax highlighting (must be LAST -- wraps ZLE widgets)
source "$(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
```

- [ ] **Step 2: Commit**

```bash
git add zsh/conf/plugins.conf
git commit -m "feat(zsh): add plugins config (autosuggestions, syntax highlighting, completions)"
```

---

### Task 8: Tools File

**Files:**
- Create: `zsh/conf/tools.conf`

- [ ] **Step 1: Write tools.conf**

Create `~/dots/zsh/conf/tools.conf`:

```zsh
# Tool initializations -- external tools that need shell setup.

# NVM
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

- [ ] **Step 2: Commit**

```bash
git add zsh/conf/tools.conf
git commit -m "feat(zsh): add tool initializations config"
```

---

### Task 9: Starship Theme (Tokyo Night)

**Files:**
- Create: `zsh/themes/starship.toml`

- [ ] **Step 1: Write starship.toml**

Create `~/dots/zsh/themes/starship.toml`:

```toml
# Starship prompt -- Tokyo Night Storm theme
# Matches tmux Tokyo Night palette from ~/dots/tmux/conf/theme.conf

format = """
$directory\
$git_branch\
$git_status\
$nodejs\
$python\
$ruby\
$docker_context\
$fill\
$cmd_duration\
$line_break\
$character"""

# Don't add a blank line between prompts
add_newline = false

[character]
success_symbol = "[❯](bold #9ece6a)"
error_symbol = "[❯](bold #f7768e)"
vimcmd_symbol = "[❮](bold #7aa2f7)"

[directory]
style = "bold #7aa2f7"
truncation_length = 3
truncate_to_repo = true

[git_branch]
format = "[$symbol$branch]($style) "
symbol = " "
style = "#9ece6a"

[git_status]
format = "[$all_status$ahead_behind]($style)"
style = "#e0af68"
conflicted = "[=$count](bold #f7768e) "
ahead = "[⇡$count](#9ece6a) "
behind = "[⇣$count](#e0af68) "
diverged = "[⇕$count](#f7768e) "
untracked = "[?$count](#7dcfff) "
stashed = "[*$count](#bb9af7) "
modified = "[!$count](#e0af68) "
staged = "[+$count](#9ece6a) "
deleted = "[✘$count](#f7768e) "

[nodejs]
format = "[$symbol($version)]($style) "
symbol = " "
style = "#9ece6a"
detect_files = ["package.json", ".node-version"]

[python]
format = "[$symbol($version)]($style) "
symbol = " "
style = "#e0af68"

[ruby]
format = "[$symbol($version)]($style) "
symbol = " "
style = "#f7768e"

[docker_context]
format = "[$symbol$context]($style) "
symbol = " "
style = "#7dcfff"

[cmd_duration]
min_time = 2_000
format = "[$duration]($style) "
style = "#414868"

[fill]
symbol = " "
```

- [ ] **Step 2: Commit**

```bash
git add zsh/themes/starship.toml
git commit -m "feat(zsh): add Starship Tokyo Night theme"
```

---

### Task 10: Symlinks and Smoke Test

- [ ] **Step 1: Back up existing config**

```bash
[ -f ~/.zshrc ] && cp ~/.zshrc ~/.zshrc.bak
```

- [ ] **Step 2: Create symlinks**

```bash
ln -sf ~/dots/zsh/.zshrc ~/.zshrc
mkdir -p ~/.zsh
ln -sfn ~/dots/zsh/conf ~/.zsh/conf
mkdir -p ~/.config
ln -sf ~/dots/zsh/themes/starship.toml ~/.config/starship.toml
```

- [ ] **Step 3: Reload shell**

```bash
source ~/.zshrc
```

Expected: Starship prompt appears with Tokyo Night colors, no errors.

- [ ] **Step 4: Smoke test features**

- Type a partial command -- autosuggestions should show ghost text
- Type an invalid command -- syntax highlighting should color it red
- Type a valid command -- syntax highlighting should color it green
- Press Tab -- completion menu should appear with selectable entries
- Run `gs` in a git repo -- should show git status
- Run `n` -- should open nvim
- Check prompt shows directory and git branch in Tokyo Night colors

- [ ] **Step 5: Commit any fixes**

```bash
git add -A zsh/
git commit -m "fix(zsh): smoke test adjustments"
```

(Only if changes were needed.)
