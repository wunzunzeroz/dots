# Tmux Config Overhaul Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the monolithic `linux/.tmux.conf` with a modular, Tokyo Night-themed tmux config in `~/dots/tmux/` with power-user keybindings, session persistence scripts, and a clean powerline status bar.

**Architecture:** Entry-point `tmux.conf` sources four conf files in order (theme -> options -> keybindings -> statusbar). Helper scripts in `scripts/` provide git branch, session save/restore, and fuzzy session picking. All colors defined as tmux user options (`@theme-*`) in theme.conf so every other file references variables, not raw hex.

**Tech Stack:** tmux 3.5+, shell scripts (POSIX sh for scripts, tmux conf syntax for config), pbcopy (macOS clipboard), fzf (optional, for session picker)

---

### Task 1: Create Directory Structure and Entry Point

**Files:**
- Create: `tmux/tmux.conf`
- Create: `tmux/conf/` (directory)
- Create: `tmux/scripts/` (directory)

- [ ] **Step 1: Create the directory structure**

```bash
mkdir -p ~/dots/tmux/conf ~/dots/tmux/scripts
```

- [ ] **Step 2: Write the entry-point tmux.conf**

Create `~/dots/tmux/tmux.conf`:

```tmux
#  mttchpmn _                                          __
#          | |_ _ __ ___  _   ___  __  ___ ___  _ __  / _|
#          | __| '_ ` _ \| | | \ \/ / / __/ _ \| '_ \| |_
#          | |_| | | | | | |_| |>  < | (_| (_) | | | |  _|
#           \__|_| |_| |_|\__,_/_/\_(_)___\___/|_| |_|_|
#
# Modular tmux config -- sources conf files in order.
# Theme must be first so variables are available to everything else.

# Resolve config directory (follows symlinks)
TMUX_CONF_DIR="$HOME/.tmux/conf"
TMUX_SCRIPTS_DIR="$HOME/.tmux/scripts"

source-file "$HOME/.tmux/conf/theme.conf"
source-file "$HOME/.tmux/conf/options.conf"
source-file "$HOME/.tmux/conf/keybindings.conf"
source-file "$HOME/.tmux/conf/statusbar.conf"
```

- [ ] **Step 3: Commit**

```bash
git add tmux/tmux.conf
git commit -m "feat(tmux): add modular entry point and directory structure"
```

---

### Task 2: Theme File (Tokyo Night Storm)

**Files:**
- Create: `tmux/conf/theme.conf`

- [ ] **Step 1: Write theme.conf with palette and semantic aliases**

Create `~/dots/tmux/conf/theme.conf`:

```tmux
# Tokyo Night Storm palette
# Swap this file to change the entire color scheme.

# Core palette
set -g @theme-bg     "#1a1b26"
set -g @theme-fg     "#a9b1d6"
set -g @theme-black  "#414868"
set -g @theme-red    "#f7768e"
set -g @theme-green  "#9ece6a"
set -g @theme-yellow "#e0af68"
set -g @theme-blue   "#7aa2f7"
set -g @theme-magenta "#bb9af7"
set -g @theme-cyan   "#7dcfff"
set -g @theme-white  "#c0caf5"

# Semantic aliases
set -g @theme-accent   "#7aa2f7"
set -g @theme-active   "#bb9af7"
set -g @theme-inactive "#414868"
set -g @theme-alert    "#f7768e"
set -g @theme-ok       "#9ece6a"

# Pane borders
set -g pane-border-style        "fg=#{@theme-inactive}"
set -g pane-active-border-style "fg=#{@theme-active}"

# Messages and command prompt
set -g message-style         "fg=#{@theme-cyan},bg=#{@theme-bg}"
set -g message-command-style "fg=#{@theme-cyan},bg=#{@theme-bg}"

# Copy mode / selection highlight
set -g mode-style "fg=#{@theme-bg},bg=#{@theme-accent}"

# Clock mode
set -g clock-mode-colour "#{@theme-accent}"
```

- [ ] **Step 2: Verify syntax**

```bash
tmux source-file ~/dots/tmux/conf/theme.conf 2>&1 || echo "Syntax error"
```

Note: This will fail if run outside tmux -- that's fine. If inside tmux, expect no output (success) or a clear error message to fix.

- [ ] **Step 3: Commit**

```bash
git add tmux/conf/theme.conf
git commit -m "feat(tmux): add Tokyo Night Storm theme"
```

---

### Task 3: Options File

**Files:**
- Create: `tmux/conf/options.conf`

- [ ] **Step 1: Write options.conf**

Create `~/dots/tmux/conf/options.conf`:

```tmux
# Base options -- behavior, not appearance.

