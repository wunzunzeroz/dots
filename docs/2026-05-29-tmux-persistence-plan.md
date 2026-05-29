# tmux Session Persistence Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Persist tmux sessions/windows/panes/layouts/cwd/scrollback across reboots, auto-restoring on login, and resume the correct Claude conversation per pane — including multiple Claude panes in one directory.

**Architecture:** Off-the-shelf core (TPM + tmux-resurrect + tmux-continuum) does the snapshotting and auto-save/restore. A thin glue layer teaches it the one thing it can't know — which Claude conversation each pane held — via durable per-pane session UUIDs, a sidecar file written by resurrect's post-save hook, and a post-restore hook that resumes each pane by exact UUID. Login auto-start is Ghostty-native (Login Item + launch-into-tmux script), since continuum's boot feature can't target Ghostty.

**Tech Stack:** tmux 3.6a, TPM, tmux-resurrect, tmux-continuum, bash, Ghostty, macOS `osascript`/Login Items, Claude Code CLI (`--session-id`/`--resume`).

**Reference spec:** `~/dots/docs/2026-05-29-tmux-persistence-design.md`

**Working repo:** all tracked files live under `~/dots/` (`~/.tmux/conf` and `~/.tmux/scripts` are symlinks into it). Plugin clones live in `~/.tmux/plugins/` (untracked, outside the repo). Commit after each task.

