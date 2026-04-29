# Aerospace Config Redesign Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Overhaul the AeroSpace config for a vim-centric keyboard workflow with direct workspace jumping, resize modes, layout toggling, and graceful docking/undocking.

**Architecture:** Single TOML config file (`aerospace/aerospace.toml`) with a companion shell script (`aerospace/dock-toggle.sh`) for manual dock/undock transitions. The TOML uses monitor fallback arrays so workspaces degrade gracefully when the LG is disconnected. The shell script handles active redistribution when monitors change mid-session.

**Tech Stack:** AeroSpace WM (TOML config), Bash (dock script), `jq` (JSON parsing in script)

---

### Task 1: Rewrite Workspace Structure and Monitor Assignments

**Files:**
- Modify: `aerospace/aerospace.toml` (full rewrite of workspace-to-monitor section)

- [ ] **Step 1: Replace the header comment block**

Replace the entire file contents with the new general settings and workspace-to-monitor assignments:

```toml

############################################
# Aerospace – Vim-Centric Desk Config
# Monitors:
# - LG Ultrawide (main – deep work)
# - MacBook built-in (side – comms & ops)
#
# Modifier hierarchy:
#   vim (single keys) < tmux (ctrl-prefix) < Aerospace (cmd-ctrl)
#
# Hybrid modal:
#   Direct bindings for frequent actions
#   Vim-like sub-modes for multi-step ops (resize)
############################################


############################################
# General behaviour
############################################

start-at-login = true

enable-normalization-flatten-containers = true
enable-normalization-opposite-orientation-for-nested-containers = true

default-root-container-layout = "tiles"
default-root-container-orientation = "horizontal"


############################################
# Workspace → Monitor assignment
############################################
# Each workspace prefers its home monitor but falls back
# to the built-in display when undocked.

[workspace-to-monitor-force-assignment]

# Main (LG Ultrawide) – deep work
"main:1:dev"   = ["LG ULTRAWIDE", "Built-in Retina Display"]
"main:2:code"  = ["LG ULTRAWIDE", "Built-in Retina Display"]
"main:3:data"  = ["LG ULTRAWIDE", "Built-in Retina Display"]

# Side (MacBook) – comms & ops
"side:1:todo"  = "Built-in Retina Display"
"side:2:notes" = "Built-in Retina Display"
"side:3:slack" = "Built-in Retina Display"
"side:4:web"   = "Built-in Retina Display"
"side:5:music" = "Built-in Retina Display"
"side:6:msg"   = "Built-in Retina Display"
```

- [ ] **Step 2: Verify the config parses**

Run:
```bash
aerospace reload-config
```
Expected: no error output. If Aerospace isn't running, run `aerospace list-workspaces --all` to at least verify the binary can read the config.

- [ ] **Step 3: Commit**

```bash
git add aerospace/aerospace.toml
git commit -m "feat(aerospace): rewrite workspace structure and monitor assignments"
```

---

### Task 2: Add App-to-Workspace Rules

**Files:**
- Modify: `aerospace/aerospace.toml` (append after workspace-to-monitor section)

- [ ] **Step 1: Append app detection rules**

Add the following after the `[workspace-to-monitor-force-assignment]` section:

```toml


############################################
# App → Workspace rules
############################################

# Arc Browser → dev workspace (paired with Ghostty)
[[on-window-detected]]
if.app-id = "company.thebrowser.Browser"
run = ["move-node-to-workspace main:1:dev"]

# Ghostty terminal → dev workspace (paired with Arc)
[[on-window-detected]]
if.app-id = "com.mitchellh.ghostty"
run = ["move-node-to-workspace main:1:dev"]

# Zed editor
[[on-window-detected]]
if.app-id = "dev.zed.Zed"
run = ["move-node-to-workspace main:2:code"]

# Firefoo (Firestore GUI)
[[on-window-detected]]
if.app-id = "com.electron.firefoo"
run = ["move-node-to-workspace main:3:data"]

# Todoist
[[on-window-detected]]
if.app-id = "com.todoist.mac.Todoist"
run = ["move-node-to-workspace side:1:todo"]

# Obsidian
[[on-window-detected]]
if.app-id = "md.obsidian"
run = ["move-node-to-workspace side:2:notes"]

# Slack
[[on-window-detected]]
if.app-id = "com.tinyspeck.slackmacgap"
run = ["move-node-to-workspace side:3:slack"]

# Chrome
[[on-window-detected]]
if.app-id = "com.google.Chrome"
run = ["move-node-to-workspace side:4:web"]

# Spotify
[[on-window-detected]]
if.app-id = "com.spotify.client"
run = ["move-node-to-workspace side:5:music"]

# WhatsApp
[[on-window-detected]]
if.app-id = "net.whatsapp.WhatsApp"
run = ["move-node-to-workspace side:6:msg"]
```