# Terminal & color support
set -g default-terminal "tmux-256color"
set -as terminal-overrides ",*:Tc"

# Remove escape delay (critical for vim)
set -sg escape-time 0

# Window/pane numbering starts at 1
set -g base-index 1
set -g pane-base-index 1

# Renumber windows when one is closed (no gaps)
set -g renumber-windows on

# Mouse support
set -g mouse on

# Vi mode for copy
setw -g mode-keys vi

# Generous scrollback
set -g history-limit 50000

# Focus events (vim/nvim integration)
set -g focus-events on

# Window titles
set -g set-titles on
set -g set-titles-string "TMUX: #S | #W"
setw -g automatic-rename on

# Activity monitoring (status bar handles the visual)
setw -g monitor-activity on
set -g visual-activity off

# Pane number display duration
set -wg display-panes-time 1500

# No repeat delay after switching windows
set -g repeat-time 0

# Cmatrix screensaver after 5 min idle
set -g lock-after-time 300
set -g lock-command "/usr/bin/cmatrix -s -C cyan"
```

- [ ] **Step 2: Commit**

```bash
git add tmux/conf/options.conf
git commit -m "feat(tmux): add base options config"
```

---

### Task 4: Keybindings File

**Files:**
- Create: `tmux/conf/keybindings.conf`

- [ ] **Step 1: Write keybindings.conf**

Create `~/dots/tmux/conf/keybindings.conf`:

```tmux
# Keybindings -- all prefix and non-prefix binds in one place.

##################################################
# PREFIX

# Unbind default prefix (Ctrl+B)
unbind C-b

# Set prefix to Ctrl+H
set -g prefix C-h
bind C-h send-prefix

##################################################
# CONFIG

# Reload config
bind r source-file ~/.tmux.conf\; display-message "Config reloaded"

##################################################
# SPLITS (open in same directory)

bind v split-window -h -c "#{pane_current_path}"
bind s split-window -v -c "#{pane_current_path}"

##################################################
# PANE NAVIGATION (vim keys)

bind h select-pane -L
bind j select-pane -D
bind k select-pane -U
bind l select-pane -R

##################################################
# PANE RESIZING (vim keys, uppercase, 5-cell increments)

bind -r H resize-pane -L 5
bind -r J resize-pane -D 5
bind -r K resize-pane -U 5
bind -r L resize-pane -R 5

##################################################
# WINDOWS

# Shift-arrow to switch windows (no prefix needed)
bind -n S-Left  previous-window
bind -n S-Right next-window

# Cycle layouts
bind Space next-layout

##################################################
# DISPLAY

# Show pane numbers
bind q display-panes

##################################################
# COPY MODE (vi-style + system clipboard)

bind [ copy-mode
bind ] paste-buffer

# In copy mode: v to begin selection, y to yank to clipboard
bind -T copy-mode-vi v send-keys -X begin-selection
bind -T copy-mode-vi y send-keys -X copy-pipe-and-cancel "pbcopy"

# Mouse drag auto-copies to clipboard
bind -T copy-mode-vi MouseDragEnd1Pane send-keys -X copy-pipe-and-cancel "pbcopy"

##################################################
# SESSION MANAGEMENT

# Fuzzy session picker
bind f display-popup -E -w 60% -h 60% "$HOME/.tmux/scripts/session-picker.sh"

# Save and restore sessions
bind S run-shell "$HOME/.tmux/scripts/session-save.sh"
bind R run-shell "$HOME/.tmux/scripts/session-restore.sh"

##################################################
# POPUP TERMINAL

# Floating scratch terminal (80% width/height)
bind t display-popup -E -w 80% -h 80% -d "#{pane_current_path}"
```

- [ ] **Step 2: Commit**

```bash
git add tmux/conf/keybindings.conf
git commit -m "feat(tmux): add keybindings config"
```

---

### Task 5: Helper Scripts (git-branch, session-save, session-restore, session-picker)

**Files:**
- Create: `tmux/scripts/git-branch.sh`
- Create: `tmux/scripts/session-save.sh`
- Create: `tmux/scripts/session-restore.sh`
- Create: `tmux/scripts/session-picker.sh`

- [ ] **Step 1: Write git-branch.sh**

Create `~/dots/tmux/scripts/git-branch.sh`:

```bash
#!/bin/sh
# Prints the current git branch for the active pane's directory.
# Returns empty string if not in a git repo.

