# Tmux Config Overhaul -- Design Spec

**Date:** 2026-04-02
**Goal:** Fully modular, zero-dependency tmux config with Tokyo Night theming, power-user keybindings, session persistence, and a clean status bar.

## File Structure

Source of truth: `~/dots/tmux/`
Symlinks:
- `~/dots/tmux/tmux.conf` -> `~/.tmux.conf`
- `~/dots/tmux/conf/` -> `~/.tmux/conf/`
- `~/dots/tmux/scripts/` -> `~/.tmux/scripts/`

```
~/dots/tmux/
  tmux.conf              # Entry point -- sources conf files in order
  conf/
    theme.conf           # Color palette as @theme-* variables + semantic aliases
    options.conf         # Base settings (mouse, vi-mode, terminal, numbering, history)
    keybindings.conf     # All key bindings
    statusbar.conf       # Status bar layout using theme variables
  scripts/
    git-branch.sh        # Prints current git branch or empty string
    session-save.sh      # Dumps sessions/windows/panes/dirs to ~/.tmux/sessions.txt
    session-restore.sh   # Recreates session structure from saved file
    session-picker.sh    # Fuzzy session picker (fzf if available, else choose-tree)
```

### Source Order

`tmux.conf` sources in this order:
1. `theme.conf` -- palette variables available to everything below
2. `options.conf` -- base behavior
3. `keybindings.conf` -- all binds
4. `statusbar.conf` -- bar layout (depends on theme vars)

## Theme: Tokyo Night Storm

### Color Palette

| Variable | Hex | Usage |
|---|---|---|
| `@theme-bg` | `#1a1b26` | Background, status bar bg |
| `@theme-fg` | `#a9b1d6` | Default foreground text |
| `@theme-black` | `#414868` | Inactive elements, borders |
| `@theme-red` | `#f7768e` | Errors, alerts |
| `@theme-green` | `#9ece6a` | Success, session name segment |
| `@theme-yellow` | `#e0af68` | Activity alerts, warnings |
| `@theme-blue` | `#7aa2f7` | Accent, git branch segment |
| `@theme-magenta` | `#bb9af7` | Active pane/window highlight |
| `@theme-cyan` | `#7dcfff` | Info segments, messages |
| `@theme-white` | `#c0caf5` | Bright foreground |

### Semantic Aliases

| Alias | Maps to | Purpose |
|---|---|---|
| `@theme-accent` | `@theme-blue` | Primary accent color |
| `@theme-active` | `@theme-magenta` | Active pane/window |
| `@theme-inactive` | `@theme-black` | Inactive elements |
| `@theme-alert` | `@theme-red` | Error/alert states |
| `@theme-ok` | `@theme-green` | Success/healthy states |

### Applied Styling

- **Pane borders:** inactive = `@theme-black`, active = `@theme-magenta`
- **Messages/command prompt:** bg = `@theme-bg`, fg = `@theme-cyan`
- **Copy mode highlight:** bg = `@theme-blue`, fg = `@theme-bg`

## Keybindings

### Prefix: `C-h` (unchanged)

### Splits & Navigation

| Bind | Action | Notes |
|---|---|---|
| `prefix v` | Vertical split (same dir) | Kept |
| `prefix s` | Horizontal split (same dir) | Kept |
| `prefix h/j/k/l` | Select pane (vim directions) | Kept |
| `prefix H/J/K/L` | Resize pane 5 cells | New |
| `S-Left / S-Right` | Prev/next window (no prefix) | Kept |
| `prefix c` | New window | Default, kept |
| `prefix Space` | Next layout | Kept |
| `prefix q` | Display pane numbers | Kept |
| `prefix z` | Zoom pane toggle | Default, kept |

### Sessions & Utilities

| Bind | Action | Notes |
|---|---|---|
| `prefix f` | Fuzzy session picker popup | New |
| `prefix S` | Save sessions | New |
| `prefix R` | Restore sessions | New |
| `prefix r` | Reload config | Kept |
| `prefix t` | Floating popup terminal (80x80%) | New |

### Copy Mode (vi)

| Bind | Action | Notes |
|---|---|---|
| `prefix [` | Enter copy mode | Kept |
| `v` (in copy mode) | Begin selection | New |
| `y` (in copy mode) | Yank to system clipboard (pbcopy) | New |
| `prefix ]` | Paste buffer | Kept |

