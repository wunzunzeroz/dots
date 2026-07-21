# tmux session picker — Claude status & activity — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Enrich the tmux fuzzy session picker so each line shows how many panes are running and a per-session breakdown of Claude state (awaiting / working / idle), with awaiting-input sessions floated to the top.

**Architecture:** Claude Code lifecycle hooks stamp a `@claude-state` option onto their own tmux pane via a tiny shared helper. The picker reads all panes in one `tmux list-panes` call, aggregates per session in a standalone awk transform, floats awaiting sessions above the existing MRU order, and renders through fzf.

**Tech Stack:** POSIX `sh`, `awk` (BWK/macOS awk — no gawk extensions), `tmux` 3.x, `fzf`, Claude Code hooks in `claude/settings.json`.

## Global Constraints

- macOS only; POSIX `sh` + BWK `awk` (no `asort`, no bash-only process substitution). Copied from spec/CLAUDE.md.
- No new tools or dependencies — only `tmux`/`awk`/`sh`/`fzf` (all already present). No `jq` in the new hooks.
- Config files are short; do not add comments that merely restate code (CLAUDE.md).
- Commit style: conventional commits, and every commit message ends with the trailer `Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>`.
- Helper invoked from hooks as `"${CLAUDE_CONFIG_DIR:-$HOME/.claude}"/hooks/tmux-state.sh` (matches the existing `statusLine` convention).
- `@claude-state` values are exactly `working`, `awaiting`, `idle`.
- Shell set (a pane is NOT busy when its `pane_current_command` is one of): `zsh -zsh bash -bash sh -sh fish login`.

## File Structure

| File | Responsibility |
|------|----------------|
| `claude/hooks/tmux-state.sh` | **new** — stamp the current tmux pane with a Claude lifecycle state; no-op outside tmux |
| `claude/settings.json` | **modify** — add `SessionStart`/`UserPromptSubmit`/`Stop` hooks, extend `Notification`, add a broad `PostToolUse`→working (leave the existing `Edit\|Write` prettier hook intact) |
| `install.sh` | **modify** — add one `LINKS` entry so `~/.claude/hooks` symlinks to `claude/hooks` |
| `tmux/scripts/session-annotate.awk` | **new** — pure transform: tagged pane+session stream → sorted-ready annotated lines (the unit-testable core) |
| `tmux/scripts/session-picker.sh` | **modify** — orchestrate the tmux calls, awk, sort, fzf display, and `switch-client` |

Note: `tmux/scripts/` is symlinked wholesale (`install.sh` line 41), so the new `.awk` file needs no install change. Only `claude/hooks/` is a new link target.

Note: the earlier uncommitted MRU-sort edit in `session-picker.sh` is superseded by the full rewrite in Task 4 and folds into that commit.

---

### Task 1: Pane-state helper script + symlink

**Files:**
- Create: `claude/hooks/tmux-state.sh`
- Modify: `install.sh:44` (add a `LINKS` entry after the `.claude/agents` line)

**Interfaces:**
- Produces: an executable `~/.claude/hooks/tmux-state.sh <state>` that runs `tmux set-option -p -t "$TMUX_PANE" @claude-state <state>` when `$TMUX_PANE` is set, and is a silent no-op otherwise. Consumed by Task 2 (hooks) and, at runtime, by Task 4 (picker reads `@claude-state`).

- [ ] **Step 1: Write the helper script**

Create `claude/hooks/tmux-state.sh`:

```sh
#!/bin/sh
# Stamp the current tmux pane with Claude Code's lifecycle state
# (working | awaiting | idle), read by tmux/scripts/session-picker.sh.
# No-op outside tmux; never blocks Claude even if tmux is absent.
[ -n "${TMUX_PANE:-}" ] && tmux set-option -p -t "$TMUX_PANE" @claude-state "$1" 2>/dev/null
exit 0
```

- [ ] **Step 2: Make it executable**

Run: `chmod +x claude/hooks/tmux-state.sh`
Expected: no output, exit 0.

- [ ] **Step 3: Add the symlink entry to install.sh**

Modify `install.sh` — insert a new line after the `.claude/agents` entry (line 44):