- [ ] **Step 2: Reload and verify**

Run:
```bash
aerospace reload-config
```
Expected: no errors.

- [ ] **Step 3: Commit**

```bash
git add aerospace/aerospace.toml
git commit -m "feat(aerospace): add app-to-workspace detection rules"
```

---

### Task 3: Add Direct Keybindings (Main Mode)

**Files:**
- Modify: `aerospace/aerospace.toml` (append keybindings section)

- [ ] **Step 1: Append main mode keybindings**

Add the following after the app rules section:

```toml


############################################
# Key bindings – main mode
############################################

[mode.main.binding]

# ── Workspace jumping (direct) ──────────────
# 1-3 = main monitor (deep work)
# 4-9 = side monitor (comms/support)
cmd-ctrl-1 = "workspace main:1:dev"
cmd-ctrl-2 = "workspace main:2:code"
cmd-ctrl-3 = "workspace main:3:data"
cmd-ctrl-4 = "workspace side:1:todo"
cmd-ctrl-5 = "workspace side:2:notes"
cmd-ctrl-6 = "workspace side:3:slack"
cmd-ctrl-7 = "workspace side:4:web"
cmd-ctrl-8 = "workspace side:5:music"
cmd-ctrl-9 = "workspace side:6:msg"

# ── Workspace cycling ───────────────────────
cmd-ctrl-n = "workspace --wrap-around next"
cmd-ctrl-p = "workspace --wrap-around prev"
cmd-ctrl-tab = "workspace-back-and-forth"

# ── Focus navigation (vim hjkl) ─────────────
cmd-ctrl-h = "focus left"
cmd-ctrl-j = "focus down"
cmd-ctrl-k = "focus up"
cmd-ctrl-l = "focus right"
cmd-ctrl-m = "focus-monitor --wrap-around next"

# ── Move window to workspace ────────────────
cmd-ctrl-shift-1 = "move-node-to-workspace main:1:dev"
cmd-ctrl-shift-2 = "move-node-to-workspace main:2:code"
cmd-ctrl-shift-3 = "move-node-to-workspace main:3:data"
cmd-ctrl-shift-4 = "move-node-to-workspace side:1:todo"
cmd-ctrl-shift-5 = "move-node-to-workspace side:2:notes"
cmd-ctrl-shift-6 = "move-node-to-workspace side:3:slack"
cmd-ctrl-shift-7 = "move-node-to-workspace side:4:web"
cmd-ctrl-shift-8 = "move-node-to-workspace side:5:music"
cmd-ctrl-shift-9 = "move-node-to-workspace side:6:msg"

# ── Layout toggles ─────────────────────────
cmd-ctrl-slash = "layout tiles h_accordion"
cmd-ctrl-f = "fullscreen"
cmd-ctrl-t = "layout floating tiling"

# ── Modes ───────────────────────────────────
cmd-ctrl-r = "mode resize"

# ── Dock toggle ─────────────────────────────
cmd-ctrl-d = "exec-and-forget bash ~/.config/aerospace/dock-toggle.sh"
```

- [ ] **Step 2: Reload and verify**

Run:
```bash
aerospace reload-config
```
Expected: no errors.

- [ ] **Step 3: Quick smoke test**

