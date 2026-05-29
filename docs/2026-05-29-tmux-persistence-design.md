# tmux session persistence across reboots — design

**Date:** 2026-05-29
**Status:** approved (pending spec review) → implementation plan next
**Scope:** `~/dots/tmux/` config + scripts, `~/dots/ghostty/config`, a macOS Login Item

## Goal

Persist tmux sessions, windows, panes, layouts, working directories, and pane
scrollback to disk so they survive a computer restart — and, critically,
**resume the correct Claude Code conversation in each pane, including multiple
Claude panes that share one working directory.** Optimise for "easiest, most
robust, low maintenance," using off-the-shelf tooling for the heavy lifting.

## Hard constraint (what is and isn't possible)

The tmux server holds session state in memory and dies on reboot. No tool on
macOS can freeze and resume a live process (Linux's CRIU has no macOS
equivalent). So "persist across restart" means **snapshot to disk, then rebuild
on restart**: layout, window/pane structure, per-pane cwd, scrollback, and
*which* programs were running are restored — programs relaunch fresh (editors
reopen files; Claude panes resume their conversation) rather than continuing
mid-execution (a running build/test does not resume).

## Current setup (discovered)

- tmux **3.6a** (brew); config symlinked from `~/dots/tmux/` — a git-tracked
  dotfiles repo (`github.com:wunzunzeroz/dots`).
- Modular config: `tmux.conf` sources `conf/{theme,options,keybindings,statusbar}.conf`.
  `~/.tmux/conf` and `~/.tmux/scripts` are symlinks into `~/dots/tmux/`.
- **No plugin manager** installed.
- Prefix is `C-h`. Lowercase `s`/`r` are bound (split / reload); uppercase
  `S`/`R` are currently a **custom** session save/restore.
- Existing custom persistence: `scripts/session-save.sh` + `session-restore.sh`
  dump `session:window:pane:cwd` to `~/.tmux/sessions.txt` and rebuild. They do
  **not** save layouts, running programs, or scrollback, and are manual-only.
- Claude workflow: `prefix+W` / `prefix+P` and `:claw` / `:clap` launch
  `claude --name <NAME>` and stamp the pane option `@claude-pane` (used by the
  status bar). Terminal is **Ghostty** (`~/.config/ghostty/config` → dots).
- Claude stores each conversation as `~/.claude/projects/<cwd-hash>/<uuid>.jsonl`
  — sessions are addressable by UUID.

### Two facts that shaped the design

1. **`claude --name` is only a display label**, not a resumable identity. The
   resumable handles are `--continue` (most-recent-in-cwd), `--resume <uuid>`,
   and `--session-id <uuid>`.
2. **Claude panes report to tmux as version strings** (`pane_current_command` =
   `2.1.150`, etc.; the `~/.local/bin/claude` launcher execs a versioned binary
   whose process title is the version). The version differs per pane and changes
   on every update, so process-name detection of Claude panes is unreliable.
   → The design therefore does **not** rely on resurrect detecting Claude by
   process name; it tracks Claude panes explicitly (see below).

## Architecture

Off-the-shelf core + a thin, well-bounded glue layer for Claude resume.

### Core stack (off-the-shelf)

- **TPM** (Tmux Plugin Manager), self-bootstrapping on first launch.
- **tmux-resurrect** — snapshots sessions/windows/panes, **layouts**, per-pane
  cwd, and **pane scrollback** (`@resurrect-capture-pane-contents on`).
- **tmux-continuum** — auto-save every 15 min + auto-restore on server start.

`@continuum-boot` is intentionally **not** used: it can only open
Terminal.app/iTerm/kitty/alacritty, not Ghostty. Auto-start-on-login is handled
Ghostty-natively instead (see "Auto-start on login").

### Claude resume — durable per-pane session IDs