```
  ".claude/agents            claude/agents"
  ".claude/hooks             claude/hooks"
  ".claude/plugins/claude-hud/config.json claude/plugins/claude-hud/config.json"
```

- [ ] **Step 4: Run install.sh and verify idempotency + the new link**

Run: `./install.sh && readlink ~/.claude/hooks`
Expected: install output reports success/kept links (no errors), and `readlink` prints an absolute path ending in `dots/claude/hooks`.

- [ ] **Step 5: Test the helper stamps the current pane**

Run:
```sh
sh ~/.claude/hooks/tmux-state.sh working
tmux show-options -pv -t "$TMUX_PANE" @claude-state
```
Expected: prints `working`.

- [ ] **Step 6: Test the no-tmux no-op path**

Run: `env -u TMUX_PANE -u TMUX sh ~/.claude/hooks/tmux-state.sh working; echo "exit=$?"`
Expected: no error output, `exit=0`.

- [ ] **Step 7: Clean up the test stamp**

Run: `tmux set-option -pu -t "$TMUX_PANE" @claude-state`
Expected: no output (unsets the option so the test value doesn't linger).

- [ ] **Step 8: Commit**

```bash
git add claude/hooks/tmux-state.sh install.sh
git commit -m "feat(claude): add tmux pane-state hook helper

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

---

### Task 2: Wire Claude lifecycle hooks in settings.json

**Files:**
- Modify: `claude/settings.json` (the `"hooks"` object)

**Interfaces:**
- Consumes: `~/.claude/hooks/tmux-state.sh <state>` from Task 1.
- Produces: Claude sessions started after this change stamp `@claude-state` on their pane — `working` on prompt submit and after each tool, `idle` on session start and turn end, `awaiting` on notification. Consumed at runtime by Task 4.

- [ ] **Step 1: Replace the `"hooks"` object**

In `claude/settings.json`, replace the entire existing `"hooks": { ... }` block with the following. The existing `Edit|Write` prettier hook is preserved verbatim as the first `PostToolUse` matcher; a second broad `PostToolUse` matcher and the osascript `Notification` command are kept.

```json
  "hooks": {
    "SessionStart": [
      {
        "hooks": [
          { "type": "command", "command": "\"${CLAUDE_CONFIG_DIR:-$HOME/.claude}\"/hooks/tmux-state.sh idle" }
        ]
      }
    ],
    "UserPromptSubmit": [
      {
        "hooks": [
          { "type": "command", "command": "\"${CLAUDE_CONFIG_DIR:-$HOME/.claude}\"/hooks/tmux-state.sh working" }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          { "type": "command", "command": "FILE=$(echo \"$CLAUDE_TOOL_INPUT\" | jq -r '.file_path // empty') && [ -n \"$FILE\" ] && npx prettier --write \"$FILE\" 2>/dev/null || true" }
        ]
      },
      {
        "matcher": "",
        "hooks": [
          { "type": "command", "command": "\"${CLAUDE_CONFIG_DIR:-$HOME/.claude}\"/hooks/tmux-state.sh working" }
        ]
      }
    ],
    "Stop": [
      {
        "hooks": [
          { "type": "command", "command": "\"${CLAUDE_CONFIG_DIR:-$HOME/.claude}\"/hooks/tmux-state.sh idle" }
        ]
      }
    ],
    "Notification": [
      {
        "matcher": "",
        "hooks": [
          { "type": "command", "command": "osascript -e 'display notification \"Claude Code needs your attention\" with title \"Claude Code\"'" },
          { "type": "command", "command": "\"${CLAUDE_CONFIG_DIR:-$HOME/.claude}\"/hooks/tmux-state.sh awaiting" }
        ]
      }
    ]
  },
```

- [ ] **Step 2: Verify the JSON still parses**

Run: `python3 -m json.tool claude/settings.json >/dev/null && echo OK`
Expected: `OK` (no parse error).

- [ ] **Step 3: Confirm the helper reference resolves**

Run: `eval echo "\"${CLAUDE_CONFIG_DIR:-$HOME/.claude}\"/hooks/tmux-state.sh"`
Expected: an absolute path to an existing file (e.g. `/Users/<you>/.claude/hooks/tmux-state.sh`); confirm with `test -x` on that path prints nothing and exits 0.

- [ ] **Step 4: Commit**

```bash
git add claude/settings.json
git commit -m "feat(claude): stamp tmux pane state from lifecycle hooks

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

- [ ] **Step 5: Manual runtime verification (requires a fresh Claude session)**

Settings are read at Claude startup, so this cannot be scripted in-session. After committing, in a tmux pane start a **new** `claude`, then from another pane run `tmux show-options -pv -t <that-pane> @claude-state` and confirm:
- right after start / after a reply finishes → `idle`
- while it is working on a submitted prompt → `working`
- when it raises a permission/attention prompt → `awaiting`

Record the result in the task notes. (This step gates the feature but is inherently manual.)

---

### Task 3: Session-annotate awk transform (unit-tested against fixtures)

**Files:**
- Create: `tmux/scripts/session-annotate.awk`
- Test: `/tmp/picker-fixture.txt` (throwaway fixture, not committed)

**Interfaces:**
- Consumes a tab-separated tagged stream on stdin:
  - `P <tab> session <tab> pane_current_command <tab> @claude-state`
  - `S <tab> session` — session lines, already MRU-ordered by the caller
- Produces one line per session: `prio <tab> rank <tab> session <tab> display`, where `prio` is `0` when the session has ≥1 awaiting Claude else `1`, and `rank` is the session's MRU arrival index. Ready for `sort -k1,1n -k2,2n | cut -f3-`. Consumed by Task 4.

- [ ] **Step 1: Write the fixture (the failing test input)**

Run:
```sh
{
  printf 'P\tHQ\t2.1.210\tworking\n'
  printf 'P\tHQ\tnvim\t\n'
  printf 'P\tDEV\t2.1.208\tworking\n'
  printf 'P\tDEV\t2.1.207\tidle\n'
  printf 'P\tLOGBOOK\t2.1.198\tawaiting\n'
  printf 'P\tLOGBOOK\tzsh\t\n'
  printf 'P\tADMIRAL\tzsh\t\n'
  printf 'P\tADMIRAL\tzsh\t\n'
  printf 'S\tLOGBOOK\n'
  printf 'S\tHQ\n'
  printf 'S\tDEV\n'
  printf 'S\tADMIRAL\n'
} > /tmp/picker-fixture.txt
cat /tmp/picker-fixture.txt
```
Expected: 12 tab-separated lines echoed back. (S lines are in MRU order: LOGBOOK, HQ, DEV, ADMIRAL.)

- [ ] **Step 2: Run the (not-yet-written) transform to verify it fails**

Run: `awk -f tmux/scripts/session-annotate.awk /tmp/picker-fixture.txt`
Expected: FAIL — `awk: can't open file tmux/scripts/session-annotate.awk`.

- [ ] **Step 3: Write the awk transform**

Create `tmux/scripts/session-annotate.awk`:

```awk
# Aggregate tmux panes per session and annotate with Claude state.
# Input (tab-separated, tagged):
#   P <tab> session <tab> pane_current_command <tab> @claude-state
#   S <tab> session                 (session lines pre-sorted MRU by caller)
# Output (tab-separated):
#   prio <tab> rank <tab> session <tab> display
# where prio=0 if the session has an awaiting Claude (else 1), rank is MRU index.
BEGIN { FS = "\t"; OFS = "\t" }

$1 == "P" {
  sess = $2; cmd = $3; state = $4
  if (cmd != "zsh" && cmd != "-zsh" && cmd != "bash" && cmd != "-bash" && cmd != "sh" && cmd != "-sh" && cmd != "fish" && cmd != "login") {
    run[sess]++
    if (state == "working")       work[sess]++
    else if (state == "awaiting") await[sess]++
    else if (state == "idle")     idle[sess]++
  }
  next
}

$1 == "S" {
  sess = $2
  rank++
  ann = ""
  if (await[sess] > 0) ann = ann sprintf(" ⏸%d", await[sess])
  if (work[sess]  > 0) ann = ann sprintf(" ⚡%d", work[sess])
  if (idle[sess]  > 0) ann = ann sprintf(" ✓%d", idle[sess])
  disp = sprintf("%-12s %d running%s", sess, run[sess] + 0, ann)
  prio = (await[sess] > 0) ? 0 : 1
  print prio, rank, sess, disp
}
```

- [ ] **Step 4: Run the transform and verify raw output**

Run: `awk -f tmux/scripts/session-annotate.awk /tmp/picker-fixture.txt`
Expected (order as emitted, before the final sort — tabs shown as spaces here):
```
1  2  HQ       HQ           2 running ⚡1
```
…and lines for `LOGBOOK` (`0  1  LOGBOOK  LOGBOOK      1 running ⏸1`), `DEV` (`1  3  DEV  DEV          2 running ⚡1 ✓1`), and `ADMIRAL` (`1  4  ADMIRAL  ADMIRAL      0 running`). Confirm LOGBOOK has `prio=0`, ADMIRAL shows `0 running`, DEV shows both `⚡1` and `✓1`.

- [ ] **Step 5: Verify the full sort + trim (the behavioural assertion)**

Run:
```sh
TAB=$(printf '\t')
awk -f tmux/scripts/session-annotate.awk /tmp/picker-fixture.txt \
  | sort -t"$TAB" -k1,1n -k2,2n | cut -f3- | cut -f2-
```
Expected — LOGBOOK (the awaiting session) is first, then MRU order HQ, DEV, ADMIRAL:
```
LOGBOOK      1 running ⏸1
HQ           2 running ⚡1
DEV          2 running ⚡1 ✓1
ADMIRAL      0 running
```

- [ ] **Step 6: Assert programmatically (guards against regressions)**

Run:
```sh
TAB=$(printf '\t')
OUT=$(awk -f tmux/scripts/session-annotate.awk /tmp/picker-fixture.txt | sort -t"$TAB" -k1,1n -k2,2n | cut -f3- | cut -f2-)
printf '%s\n' "$OUT" | head -1 | grep -q 'LOGBOOK' && \
printf '%s\n' "$OUT" | grep -q 'ADMIRAL      0 running' && \
printf '%s\n' "$OUT" | grep -q 'DEV .*⚡1 ✓1' && \
echo PASS || echo FAIL
```
Expected: `PASS`.

- [ ] **Step 7: Commit**

```bash
git add tmux/scripts/session-annotate.awk
git commit -m "feat(tmux): add session-annotate awk transform for picker

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

---

### Task 4: Rewrite session-picker.sh to render annotations

**Files:**
- Modify: `tmux/scripts/session-picker.sh` (full rewrite of the fzf branch)

**Interfaces:**
- Consumes: `~/.tmux/scripts/session-annotate.awk` (Task 3) and, at runtime, `@claude-state` pane options (Tasks 1–2).
- Produces: `prefix + Space` popup listing sessions annotated with running counts and Claude state, awaiting-first then MRU, and `switch-client` to the chosen session.

- [ ] **Step 1: Write the new script**

Replace the entire contents of `tmux/scripts/session-picker.sh` with:

```sh
#!/bin/sh
# Fuzzy session picker.
# With fzf: sessions annotated with running counts + Claude state
# (awaiting-first, then most-recently-attached). Without fzf: choose-tree.
#
# Pipeline: pane data + MRU-sorted session names -> session-annotate.awk
# -> sort (awaiting first, MRU within) -> fzf. Each fzf row is
# "<name><TAB><display>"; --with-nth=2.. hides the name, cut -f1 recovers it.

[ -f "$HOME/.tmux/scripts/fzf-theme.sh" ] && . "$HOME/.tmux/scripts/fzf-theme.sh"

ANNOTATE="$HOME/.tmux/scripts/session-annotate.awk"
TAB=$(printf '\t')

if command -v fzf >/dev/null 2>&1; then
    line=$(
        {
            tmux list-panes -a -F "P${TAB}#{session_name}${TAB}#{pane_current_command}${TAB}#{@claude-state}" 2>/dev/null
            tmux list-sessions -F "#{session_last_attached}${TAB}S${TAB}#{session_name}" 2>/dev/null \
                | sort -rn | cut -f2-
        } \
            | awk -f "$ANNOTATE" \
            | sort -t"$TAB" -k1,1n -k2,2n \
            | cut -f3- \
            | fzf --delimiter="$TAB" --with-nth=2.. \
                  --header='󰮪 Switch session' --border-label=' sessions '
    )
    session=$(printf '%s' "$line" | cut -f1)
    [ -n "$session" ] && tmux switch-client -t "$session"
else
    tmux choose-tree -s -O time
fi
```

- [ ] **Step 2: Verify the non-interactive pipeline against live sessions**

Run (mirrors the script but pipes to `cat` instead of fzf):
```sh
TAB=$(printf '\t')
{
  tmux list-panes -a -F "P${TAB}#{session_name}${TAB}#{pane_current_command}${TAB}#{@claude-state}"
  tmux list-sessions -F "#{session_last_attached}${TAB}S${TAB}#{session_name}" | sort -rn | cut -f2-
} | awk -f ~/.tmux/scripts/session-annotate.awk | sort -t"$TAB" -k1,1n -k2,2n | cut -f3- | cut -f2-
```
Expected: one line per live session, running counts matching reality (idle shells show `0 running`), any `@claude-state`-stamped panes annotated, awaiting sessions on top. No errors.

- [ ] **Step 3: Verify selection extraction (simulated fzf pick)**

Run:
```sh
TAB=$(printf '\t')
{
  tmux list-panes -a -F "P${TAB}#{session_name}${TAB}#{pane_current_command}${TAB}#{@claude-state}"
  tmux list-sessions -F "#{session_last_attached}${TAB}S${TAB}#{session_name}" | sort -rn | cut -f2-
} | awk -f ~/.tmux/scripts/session-annotate.awk | sort -t"$TAB" -k1,1n -k2,2n | cut -f3- \
  | fzf --delimiter="$TAB" --with-nth=2.. --filter="" | head -1 | cut -f1
```
Expected: prints a bare session name (field 1), no display text or tabs — confirming `cut -f1` recovers the target for `switch-client`. (`--filter=""` matches all; `head -1` takes the top row.)

- [ ] **Step 4: Interactive smoke test**

In tmux, press `prefix + Space`. Expected: popup lists annotated sessions (awaiting-first, then MRU); selecting one switches to it; pressing Esc cancels with no switch.

- [ ] **Step 5: Verify the no-fzf fallback path is intact**

Run: `command -v fzf` to confirm fzf exists, then read the script's `else` branch to confirm it still calls `tmux choose-tree -s -O time`. (No behaviour change expected here; this guards against accidental deletion.)
Expected: fallback branch present and unchanged.

- [ ] **Step 6: Commit**

```bash
git add tmux/scripts/session-picker.sh
git commit -m "feat(tmux): annotate session picker with Claude state

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
```

---

## Self-Review

**1. Spec coverage:**
- Running count = busy panes → Task 3 awk (`run[sess]`, shell-set exclusion). ✓
- 3-state Claude detection via hooks → Tasks 1–2 (helper + hooks). ✓
- Pane-option storage + staleness guard (honor state only if pane busy) → Task 3 (state counted only inside the non-shell branch). ✓
- Awaiting-floats-to-top, MRU within → Task 3 (`prio`/`rank`) + Task 4 (`sort -k1,1n -k2,2n`). ✓
- Robust name extraction (no `cut -d: -f1`) → Task 4 (`--with-nth=2..` + `cut -f1`). ✓
- Symlink for hooks dir → Task 1 (install.sh). ✓
- `choose-tree -O time` fallback preserved → Task 4 else branch + Step 5. ✓
- No new deps, macOS/POSIX, no jq in new hooks → honored throughout. ✓
- SessionStart marks presence, PostToolUse refinement, Notification extended not replaced → Task 2. ✓

**2. Placeholder scan:** No TBD/TODO. The one inherently-manual step (Task 2 Step 5) is explicitly labelled and unavoidable (settings load at Claude startup); it still gives exact commands and expected values.

**3. Type/name consistency:** `session-annotate.awk` path, tag letters `P`/`S`, field order (`P: session,cmd,state`; `S: session`), output columns (`prio,rank,session,display`), and the `TAB` variable are identical across Tasks 3 and 4. Sort keys `-k1,1n -k2,2n` match the emitted `prio`/`rank` columns. `@claude-state` values `working`/`awaiting`/`idle` match between the helper (Task 1), hooks (Task 2), and awk matching (Task 3).