cd "$1" 2>/dev/null || exit 0
branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
if [ -n "$branch" ]; then
    printf " %s" "$branch"
fi
```

- [ ] **Step 2: Write session-save.sh**

Create `~/dots/tmux/scripts/session-save.sh`:

```bash
#!/bin/sh
# Saves all tmux sessions, windows, panes and their working directories.
# Format: session_name:window_index:window_name:pane_index:pane_current_path

SAVE_FILE="$HOME/.tmux/sessions.txt"
mkdir -p "$(dirname "$SAVE_FILE")"

: > "$SAVE_FILE"

tmux list-panes -a -F "#{session_name}:#{window_index}:#{window_name}:#{pane_index}:#{pane_current_path}" >> "$SAVE_FILE"

tmux display-message "Sessions saved to $SAVE_FILE"
```

- [ ] **Step 3: Write session-restore.sh**

Create `~/dots/tmux/scripts/session-restore.sh`:

```bash
#!/bin/sh
# Restores tmux sessions from saved state.
# Skips sessions that already exist. Does not restore running processes.

SAVE_FILE="$HOME/.tmux/sessions.txt"

if [ ! -f "$SAVE_FILE" ]; then
    tmux display-message "No saved sessions found at $SAVE_FILE"
    exit 0
fi

while IFS=: read -r session_name window_index window_name pane_index pane_dir; do
    # Skip empty lines
    [ -z "$session_name" ] && continue

    # Check if session exists
    if ! tmux has-session -t "$session_name" 2>/dev/null; then
        tmux new-session -d -s "$session_name" -c "$pane_dir"
        # First window is created with the session, rename it
        tmux rename-window -t "${session_name}:1" "$window_name"
        continue
    fi

    # Check if window exists in session
    if ! tmux list-windows -t "$session_name" -F "#{window_index}" | grep -q "^${window_index}$"; then
        tmux new-window -t "${session_name}:${window_index}" -n "$window_name" -c "$pane_dir"
        continue
    fi

    # Add pane if pane_index > 0 (first pane already exists with the window)
    if [ "$pane_index" -gt 0 ] 2>/dev/null; then
        tmux split-window -t "${session_name}:${window_index}" -c "$pane_dir"
    fi
done < "$SAVE_FILE"

tmux display-message "Sessions restored from $SAVE_FILE"
```

- [ ] **Step 4: Write session-picker.sh**

Create `~/dots/tmux/scripts/session-picker.sh`:

```bash
#!/bin/sh
# Fuzzy session picker.
# Uses fzf if available, otherwise falls back to tmux choose-tree.

if command -v fzf >/dev/null 2>&1; then
    session=$(tmux list-sessions -F "#{session_name}: #{session_windows} windows (#{session_attached} attached)" 2>/dev/null \
        | fzf --reverse --prompt="Switch session: " \
        | cut -d: -f1)
    if [ -n "$session" ]; then
        tmux switch-client -t "$session"
    fi
else
    tmux choose-tree -s