**Safety:** You have 4 live sessions with running Claude conversations. Config reloads (`source-file`) and saves are non-destructive. The **restore** path runs `respawn-pane -k` (kills + relaunches a pane's process), so it is **only ever exercised on an isolated test socket** (Task 6) until the real reboot test (Task 9). Never run the restore hook against the live server during development.

---

## Task 0: Verify the keystone assumption (`--session-id` / `--resume` round-trip)

Everything in the Claude-resume layer depends on this. It is a manual, interactive check — do it first.

**Files:** none.

- [ ] **Step 1: Create a session with a known UUID**

In a scratch terminal pane (not one of your working Claude panes), run:

```bash
TESTID=$(uuidgen | tr '[:upper:]' '[:lower:]'); echo "$TESTID"
cd /tmp
claude --session-id "$TESTID" --name keystone-test
```

In the Claude session, send one message (e.g. "remember the word PELICAN"), then quit (`Ctrl-C` twice / `/exit`).

- [ ] **Step 2: Resume by that exact UUID**

```bash
cd /tmp
claude --resume "$TESTID" --name keystone-test
```

Expected: the prior conversation loads (ask "what word did I tell you?" → it recalls PELICAN). Confirm `--resume` + `--name` coexist without error.

- [ ] **Step 3: Confirm the transcript on disk**

Run: `ls ~/.claude/projects/-tmp/ | grep "$TESTID"`
Expected: a file `<TESTID>.jsonl` exists.

- [ ] **Step 4: Decision gate**

If resume works → proceed. If `--session-id` is rejected for interactive sessions or `--resume`+`--name` conflict, STOP and revisit the spec's Claude-resume layer (fallback: drop `--name` from the resume call, or use `--session-id` on both legs if re-running an existing id resumes). Record the outcome before continuing.

- [ ] **Step 5: Commit the spec (now that the keystone holds)**

```bash
cd ~/dots
git add docs/2026-05-29-tmux-persistence-design.md docs/2026-05-29-tmux-persistence-plan.md
git commit -m "docs(tmux): session-persistence design + implementation plan"
```

---

## Task 1: Install the core stack (TPM + resurrect + continuum)

**Files:**
- Create: `~/dots/tmux/conf/plugins.conf`
- Modify: `~/dots/tmux/tmux.conf` (append plugin sourcing + TPM bootstrap)

- [ ] **Step 1: Create `conf/plugins.conf`**

```tmux
# Plugins -- managed by TPM. Settings must be set before `run tpm` (in tmux.conf).

# Plugin list
set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'tmux-plugins/tmux-resurrect'
set -g @plugin 'tmux-plugins/tmux-continuum'

# --- tmux-resurrect ---
# Capture pane scrollback into the snapshot.
set -g @resurrect-capture-pane-contents 'on'
# Rebind save/restore to S / R (preserves muscle memory; replaces old scripts).
set -g @resurrect-save 'S'
set -g @resurrect-restore 'R'
# NOTE: Claude panes are intentionally NOT in @resurrect-processes; they are
# handled by the save/restore hooks added in Tasks 5 and 6.

# --- tmux-continuum ---
set -g @continuum-save-interval '15'
set -g @continuum-restore 'on'
# @continuum-boot deliberately unset -- Ghostty handles login start (Task 7/8).
```

- [ ] **Step 2: Append plugin loading to `tmux.conf`**

Add these lines at the **end** of `~/dots/tmux/tmux.conf` (after the existing `source-file` lines). `run '...tpm'` MUST be the last line:

```tmux

# --- Plugins (TPM) ---
source-file "$HOME/.tmux/conf/plugins.conf"

# Auto-install TPM on first launch, then load plugins (keep this last).
if "test ! -d ~/.tmux/plugins/tpm" \
   "run 'git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm && ~/.tmux/plugins/tpm/bin/install_plugins'"
run '~/.tmux/plugins/tpm/tpm'
```

- [ ] **Step 3: Reload config and let TPM bootstrap**

Run: `tmux source-file ~/.tmux.conf`
Wait ~10s (TPM clones + installs). Then verify:

Run: `ls ~/.tmux/plugins/`
Expected: `tmux-continuum  tmux-resurrect  tpm`

- [ ] **Step 4: Take a first safety snapshot of current live state**

Run: `~/.tmux/plugins/tmux-resurrect/scripts/save.sh`
Then: `ls -l ~/.tmux/resurrect/last && cat ~/.tmux/resurrect/last | head -5`
Expected: a `last` symlink → a `tmux_resurrect_*.txt` file listing your current sessions/windows/panes. (This is your rollback safety net.)

- [ ] **Step 5: Commit**

```bash
cd ~/dots
git add tmux/conf/plugins.conf tmux/tmux.conf
git commit -m "feat(tmux): add TPM + resurrect + continuum core"
```

---

## Task 2: Retire the custom save/restore scripts

**Files:**
- Delete: `~/dots/tmux/scripts/session-save.sh`, `~/dots/tmux/scripts/session-restore.sh`
- Modify: `~/dots/tmux/conf/keybindings.conf` (remove the custom `bind S` / `bind R`)

- [ ] **Step 1: Remove the custom bindings**

In `~/dots/tmux/conf/keybindings.conf`, delete this block (under `# SESSION MANAGEMENT`):

```tmux
# Save and restore sessions
bind S run-shell "$HOME/.tmux/scripts/session-save.sh"
bind R run-shell "$HOME/.tmux/scripts/session-restore.sh"
```

(Leave the `prefix+f` / `prefix+w` picker binds intact.)

- [ ] **Step 2: Delete the scripts**

```bash
cd ~/dots
git rm tmux/scripts/session-save.sh tmux/scripts/session-restore.sh
```

- [ ] **Step 3: Reload and verify S/R now belong to resurrect**

Run: `tmux source-file ~/.tmux.conf`
Run: `tmux list-keys | grep -E "bind-key.* [SR] "`
Expected: `S` and `R` are bound to `run-shell` invoking the resurrect `save.sh` / `restore.sh` (paths under `tmux-resurrect/scripts/`), not the deleted scripts.

- [ ] **Step 4: Commit**

```bash
cd ~/dots
git add -A tmux/
git commit -m "refactor(tmux): retire custom session scripts; S/R now resurrect"
```

---

## Task 3: Claude launch wrapper (`claude-pane.sh`)

**Files:**
- Create: `~/dots/tmux/scripts/claude-pane.sh`

- [ ] **Step 1: Write the wrapper**

```bash
#!/usr/bin/env bash
# Launch or resume a Claude Code session in the current tmux pane, stamping the
# pane with its session id + display name so it can be saved and restored across
# reboots (see resurrect-save-claude.sh / resurrect-restore-claude.sh).
#
#   claude-pane.sh <name>              # new session (fresh uuid)
#   claude-pane.sh <name> <session-id> # resume an existing session by id
set -u

name="${1:-claude}"
sid="${2:-}"

if [ -z "$sid" ]; then
  sid="$(uuidgen | tr '[:upper:]' '[:lower:]')"
  set -- --session-id "$sid"
else
  set -- --resume "$sid"
fi

# Stamp the pane: read by the resurrect save hook and by the status bar.
if [ -n "${TMUX_PANE:-}" ]; then
  tmux set-option -p -t "$TMUX_PANE" @claude-session-id "$sid"
  tmux set-option -p -t "$TMUX_PANE" @claude-pane "$name"
fi

exec claude "$@" --name "$name"
```

- [ ] **Step 2: Make it executable**

```bash
chmod +x ~/dots/tmux/scripts/claude-pane.sh
```

- [ ] **Step 3: Test it launches a new session and stamps the pane**

In a scratch tmux window:
```bash
~/.tmux/scripts/claude-pane.sh scratch-test
```
Then from another pane:
Run: `tmux list-panes -a -F '#{@claude-pane} #{@claude-session-id}' | grep scratch-test`
Expected: one line with `scratch-test` and a lowercase UUID. Quit that Claude session afterward.

- [ ] **Step 4: Commit**

```bash
cd ~/dots
git add tmux/scripts/claude-pane.sh
git commit -m "feat(tmux): claude-pane.sh launch/resume wrapper with durable session id"
```

---

## Task 4: Rewire the Claude keybinds and aliases through the wrapper

**Files:**
- Modify: `~/dots/tmux/conf/keybindings.conf` (the `# CLAUDE` section)

- [ ] **Step 1: Replace the command-aliases**

Replace the two `command-alias[100/101]` lines with (the wrapper now sets `@claude-pane`, so the inline `set-option` is dropped):

```tmux
set -g command-alias[100] 'claw=command-prompt -p "claude window name:" -I "%1" { new-window -c "#{pane_current_path}" -n "%%" "$HOME/.tmux/scripts/claude-pane.sh %%" }'
set -g command-alias[101] 'clap=command-prompt -p "claude pane name:"   -I "%1" { split-window -h -c "#{pane_current_path}" "$HOME/.tmux/scripts/claude-pane.sh %%" }'
```

- [ ] **Step 2: Replace the `prefix+W` / `prefix+P` binds**

```tmux
bind W command-prompt -p "claude window name:" { new-window -c "#{pane_current_path}" -n "%%" "$HOME/.tmux/scripts/claude-pane.sh %%" }
bind P command-prompt -p "claude pane name:"   { split-window -h -c "#{pane_current_path}" "$HOME/.tmux/scripts/claude-pane.sh %%" }
```

(Note: as in the original config, Claude names with spaces aren't supported by this prompt path — unchanged behaviour.)

- [ ] **Step 3: Reload and test via the keybind**

Run: `tmux source-file ~/.tmux.conf`
Press `prefix+P`, enter name `wire-test`. A new pane launches Claude.
Run: `tmux list-panes -a -F '#{@claude-pane} #{@claude-session-id}' | grep wire-test`
Expected: `wire-test <uuid>`. Quit that Claude pane afterward.

- [ ] **Step 4: Commit**

```bash
cd ~/dots
git add tmux/conf/keybindings.conf
git commit -m "feat(tmux): route Claude keybinds/aliases through claude-pane.sh"
```

---

## Task 5: Save hook — persist the pane→session map

**Files:**
- Create: `~/dots/tmux/scripts/resurrect-save-claude.sh`
- Modify: `~/dots/tmux/conf/plugins.conf` (add the post-save hook line)

- [ ] **Step 1: Write the save hook**

```bash
#!/usr/bin/env bash
# resurrect post-save hook (@resurrect-hook-post-save-all):
# Persist each Claude pane's positional address, cwd, session id and label so
# the restore hook can resume the exact conversation in the exact pane.
# Tab-separated columns: session  window  pane  cwd  session-id  name
set -u

out="${HOME}/.tmux/resurrect/claude-panes.tsv"
mkdir -p "$(dirname "$out")"
: > "$out"

# Iterate by pane id (stable within a server) to read options reliably; store
# the positional address (session:window.pane), which resurrect preserves.
tmux list-panes -a -F '#{pane_id}' | while read -r pid; do
  sid=$(tmux show-options -pqv -t "$pid" @claude-session-id 2>/dev/null || true)
  [ -z "${sid:-}" ] && continue
  name=$(tmux show-options -pqv -t "$pid" @claude-pane 2>/dev/null || true)
  s=$(tmux display-message -p -t "$pid" '#{session_name}')
  w=$(tmux display-message -p -t "$pid" '#{window_index}')
  p=$(tmux display-message -p -t "$pid" '#{pane_index}')
  cwd=$(tmux display-message -p -t "$pid" '#{pane_current_path}')
  printf '%s\t%s\t%s\t%s\t%s\t%s\n' "$s" "$w" "$p" "$cwd" "$sid" "$name" >> "$out"
done
```

- [ ] **Step 2: Make executable and wire the hook**

```bash
chmod +x ~/dots/tmux/scripts/resurrect-save-claude.sh
```

Add to `~/dots/tmux/conf/plugins.conf`, in the `# --- tmux-resurrect ---` block (after the `@resurrect-restore` line):

```tmux
set -g @resurrect-hook-post-save-all '~/.tmux/scripts/resurrect-save-claude.sh'
```

- [ ] **Step 3: Reload, save, and verify the sidecar**

Run: `tmux source-file ~/.tmux.conf`
Launch a throwaway Claude pane: `prefix+P`, name `save-test`.
Run a save: `~/.tmux/plugins/tmux-resurrect/scripts/save.sh`
Run: `grep save-test ~/.tmux/resurrect/claude-panes.tsv`
Expected: a 6-field tab-separated line ending in the UUID and `save-test`. Quit the test pane.

- [ ] **Step 4: Commit**

```bash
cd ~/dots
git add tmux/scripts/resurrect-save-claude.sh tmux/conf/plugins.conf
git commit -m "feat(tmux): resurrect post-save hook persists Claude pane→session map"
```

---

## Task 6: Restore hook — resume each Claude pane (tested in isolation)

**Files:**
- Create: `~/dots/tmux/scripts/resurrect-restore-claude.sh`
- Modify: `~/dots/tmux/conf/plugins.conf` (add the post-restore hook line)
- Create (temporary, not committed): `/tmp/sprtest.conf`

- [ ] **Step 1: Write the restore hook**

```bash
#!/usr/bin/env bash
# resurrect post-restore hook (@resurrect-hook-post-restore-all):
# Resume each saved Claude conversation in its pane. Runs after resurrect has
# rebuilt panes (as bare shells in the right cwd); we respawn the Claude ones.
set -u

in="${HOME}/.tmux/resurrect/claude-panes.tsv"
[ -f "$in" ] || exit 0
wrapper="${HOME}/.tmux/scripts/claude-pane.sh"

while IFS=$'\t' read -r s w p cwd sid name; do
  [ -z "${sid:-}" ] && continue
  target="${s}:${w}.${p}"
  cmd="$wrapper $(printf '%q' "${name:-claude}") $(printf '%q' "$sid")"
  tmux respawn-pane -k -c "$cwd" -t "$target" "$cmd" 2>/dev/null || true
done < "$in"
```

- [ ] **Step 2: Make executable and wire the hook**

```bash
chmod +x ~/dots/tmux/scripts/resurrect-restore-claude.sh
```

Add to `~/dots/tmux/conf/plugins.conf`, right after the post-save hook line:

```tmux
set -g @resurrect-hook-post-restore-all '~/.tmux/scripts/resurrect-restore-claude.sh'
```

- [ ] **Step 3: Build an isolated test config** (`/tmp/sprtest.conf`)

This uses a SEPARATE resurrect dir so it cannot touch your real snapshot, and loads the plugins + hooks:

```tmux
set -g @resurrect-dir '/tmp/sprtest-resurrect'
set -g @resurrect-capture-pane-contents 'on'
set -g @resurrect-hook-post-save-all '~/.tmux/scripts/resurrect-save-claude.sh'
set -g @resurrect-hook-post-restore-all '~/.tmux/scripts/resurrect-restore-claude.sh'
set -g @continuum-restore 'on'
run '~/.tmux/plugins/tmux-resurrect/resurrect.tmux'
run '~/.tmux/plugins/tmux-continuum/continuum.tmux'
```

NOTE: the save/restore hooks write to `~/.tmux/resurrect/claude-panes.tsv` (HOME-based, shared). For the isolated test, temporarily point them at the test dir by exporting nothing — instead the test below seeds and inspects `/tmp/sprtest-resurrect` for the resurrect snapshot and uses the same sidecar; this is acceptable because the test uses unique session names. If you prefer full isolation of the sidecar, edit the two hook scripts' `out`/`in` to honour `${RESURRECT_DIR:-$HOME/.tmux/resurrect}` and export `RESURRECT_DIR=/tmp/sprtest-resurrect` for the test server.

- [ ] **Step 4: Run the isolated save→kill→restore cycle**

```bash
mkdir -p /tmp/sprtest-resurrect
# Start an isolated server with two Claude panes in the SAME cwd (the collision case)
tmux -L sprtest -f /tmp/sprtest.conf new-session -d -s T -c /tmp
tmux -L sprtest send-keys -t T "~/.tmux/scripts/claude-pane.sh alpha" Enter
tmux -L sprtest split-window -t T -c /tmp
tmux -L sprtest send-keys -t T "~/.tmux/scripts/claude-pane.sh bravo" Enter
sleep 5   # let both Claude sessions initialise
# Save, then tear the server down completely
tmux -L sprtest run-shell '~/.tmux/plugins/tmux-resurrect/scripts/save.sh'
tmux -L sprtest kill-server
# Bring it back: server start triggers continuum-restore + the restore hook
tmux -L sprtest -f /tmp/sprtest.conf start-server
sleep 6
tmux -L sprtest list-panes -t T -F '#{pane_index} #{@claude-pane} #{@claude-session-id}'
```

Expected: session `T` exists with two panes, labelled `alpha` and `bravo`, each carrying its **own** distinct UUID — i.e. two same-cwd panes resumed to different conversations. Attach (`tmux -L sprtest attach -t T`) and eyeball that each pane is a live Claude session; detach.

- [ ] **Step 5: Tear down the test server**

```bash
tmux -L sprtest kill-server 2>/dev/null || true
rm -rf /tmp/sprtest-resurrect /tmp/sprtest.conf
```

- [ ] **Step 6: Commit**

```bash
cd ~/dots
git add tmux/scripts/resurrect-restore-claude.sh tmux/conf/plugins.conf
git commit -m "feat(tmux): resurrect post-restore hook resumes Claude panes by id"
```

---

## Task 7: Ghostty launch-into-tmux

**Files:**
- Create: `~/dots/tmux/scripts/ghostty-tmux.sh`
- Modify: `~/dots/ghostty/config`

- [ ] **Step 1: Write the launcher**

```bash
#!/usr/bin/env bash
# Ghostty launch command: every Ghostty surface drops into tmux.
# First launch starts the server (continuum auto-restores the last snapshot);
# subsequent windows attach to the running server.
set -u

if tmux has-session 2>/dev/null; then
  exec tmux attach
fi

# No server yet: start it so continuum-restore (fires on server start) rebuilds
# the saved sessions, then attach. The loop covers the restore-vs-attach race.
tmux start-server
for _ in 1 2 3 4 5 6 7 8 9 10; do
  tmux has-session 2>/dev/null && break
  sleep 0.3
done

exec tmux attach 2>/dev/null || exec tmux new-session
```

- [ ] **Step 2: Make executable**

```bash
chmod +x ~/dots/tmux/scripts/ghostty-tmux.sh
```

- [ ] **Step 3: Point Ghostty at it**

Add to `~/dots/ghostty/config`:

```
command = /Users/mattchapman/.tmux/scripts/ghostty-tmux.sh
```

- [ ] **Step 4: Verify a new Ghostty window attaches to the running server**

Open a new Ghostty window (⌘N). Expected: it lands inside tmux attached to your existing live server (you see your current sessions), NOT a fresh empty server. Run inside it: `tmux display-message -p '#{socket_path} / sessions=#{session_many... }'` — simpler: `tmux ls` should show your real DEV/INFOSEC/LEADERSHIP/QUASAR sessions.

If a stray duplicate session appears or it fails to attach, adjust the launcher (e.g. increase the wait, or `tmux attach -t` a named default) and re-test before committing.

- [ ] **Step 5: Commit**

```bash
cd ~/dots
git add tmux/scripts/ghostty-tmux.sh ghostty/config
git commit -m "feat(ghostty): launch into tmux so sessions auto-restore on open"
```

---

## Task 8: macOS Login Item for Ghostty

**Files:**
- Create: `~/dots/tmux/scripts/setup-login-item.sh`

- [ ] **Step 1: Write the idempotent setup helper**

```bash
#!/usr/bin/env bash
# One-time: add Ghostty to macOS Login Items so tmux auto-starts on login.
# Idempotent -- safe to run repeatedly.
set -u

osascript <<'OSA'
tell application "System Events"
  if not (exists login item "Ghostty") then
    make login item at end with properties {path:"/Applications/Ghostty.app", hidden:false}
  end if
end tell
OSA

echo "Ghostty login item ensured."
```

- [ ] **Step 2: Make executable and run it**

```bash
chmod +x ~/dots/tmux/scripts/setup-login-item.sh
~/dots/tmux/scripts/setup-login-item.sh
```

(macOS may prompt to allow Terminal/Ghostty to control "System Events" — approve it.)

- [ ] **Step 3: Verify the login item exists**

Run: `osascript -e 'tell application "System Events" to get the name of every login item'`
Expected: the list includes `Ghostty`. (Also visible in System Settings → General → Login Items.)

- [ ] **Step 4: Commit**

```bash
cd ~/dots
git add tmux/scripts/setup-login-item.sh
git commit -m "feat(tmux): one-time helper to add Ghostty to macOS Login Items"
```

---

## Task 9: End-to-end reboot verification

**Files:** none (manual acceptance test).

- [ ] **Step 1: Prime real state**

Ensure your working sessions are set up as normal, with at least one window containing **two Claude panes in the same directory** (the collision case). Trigger a save so the snapshot + sidecar are fresh: `prefix+S`. Then confirm:

Run: `wc -l ~/.tmux/resurrect/claude-panes.tsv && cat ~/.tmux/resurrect/last`
Expected: sidecar has a line per Claude pane; `last` points at a recent snapshot.

- [ ] **Step 2: Reboot**

Restart the Mac (or log out and back in).

- [ ] **Step 3: Observe auto-start + restore**

Expected on login: Ghostty opens automatically and lands you in tmux with DEV/INFOSEC/LEADERSHIP/QUASAR restored — windows, layouts, cwds and scrollback intact.

- [ ] **Step 4: Verify Claude resume, including the collision case**

In the window with two same-cwd Claude panes: confirm each pane resumed its **own** conversation (ask each "what were we just doing?"), and the status-bar labels are present.

Run: `tmux list-panes -a -F '#{@claude-pane} #{@claude-session-id}' | sort | uniq -c`
Expected: distinct UUIDs per Claude pane; labels restored.

- [ ] **Step 5: Confirm no stray empty session**

Run: `tmux ls`
Expected: only your real sessions (no extra `main`/empty session from the launcher).

- [ ] **Step 6: Record results / file follow-ups**

If anything regressed (stray session, a pane that didn't resume, missing label), note it against the relevant task's open risk in the spec and fix forward. Otherwise, done.

- [ ] **Step 7: Final commit (docs tidy, if any)**

```bash
cd ~/dots
git add -A docs/ && git commit -m "docs(tmux): mark session-persistence verified" || true
```

---

## Self-review notes (author)

- **Spec coverage:** core stack (T1), pane-scrollback (T1), continuum auto-save/restore (T1), retire custom scripts + S/R rebind (T2), durable session-id wrapper (T3) + rewire (T4), post-save sidecar (T5), post-restore resume incl. same-cwd (T6), Ghostty login auto-start (T7+T8), reboot acceptance + no-stray-session + label restore (T9). Keystone (`--session-id`/`--resume`) gated first (T0).
- **Open risks** from the spec are each pinned to a task: keystone→T0; pane addressing→T6; Ghostty wiring/stray session→T7+T9; hook quoting (`printf %q`)→T6 script; resume-failure→`exec` semantics noted in T3 (pane closes on failure, consistent with current window-on-exit behaviour).
- **Type/name consistency:** pane option names `@claude-session-id` / `@claude-pane`, sidecar path `~/.tmux/resurrect/claude-panes.tsv`, and wrapper signature `claude-pane.sh <name> [session-id]` are used identically across T3/T4/T5/T6.