Test a few bindings manually:
- Press `cmd-ctrl-1` — should switch to `main:1:dev` workspace
- Press `cmd-ctrl-h` / `cmd-ctrl-l` — should move focus between windows if you have two on the workspace
- Press `cmd-ctrl-n` / `cmd-ctrl-p` — should cycle workspaces

- [ ] **Step 4: Commit**

```bash
git add aerospace/aerospace.toml
git commit -m "feat(aerospace): add vim-style direct keybindings"
```

---

### Task 4: Add Resize Mode

**Files:**
- Modify: `aerospace/aerospace.toml` (append resize mode section)

- [ ] **Step 1: Append resize mode keybindings**

Add the following after the main mode bindings:

```toml


############################################
# Key bindings – resize mode
############################################
# Enter: cmd-ctrl-r
# Exit:  escape or enter
# hjkl to nudge, e to equalise, 1/2 for presets

[mode.resize.binding]

# Nudge (incremental)
h = "resize width -50"
l = "resize width +50"
j = "resize height +50"
k = "resize height -50"

# Equal split (50/50)
e = ["balance-sizes", "mode main"]

# Preset: focused window ~70%
1 = ["balance-sizes", "resize width +200", "mode main"]

# Preset: focused window ~30%
2 = ["balance-sizes", "resize width -200", "mode main"]

# Exit resize mode
escape = "mode main"
enter = "mode main"
```

Note on the presets: `balance-sizes` resets to 50/50, then `resize width +200` grows the focused window by 200px. On a typical workspace this produces roughly a 70/30 split. The exact ratio depends on monitor width — 200px is a sensible starting point that can be tuned. The presets auto-exit to main mode after applying.

- [ ] **Step 2: Reload and test resize mode**

Run:
```bash
aerospace reload-config
```

Then test manually:
1. Open two windows on the same workspace (e.g., Arc + Ghostty on `main:1:dev`)
2. Press `cmd-ctrl-r` to enter resize mode
3. Press `l` a few times — the focused window should grow wider
4. Press `e` — windows should equalise and you return to main mode
5. Press `cmd-ctrl-r` again, then `1` — focused window should take ~70% and you return to main mode

- [ ] **Step 3: Tune preset values if needed**

If 200px doesn't produce a good 70/30 split on the LG Ultrawide, adjust the value. For a 3440px ultrawide, `+400` may be more appropriate. Test and adjust the `resize width` values for presets `1` and `2` until they feel right.

- [ ] **Step 4: Commit**

```bash
git add aerospace/aerospace.toml
git commit -m "feat(aerospace): add resize mode with hjkl nudge and presets"
```

---

### Task 5: Create Dock Toggle Script

**Files:**
- Create: `aerospace/dock-toggle.sh`

- [ ] **Step 1: Create the dock toggle script**

Create `aerospace/dock-toggle.sh`:

```bash
#!/usr/bin/env bash
#
# dock-toggle.sh — Smart dock/undock for Aerospace
# Detects monitor count and redistributes workspaces accordingly.
# Idempotent: safe to run multiple times.
#
# Usage: bound to cmd-ctrl-d in aerospace.toml
#        exec-and-forget bash ~/.config/aerospace/dock-toggle.sh

set -euo pipefail

AEROSPACE="/opt/homebrew/bin/aerospace"
MONITOR_COUNT=$("$AEROSPACE" list-monitors --json | /usr/bin/jq length)

LG_PATTERN="LG ULTRAWIDE"
BUILTIN_PATTERN="Built-in Retina Display"

# Find the monitor ID for the LG (if connected)
LG_ID=$("$AEROSPACE" list-monitors --json | /usr/bin/jq -r ".[] | select(.\"monitor-name\" | test(\"$LG_PATTERN\"; \"i\")) | .\"monitor-id\"")

if [ "$MONITOR_COUNT" -ge 2 ] && [ -n "$LG_ID" ]; then
    # Docked: move main workspaces to the LG
    "$AEROSPACE" move-workspace-to-monitor --workspace "main:1:dev" "$LG_ID" 2>/dev/null || true
    "$AEROSPACE" move-workspace-to-monitor --workspace "main:2:code" "$LG_ID" 2>/dev/null || true
    "$AEROSPACE" move-workspace-to-monitor --workspace "main:3:data" "$LG_ID" 2>/dev/null || true
else
    # Undocked: move everything to the single available monitor
    BUILTIN_ID=$("$AEROSPACE" list-monitors --json | /usr/bin/jq -r ".[0].\"monitor-id\"")
    for ws in $("$AEROSPACE" list-workspaces --all); do
        "$AEROSPACE" move-workspace-to-monitor --workspace "$ws" "$BUILTIN_ID" 2>/dev/null || true
    done
fi
```

