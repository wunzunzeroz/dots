# Aerospace Configuration Redesign

## Overview

Overhaul of the AeroSpace tiling window manager config for a vim-centric, keyboard-driven workflow across a 2-monitor docked setup (LG Ultrawide + MacBook) with graceful degradation to single-monitor undocked mode.

### Design Principles

- **Modifier hierarchy:** vim (single keys) < tmux (ctrl-prefix) < Aerospace (cmd-ctrl) — the higher the abstraction, the heavier the chord
- **Hybrid modal:** direct bindings for frequent actions, vim-like sub-modes for multi-step operations (resize)
- **Deterministic placement:** every app has a home workspace, every workspace has a home monitor
- **Dock-agnostic keybindings:** same keys work docked or undocked; only the physical screen changes

---

## Workspace Structure

### Docked Mode (LG Ultrawide + MacBook)

| Workspace | Monitor | Apps | Layout |
|-----------|---------|------|--------|
| `main:1:dev` | LG Ultrawide | Arc + Ghostty | h_tiles (side-by-side) |
| `main:2:code` | LG Ultrawide | Zed | single |
| `main:3:data` | LG Ultrawide | Firefoo | single |
| `side:1:todo` | MacBook | Todoist | single |
| `side:2:notes` | MacBook | Obsidian | single |
| `side:3:slack` | MacBook | Slack | single |
| `side:4:web` | MacBook | Chrome | single |
| `side:5:music` | MacBook | Spotify | single |
| `side:6:msg` | MacBook | WhatsApp | single |

### Undocked Mode (MacBook only)

All workspaces move to the MacBook display. Same names, same keybindings. No workspace culling — everything stays available, low-numbered keys remain the most-used workspaces.

---

## Keybindings

### Direct Actions (main mode)

#### Workspace Jumping

| Binding | Action |
|---------|--------|
| `cmd-ctrl-1` | `workspace main:1:dev` |
| `cmd-ctrl-2` | `workspace main:2:code` |
| `cmd-ctrl-3` | `workspace main:3:data` |
| `cmd-ctrl-4` | `workspace side:1:todo` |
| `cmd-ctrl-5` | `workspace side:2:notes` |
| `cmd-ctrl-6` | `workspace side:3:slack` |
| `cmd-ctrl-7` | `workspace side:4:web` |
| `cmd-ctrl-8` | `workspace side:5:music` |
| `cmd-ctrl-9` | `workspace side:6:msg` |

Numbering logic: 1-3 = main monitor (deep work), 4-9 = side monitor (comms/support).

#### Focus Navigation

| Binding | Action | Description |
|---------|--------|-------------|
| `cmd-ctrl-h` | `focus left` | focus window left (within workspace) |
| `cmd-ctrl-l` | `focus right` | focus window right |
| `cmd-ctrl-j` | `focus down` | focus window down |
| `cmd-ctrl-k` | `focus up` | focus window up |
| `cmd-ctrl-m` | `focus-monitor --wrap-around next` | hop between monitors |
| `cmd-ctrl-tab` | `workspace-back-and-forth` | toggle last workspace (like ctrl-^ in vim) |

#### Move Window to Workspace

| Binding | Action |
|---------|--------|
| `cmd-ctrl-shift-1` | `move-node-to-workspace main:1:dev` |
| `cmd-ctrl-shift-2` | `move-node-to-workspace main:2:code` |
| `cmd-ctrl-shift-3` | `move-node-to-workspace main:3:data` |
| `cmd-ctrl-shift-4` | `move-node-to-workspace side:1:todo` |
| `cmd-ctrl-shift-5` | `move-node-to-workspace side:2:notes` |
| `cmd-ctrl-shift-6` | `move-node-to-workspace side:3:slack` |
| `cmd-ctrl-shift-7` | `move-node-to-workspace side:4:web` |
| `cmd-ctrl-shift-8` | `move-node-to-workspace side:5:music` |
| `cmd-ctrl-shift-9` | `move-node-to-workspace side:6:msg` |

Adding shift to a workspace jump moves the focused window there.

#### Workspace Cycling

| Binding | Action | Description |
|---------|--------|-------------|
| `cmd-ctrl-n` | `workspace --wrap-around next` | next workspace on current monitor |
| `cmd-ctrl-p` | `workspace --wrap-around prev` | prev workspace on current monitor |

#### Layout Toggling

| Binding | Action | Description |
|---------|--------|-------------|
| `cmd-ctrl-/` | `layout tiles h_accordion` | toggle side-by-side vs stacked |
| `cmd-ctrl-f` | `fullscreen` | toggle fullscreen |
| `cmd-ctrl-t` | `layout floating tiling` | toggle floating/tiling |

#### Dock Toggle

| Binding | Action |
|---------|--------|
| `cmd-ctrl-d` | `exec-and-forget ~/.config/aerospace/dock-toggle.sh` |

### Resize Mode

Enter with `cmd-ctrl-r`. Single keys operate within the mode. Exit with `escape` or `enter`.

| Binding | Action | Description |
|---------|--------|-------------|
| `h` | `resize width -50` | nudge narrower |
| `l` | `resize width +50` | nudge wider |
| `j` | `resize height +50` | nudge taller |
| `k` | `resize height -50` | nudge shorter |
| `e` | `balance-sizes` | equal split (50/50) |
| `1` | `balance-sizes` then `resize width +N` | preset: focused window 70% |
| `2` | `balance-sizes` then `resize width -N` | preset: focused window 30% |
| `escape` | `mode main` | exit resize mode |
| `enter` | `mode main` | exit resize mode |

The exact pixel offset for 70/30 presets will be calculated during implementation based on `balance-sizes` baseline behavior.

---

## App-to-Workspace Rules

| App | App ID | Workspace |
|-----|--------|-----------|
| Arc | `company.thebrowser.Browser` | `main:1:dev` |
| Ghostty | `com.mitchellh.ghostty` | `main:1:dev` |
| Zed | `dev.zed.Zed` | `main:2:code` |
| Firefoo | `com.electron.firefoo` | `main:3:data` |
| Todoist | `com.todoist.mac.Todoist` | `side:1:todo` |
| Obsidian | `md.obsidian` | `side:2:notes` |
| Slack | `com.tinyspeck.slackmacgap` | `side:3:slack` |
| Chrome | `com.google.Chrome` | `side:4:web` |
| Spotify | `com.spotify.client` | `side:5:music` |
| WhatsApp | `net.whatsapp.WhatsApp` | `side:6:msg` |

Removed: Alacritty (`org.alacritty`), Bruno (`com.usebruno.app`)
Added: Ghostty (`com.mitchellh.ghostty`), Obsidian (`md.obsidian`)

---

## Dock Toggle Script

`~/.config/aerospace/dock-toggle.sh` — smart mode that detects monitor count.

### Behavior

1. Run `aerospace list-monitors` to count connected monitors
2. **If 1 monitor (undocked):** all workspaces are already on the single display; no action needed beyond clearing stale monitor assignments
3. **If 2 monitors (docked):** move `main:*` workspaces to the LG, `side:*` to the MacBook using `move-workspace-to-monitor`

The script is idempotent — pressing `cmd-ctrl-d` multiple times is safe. Workspace-to-monitor force assignments in the TOML handle the steady state; the script handles transitions.

---

## Removed Features

- Alacritty app rule (replaced by Ghostty)
- Bruno app rule (no longer used)
- Portable monitor (ASUS) configuration
- Commented-out alt-key workspace bindings (replaced by cmd-ctrl-number scheme)
- Commented-out alt-shift move bindings (replaced by cmd-ctrl-shift-number scheme)