### Removed

- `Alt-arrow` pane navigation (redundant with h/j/k/l)

## Status Bar

### Layout

```
LEFT:   [ session]  [ branch]
CENTER: ...window tabs...
RIGHT:  [Z]  [ spotify]  [ IP]  [ date time]
```

### Segment Details

**Left:**
- Session name: `@theme-green` bg, `@theme-bg` fg, nerdfont icon ``
- Git branch: `@theme-blue` bg, `@theme-bg` fg, nerdfont icon ``
  - Only shows when inside a git repo (script returns empty string otherwise)
  - Powerline arrow transition between segments with correct fg/bg matching

**Center (window tabs):**
- Inactive: `@theme-black` bg, `@theme-fg` fg, powerline caps
- Active: `@theme-magenta` bg, `@theme-bg` fg (bold), powerline caps
- Activity: `@theme-yellow` fg flash

**Right:**
- Zoom indicator: `Z` in `@theme-yellow` -- only visible when a pane is zoomed
- Spotify: `@theme-cyan` bg, `@theme-bg` fg, nerdfont icon ``, runs `osascript ~/dots/macos/spotify.scpt`
- IP address: `@theme-magenta` bg, `@theme-bg` fg, nerdfont icon ``
- Date/time: `@theme-green` bg, `@theme-bg` fg, nerdfont icon ``, format `%d %b %R`

**Powerline arrows:** Each transition arrow's fg = outgoing segment bg, arrow bg = incoming segment bg. This prevents the inversion bug in the current config.

### Performance

- `status-interval 5` (up from 1) -- git branch and Spotify don't need per-second updates
- Scripts are lightweight shell commands, no heavy subprocesses

## Options

| Setting | Value | Why |
|---|---|---|
| `escape-time` | `0` | No delay after Escape (vim users) |
| `history-limit` | `50000` | Generous scrollback |
| `base-index` | `1` | Windows start at 1 (kept) |
| `pane-base-index` | `1` | Panes start at 1 (kept) |
| `mouse` | `on` | Mouse support (kept) |
| `mode-keys` | `vi` | Vi copy mode (kept) |
| `renumber-windows` | `on` | Close gaps on window kill |
| `focus-events` | `on` | Vim/nvim focus detection |
| `default-terminal` | `tmux-256color` | Better color/italics support (upgraded from screen-256color) |
| `set-titles` | `on` | Terminal window titles (kept) |
| `set-titles-string` | `TMUX: #S \| #W` | Title format (kept) |
| `automatic-rename` | `on` | Auto window names (kept) |
| `monitor-activity` | `on` | Activity detection (kept) |
| `visual-activity` | `off` | Changed from on -- the status bar yellow flash is enough, no need for message spam |
| `display-panes-time` | `1500` | Pane number visibility (kept) |
| `repeat-time` | `0` | Instant arrow keys after window switch (kept) |
| `lock-after-time` | `300` | Cmatrix screensaver (kept) |
| `lock-command` | `/usr/bin/cmatrix -s -C cyan` | The classic (kept) |

## Session Persistence

### session-save.sh

Iterates all sessions, windows, panes. Writes to `~/.tmux/sessions.txt`:
```
session_name:window_index:window_name:pane_index:pane_current_path
```

### session-restore.sh

Reads `~/.tmux/sessions.txt` and recreates structure:
- Skips sessions that already exist
- Creates windows and panes with correct working directories
- Does not restore running processes (just the layout and dirs)

### session-picker.sh

- If `fzf` is available: pipes `tmux list-sessions` through fzf in a popup
- Fallback: `tmux choose-tree -s` (built-in session picker)

## Symlink Setup

User manages symlinks manually or via a setup script. Required links:
```bash
ln -sf ~/dots/tmux/tmux.conf ~/.tmux.conf
ln -sf ~/dots/tmux/conf ~/.tmux/conf
ln -sf ~/dots/tmux/scripts ~/.tmux/scripts
```

## Migration from Current Config

- Current `~/dots/linux/.tmux.conf` is replaced by the new modular structure in `~/dots/tmux/`
- The old file can be kept for reference or removed
- All existing functionality is preserved or improved