Note: `move-workspace-to-monitor` may fail for workspaces with force-assignment. The `2>/dev/null || true` suppresses those errors — the force-assignment fallback arrays in the TOML handle the steady state. This script is for nudging workspaces into place during a transition.

- [ ] **Step 2: Make it executable**

Run:
```bash
chmod +x aerospace/dock-toggle.sh
```

- [ ] **Step 3: Set up the symlink target**

The aerospace.toml references `~/.config/aerospace/dock-toggle.sh`. Verify the symlink or install path for the dots repo. If the dots repo uses a symlink strategy (like stow or manual links), ensure the script will be reachable at `~/.config/aerospace/dock-toggle.sh`.

Run:
```bash
ls -la ~/.config/aerospace/ 2>/dev/null || echo "directory does not exist yet"
```

If the directory doesn't exist or the symlink isn't set up, create it:
```bash
mkdir -p ~/.config/aerospace
ln -sf "$(pwd)/aerospace/dock-toggle.sh" ~/.config/aerospace/dock-toggle.sh
```

- [ ] **Step 4: Test the script manually**

Run:
```bash
bash aerospace/dock-toggle.sh
```
Expected: no errors. If docked (2 monitors), main workspaces should move to the external display. If undocked (1 monitor), no visible change but no errors.

- [ ] **Step 5: Commit**

```bash
git add aerospace/dock-toggle.sh
git commit -m "feat(aerospace): add smart dock/undock toggle script"
```

---

### Task 6: Final Integration Test and Cleanup

**Files:**
- Verify: `aerospace/aerospace.toml` (full file review)
- Verify: `aerospace/dock-toggle.sh`

- [ ] **Step 1: Reload the full config**

Run:
```bash
aerospace reload-config
```
Expected: no errors.

- [ ] **Step 2: Full smoke test**

Walk through each binding category:

1. **Workspace jumping:** `cmd-ctrl-1` through `cmd-ctrl-9` — each should jump to the correct workspace
2. **Focus navigation:** On `main:1:dev` with Arc + Ghostty open, `cmd-ctrl-h`/`cmd-ctrl-l` should switch focus between them
3. **Monitor focus:** `cmd-ctrl-m` should hop focus to the other monitor
4. **Back and forth:** `cmd-ctrl-tab` should toggle between last two workspaces
5. **Workspace cycling:** `cmd-ctrl-n`/`cmd-ctrl-p` should cycle through workspaces on the current monitor
6. **Move window:** Focus a window, `cmd-ctrl-shift-2` should move it to `main:2:code`
7. **Layout toggle:** `cmd-ctrl-/` should toggle between tiles and accordion
8. **Fullscreen:** `cmd-ctrl-f` should toggle fullscreen
9. **Float toggle:** `cmd-ctrl-t` should toggle floating
10. **Resize mode:** `cmd-ctrl-r` enters resize, `h`/`l` nudge, `e` equalises, `1`/`2` for presets, `escape` exits
11. **Dock toggle:** `cmd-ctrl-d` should run without errors

- [ ] **Step 3: Verify app placement**

Quit and relaunch a few apps to verify on-window-detected rules:
- Launch Ghostty — should land on `main:1:dev`
- Launch Chrome — should land on `side:4:web`

- [ ] **Step 4: Final commit if any tuning was needed**

If preset values or other details were adjusted during testing:
```bash
git add aerospace/aerospace.toml aerospace/dock-toggle.sh
git commit -m "fix(aerospace): tune resize presets after testing"
```