fi
```

- [ ] **Step 5: Make all scripts executable**

```bash
chmod +x ~/dots/tmux/scripts/*.sh
```

- [ ] **Step 6: Commit**

```bash
git add tmux/scripts/
git commit -m "feat(tmux): add helper scripts (git-branch, session save/restore, picker)"
```

---

### Task 6: Status Bar

**Files:**
- Create: `tmux/conf/statusbar.conf`

- [ ] **Step 1: Write statusbar.conf**

Create `~/dots/tmux/conf/statusbar.conf`:

```tmux
# Status bar -- uses @theme-* variables from theme.conf.
# Powerline arrows: each arrow fg = outgoing segment bg, arrow bg = incoming segment bg.

# Update interval (5s is enough for git branch + spotify)
set -g status-interval 5

# Status bar position and base style
set -g status-style "fg=#{@theme-fg},bg=#{@theme-bg}"

##################################################
# LEFT STATUS

set -g status-left-length 200

# Segments: [ session] -> [ git-branch] -> (fade to bg)
#
# Arrow color logic:
#   green->blue arrow: fg=green, bg=blue
#   blue->bg arrow:    fg=blue, bg=default
set -g status-left "\
#[fg=#{@theme-bg},bg=#{@theme-ok},bold]  #S \
#[fg=#{@theme-ok},bg=#{@theme-accent},nobold]\
#[fg=#{@theme-bg},bg=#{@theme-accent}]#($HOME/.tmux/scripts/git-branch.sh #{pane_current_path}) \
#[fg=#{@theme-accent},bg=#{@theme-bg}] "

##################################################
# RIGHT STATUS

set -g status-right-length 500

# Segments (right to left build, left to right display):
#   [zoom indicator] [spotify] [IP] [date/time]
#
# Zoom: only shows when pane is zoomed
# Arrow color logic:
#   bg->cyan arrow:      fg=cyan, bg=default
#   cyan->magenta arrow: fg=cyan, bg=magenta
#   magenta->green arrow: fg=magenta, bg=green
set -g status-right "\
#{?window_zoomed_flag,#[fg=#{@theme-yellow}] Z ,}\
#[fg=#{@theme-cyan},bg=#{@theme-bg}]\
#[fg=#{@theme-bg},bg=#{@theme-cyan}] 󰓇 #(osascript ~/dots/macos/spotify.scpt) \
#[fg=#{@theme-active},bg=#{@theme-cyan}]\
#[fg=#{@theme-bg},bg=#{@theme-active}]  #(ipconfig getifaddr en0) \
#[fg=#{@theme-ok},bg=#{@theme-active}]\
#[fg=#{@theme-bg},bg=#{@theme-ok}] 󰥔 %d %b %R "

##################################################
# WINDOW TABS (center)

set -g status-justify centre

# Inactive window: dim background with powerline caps
set -g window-status-format "\
#[fg=#{@theme-bg},bg=#{@theme-inactive}]\
#[fg=#{@theme-fg},bg=#{@theme-inactive}] #W \
#[fg=#{@theme-inactive},bg=#{@theme-bg}]"

# Active window: accent background with powerline caps (bold)
set -g window-status-current-format "\
#[fg=#{@theme-bg},bg=#{@theme-active}]\
#[fg=#{@theme-bg},bg=#{@theme-active},bold] #W \
#[fg=#{@theme-active},bg=#{@theme-bg}]"

# Activity style (overrides inactive window fg when activity detected)
set -g window-status-activity-style "fg=#{@theme-yellow},bg=#{@theme-inactive}"

# Separator between window tabs
set -g window-status-separator " "
```

- [ ] **Step 2: Commit**

```bash
git add tmux/conf/statusbar.conf
git commit -m "feat(tmux): add powerline status bar with tokyo night theme"
```

---

### Task 7: Symlink Setup and Smoke Test

**Files:**
- Modify: existing symlinks at `~/.tmux.conf`, `~/.tmux/conf`, `~/.tmux/scripts`

- [ ] **Step 1: Back up existing config**

```bash
[ -f ~/.tmux.conf ] && cp ~/.tmux.conf ~/.tmux.conf.bak
```

- [ ] **Step 2: Create symlinks**

```bash
ln -sf ~/dots/tmux/tmux.conf ~/.tmux.conf
mkdir -p ~/.tmux
ln -sfn ~/dots/tmux/conf ~/.tmux/conf
ln -sfn ~/dots/tmux/scripts ~/.tmux/scripts
```

Note: `-n` flag on directory symlinks prevents creating a symlink inside an existing directory.

- [ ] **Step 3: Reload tmux config (inside a tmux session)**

```bash
tmux source-file ~/.tmux.conf
```

Expected: No errors. Status bar should show Tokyo Night colors with powerline segments.

- [ ] **Step 4: Smoke test keybindings**

Test each of these inside tmux:
- `C-h v` -- should split vertically
- `C-h s` -- should split horizontally
- `C-h h/j/k/l` -- should navigate panes
- `C-h H/J/K/L` -- should resize panes
- `C-h t` -- should open floating popup terminal
- `C-h f` -- should open session picker
- `C-h [` then `v`, select text, `y` -- should copy to system clipboard
- `C-h r` -- should show "Config reloaded"

- [ ] **Step 5: Smoke test status bar**

Verify:
- Left: green session name segment, blue git branch (if in a git repo)
- Right: Spotify info, IP address, date/time
- Center: window tabs with magenta active, dark inactive
- Powerline arrows have correct color transitions (no inversions)

- [ ] **Step 6: Commit any fixes from smoke testing**

```bash
git add -A tmux/
git commit -m "fix(tmux): smoke test adjustments"
```

(Only if changes were needed.)

---

### Task 8: Final Commit and Cleanup

- [ ] **Step 1: Verify all files are tracked**

```bash
git status
```

Expected: All `tmux/` files committed, no untracked files in that directory.

- [ ] **Step 2: Final commit if any loose changes**

```bash
git add tmux/
git commit -m "feat(tmux): complete modular tmux config overhaul"
```