Root problem: `claude --continue` resumes the *most recent* conversation in a
directory, so N Claude panes in one cwd all collapse onto the same conversation.
A pane has no Claude identity that survives a reboot (tmux pane options die with
the server; resurrect doesn't persist custom pane options).

Fix: stamp each Claude pane with its own session UUID at launch, persist a
pane→UUID map alongside resurrect's snapshot, and on restore relaunch each pane
with `--resume <its own UUID>`.

Four pieces, all on official extension points (resurrect hooks, tmux pane
options + `respawn-pane`, Claude's `--session-id`/`--resume`):

1. **Launch wrapper** `scripts/claude-pane.sh` — replaces the inline
   `claude --name %%` in `prefix+W` / `prefix+P` and `:claw` / `:clap`.
   - New session: generate a UUID, stamp the pane
     (`set -p @claude-session-id <uuid>` + `@claude-pane <name>`), then
     `exec claude --session-id <uuid> --name <name>`.
   - Resume mode (given an existing UUID): re-stamp the pane and
     `exec claude --resume <uuid> --name <name>`.
   - On Claude exit/failure, fall back to a shell so the pane doesn't vanish.

2. **post-save hook** (`@resurrect-hook-post-save-all`) → `scripts/resurrect-save-claude.sh`
   writes `claude-panes.tsv` into resurrect's snapshot dir (resolved
   dynamically from `@resurrect-dir`; XDG default `~/.local/share/tmux/resurrect`
   on this machine): `session ⇥ window ⇥ pane ⇥ cwd ⇥ session-id ⇥ name` for
   every pane carrying `@claude-session-id`. (continuum's 15-min auto-save
   invokes this too.)

3. **post-restore hook** (`@resurrect-hook-post-restore-all`) → `scripts/resurrect-restore-claude.sh`
   reads the sidecar and, for each entry,
   `respawn-pane -k -c <cwd> -t <session:window.pane> "claude-pane.sh <name> <uuid>"`
   — deterministically resuming the exact conversation in the exact pane, even
   several in one cwd. Re-stamping the pane also **restores the status-bar
   Claude labels**, which the vanilla setup would lose.

4. Claude is left **out** of `@resurrect-processes`, so resurrect restores those
   panes as bare shells in the right cwd and the hook respawns them. Ad-hoc
   `claude` typed by hand (not via a keybind) carries no UUID → returns as a
   shell to re-run (accepted best-effort tier).

### Replace the existing custom save/restore

- **Delete** `scripts/session-save.sh` and `scripts/session-restore.sh`.
- Rebind to resurrect, preserving muscle memory: `set -g @resurrect-save 'S'`,
  `set -g @resurrect-restore 'R'`; remove the two custom `bind S` / `bind R`
  lines. No conflict with lowercase `s` (split) / `r` (reload).

### Auto-start on login (Ghostty-native)

- Add **Ghostty** to macOS Login Items via an idempotent `osascript` helper
  (`scripts/setup-login-item.sh`), run once.
- `~/dots/ghostty/config` gets `command = ~/.tmux/scripts/ghostty-tmux.sh`, a
  launcher that drops every Ghostty surface into tmux: first launch starts the
  server (continuum auto-restores the snapshot), later windows attach.

## Files

New / edited under `~/dots/`:

| File | Change |
|------|--------|
| `tmux/conf/plugins.conf` | **new** — TPM plugin list + resurrect/continuum settings + hook paths |
| `tmux/tmux.conf` | **edit** — source `plugins.conf`; TPM bootstrap; `run '~/.tmux/plugins/tpm/tpm'` as final line |
| `tmux/conf/keybindings.conf` | **edit** — route `W`/`P` + `:claw`/`:clap` through `claude-pane.sh`; remove custom `bind S`/`bind R` |
| `tmux/scripts/claude-pane.sh` | **new** — launch/resume wrapper |
| `tmux/scripts/resurrect-save-claude.sh` | **new** — post-save hook |
| `tmux/scripts/resurrect-restore-claude.sh` | **new** — post-restore hook |
| `tmux/scripts/ghostty-tmux.sh` | **new** — Ghostty launch-into-tmux |
| `tmux/scripts/setup-login-item.sh` | **new** — one-time Login Item helper |
| `tmux/scripts/session-save.sh` | **delete** |
| `tmux/scripts/session-restore.sh` | **delete** |
| `ghostty/config` | **edit** — add `command = …/ghostty-tmux.sh` |

Plugin clones live in `~/.tmux/plugins/` (a real dir outside the dots repo —
nothing to gitignore).

### `conf/plugins.conf` (proposed)

```tmux
# Plugins (TPM)
set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'tmux-plugins/tmux-resurrect'
set -g @plugin 'tmux-plugins/tmux-continuum'

# resurrect
set -g @resurrect-capture-pane-contents 'on'
set -g @resurrect-save 'S'        # prefix+S
set -g @resurrect-restore 'R'     # prefix+R
set -g @resurrect-hook-post-save-all   '~/.tmux/scripts/resurrect-save-claude.sh'
set -g @resurrect-hook-post-restore-all '~/.tmux/scripts/resurrect-restore-claude.sh'

# continuum
set -g @continuum-save-interval '15'
set -g @continuum-restore 'on'
# @continuum-boot deliberately unset — Ghostty handles login start.
```

### `tmux.conf` tail (proposed)

```tmux
source-file "$HOME/.tmux/conf/plugins.conf"

# Auto-install TPM on first launch, then load plugins (must be last).
if "test ! -d ~/.tmux/plugins/tpm" \
   "run 'git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm && ~/.tmux/plugins/tpm/bin/install_plugins'"
run '~/.tmux/plugins/tpm/tpm'
```

Script contents (`claude-pane.sh`, the two hooks, `ghostty-tmux.sh`,
`setup-login-item.sh`) are sketched in the discussion and will be finalised in
the implementation plan; exact quoting and timing get pinned with tests.

## What survives a reboot

- ✅ Sessions, windows, panes, **layouts**, per-pane cwd, pane **scrollback**.
- ✅ Claude panes resumed to their **exact** conversation (incl. multiple in one
  cwd) when launched via the keybinds; status labels restored.
- ⚠️ Ad-hoc `claude` typed by hand → returns as a shell (re-run manually).
- ❌ Live in-flight process state (running build/test, unsaved REPL) — not
  recoverable on macOS by any tool.

## Open risks / to verify during implementation

1. **Keystone:** `claude --session-id <uuid>` creates a resumable interactive
   session and `claude --resume <uuid>` later resumes it; `--resume` + `--name`
   combine. (Storage-by-UUID already confirmed.) Verify first — everything in
   the Claude-resume layer depends on it.
2. **Pane addressing:** resurrect preserves `session:window_index.pane_index`
   across restore so the restore hook can target panes. Verify against a real
   save file; the sidecar carries cwd so `respawn-pane -c` fixes the directory
   regardless.
3. **Ghostty launch wiring:** `ghostty-tmux.sh` must land in the restored
   sessions without spawning a stray empty session and must tolerate the
   restore-vs-attach timing. Candidate: start server, briefly wait for
   continuum-restore, then `attach`. Pin with a real reboot test.
4. **Hook quoting:** window/pane names may contain spaces (e.g. "App Check") —
   the restore hook must quote names safely (`printf %q`).
5. **Resume failure:** if a conversation's `.jsonl` is gone, `--resume` errors —
   the wrapper falls back to a shell so the pane survives.

## Out of scope

- Headless launchd tmux server (Approach C) — rejected for higher maintenance.
- Restoring arbitrary non-Claude programs with arguments beyond resurrect's
  defaults.
- Syncing the resurrect snapshot across machines.
