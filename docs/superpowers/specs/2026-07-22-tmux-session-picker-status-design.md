# tmux session picker — Claude status & activity

Design doc — 2026-07-22

## Problem

The fuzzy session picker (`prefix + Space`, backed by
`tmux/scripts/session-picker.sh`) lists sessions with only their name and
window count. When several sessions each run a backgrounded Claude Code, the
picker gives no way to tell, at a glance:

- which sessions have a Claude that is **waiting on you** (a permission prompt
  or an attention notification),
- which have a Claude that is **actively working**,
- how much is **running** in each session at all.

You end up cycling through sessions to find the one that needs you.

## Goal

Enrich each picker line with:

1. a **running count** — how many panes in the session are doing something, and
2. a **Claude state breakdown** — counts of Claude panes that are awaiting
   input / working / idle,

and float sessions with a Claude **awaiting input** to the top so the picker
doubles as a "who needs me" list.

## Foundation (already shipped this session)

`session-picker.sh` now sorts sessions **most-recently-attached first** instead
of alphabetically, by prefixing each line with `#{session_last_attached}`,
`sort -rn`, then stripping the key. The `choose-tree` fallback gained `-O time`.
This design builds the status annotations on top of that MRU ordering.

## Decisions (locked during brainstorming)

- **State detection: Claude hooks stamp the pane.** Process inspection alone
  cannot distinguish a Claude that is thinking from one waiting on you — both
  are just a live process in the pane. Only Claude knows, so Claude reports it
  via lifecycle hooks.
- **"Running" = busy panes.** A pane counts as running when its
  `pane_current_command` is not a login shell. A dev server, build, `nvim`, or a
  live Claude all count; an idle shell prompt does not. (No process-tree walk.)
- **Sort: awaiting floats to top, rest MRU.** Sessions with a Claude awaiting
  input sort above everything else, most-recent-first within that group; the
  remainder keep MRU order.

## Architecture

```
Claude Code process (running inside a tmux pane)
   │  hooks fire on lifecycle events
   ▼
tmux pane option  @claude-state = working | awaiting | idle
   │  (lives with the pane; removed when the pane closes)
   ▼
session-picker.sh
   ├── tmux list-sessions  (MRU order, names)
   └── tmux list-panes -a  (per-pane command + @claude-state)
          │  awk aggregates per session
          ▼
   fzf  (awaiting-first, then MRU)  →  switch-client
```

Snapshot-on-demand: two `tmux` calls plus one `awk` pass each time the popup
opens. No daemon, no polling, no temp files.

**Why a pane option, not a state file:** the state belongs to the pane,
`set-option -p` is a single cheap call, the value is garbage-collected
automatically when the pane closes, and the picker already reads pane data in
the `list-panes` call it needs anyway.

## Component 1 — state emission (Claude hooks)

### Helper script — `claude/hooks/tmux-state.sh` (new)

```sh
#!/bin/sh
# Stamp the current tmux pane with Claude's lifecycle state.
# No-op outside tmux; never blocks Claude even if tmux is absent.
[ -n "${TMUX_PANE:-}" ] && tmux set-option -p -t "$TMUX_PANE" @claude-state "$1" 2>/dev/null
exit 0
```

`$TMUX_PANE` is present in the Claude process environment (verified: `%92`) and
is inherited by hook subprocesses, so the pane is unambiguous and stable across
window renumbering.

### `claude/settings.json` hooks

| Hook | Argument | Meaning |
|------|----------|---------|
| `SessionStart` | `idle` | Claude present; marks the pane immediately, before the first prompt |
| `UserPromptSubmit` | `working` | prompt submitted; Claude is busy |
| `Stop` | `idle` | turn finished; quietly waiting for you |
| `Notification` (matcher `permission_prompt\|agent_needs_input\|elicitation_dialog`) | `awaiting` | genuinely needs you — a permission prompt or a request for input |
| `PostToolUse` (matcher `""`) | `working` | accuracy refinement — re-stamps working after a granted permission |

- The `Notification` awaiting-stamp is **scoped by `notification_type`** so it
  fires only when Claude is actually blocked on the user. Claude Code fires
  `Notification` for eight types; the routine `idle_prompt` (the ~60s
  "waiting for your input" timeout) is deliberately excluded — otherwise every
  finished-and-idle session decays into `awaiting` after a minute and floods
  "needs attention". The unscoped osascript notification is a **separate**
  matcher (`""`) that still pops for all notifications, unchanged.
- The broad `PostToolUse` → `working` is a **second, separate** `PostToolUse`
  entry. The existing `Edit|Write` prettier hook is left untouched.
- Command form (matches the `statusLine` convention already in the file):
  `${CLAUDE_CONFIG_DIR:-$HOME/.claude}/hooks/tmux-state.sh working`

### State semantics

- `awaiting` — actively blocked, needs action. **This is what floats to the
  top.**
- `working` — actively processing a turn.
- `idle` — finished a turn, your turn, no urgency. Stays in MRU order.

"Just finished a turn" maps to `idle`, deliberately **not** `awaiting`:
otherwise nearly every backgrounded Claude would float up and the signal is
lost. `awaiting` is reserved for the sharp `Notification` signal (permission /
attention).

**Known edge case & its fix:** if Claude raises a permission `Notification`
(`awaiting`) mid-turn and you grant it, it resumes working but would remain
labelled `awaiting` until `Stop`. The broad `PostToolUse` → `working` corrects
this: the next tool run re-stamps `working`. Without that hook the label
self-corrects at `Stop`; the refinement just tightens the window.

### Symlink

`~/.claude` is a real directory with individual entries symlinked. Add to the
`install.sh` `LINKS` array, mirroring how `agents/` is linked:

```
.claude/hooks             claude/hooks
```

Then `./install.sh` creates `~/.claude/hooks → dots/claude/hooks`.

## Component 2 — state consumption (`session-picker.sh`)

Gather all panes in one call:

```sh
tmux list-panes -a -F "#{session_name}	#{pane_current_command}	#{@claude-state}"
```

Per pane (in `awk`):

- **busy** — `pane_current_command` is not in the shell set
  (`zsh -zsh bash -bash sh -sh fish login`). A live Claude reports its version
  string (e.g. `2.1.185`) as the command, so it is non-shell and counts as busy.
- **claude state** — honor `@claude-state` **only if the pane is busy**. This is
  the staleness guard: when Claude exits, the pane command drops back to `zsh`,
  so a lingering `@claude-state` on a now-shell pane is ignored. (Optionally the
  picker clears it with `set-option -pu`; ignoring is sufficient.)

Per session, accumulate: `running` (busy count), and counts of `working` /
`awaiting` / `idle` Claude panes.

## Sort & display

The picker is a **two-level list**: a row per session (grouped current /
needs-attention / recent), and — for multi-window sessions — a row per window
beneath it. Selecting a session row switches to it (its last-active window);
selecting a window row switches and `select-window`s into that window. This
makes fzf search work at the window level: typing `WEATHER` jumps straight to
`LOGBOOK:WEATHER`.

The current session (passed to the awk from the keybind as `#{session_name}`)
is pinned to the top; the rest split into a **needs-attention** group (a Claude
awaiting input) and a **recent** group, each in MRU order (`session_last_attached`,
`sort -rn`). The awk emits `group <tab> rank <tab> sub <tab> session <tab>
window_index <tab> display`; the picker sorts by `group,rank,sub`.

- **Groups:** `0` current · `1` needs-attention · `2` recent. A session appears
  in exactly one group (current wins over awaiting).
- **`sub`** orders rows within a session: `0` for the session row,
  `window_index + 1` for window rows, so windows follow their session in index
  order. Window rows are emitted only when `window_count > 1` (a lone window
  would just restate the session row).
- **Section headers** (`─ needs attention ─`, `─ recent ─`) are emitted for each
  non-empty non-current group with `rank 0`. Header rows carry an **empty
  session field**, so selecting one is a no-op (the picker's `[ -z ] && continue`
  re-opens the list). The current session has no header — just a marker.
- fzf hides the two leading target columns (`session`, `window_index`) via
  `--with-nth 3..`; selection recovers them with `cut -f1` / `cut -f2`. Robust
  to spaces/colons in names and to the empty-field header rows.

Per-window stats reuse the same renderer as the session row. State labels come
**before** the program strip so they sit at a fixed offset after `N running`
(the run icon is the same glyph on every row) and therefore align across rows.
The program strip trails last because its icons render at unpredictable widths —
keeping them last means nothing that must align sits after them.

```
● HQ          HQ-CLI            󰜎 4 running   󰥔 2 working, 󰒲 1 idle   󰏫 1
    1         HQ                󰜎 2 running   󰒲 1 idle                󰏫 1
  > 2         HQ-CLI            󰜎 2 running   󰥔 2 working
─ recent ─
  LOGBOOK     SMART FIELDS      󰜎 3 running   󰒲 2 idle                󰏫 1
  > 1         SMART FIELDS      󰜎 2 running   󰒲 1 idle                󰏫 1
    2         WEATHER           󰜎 1 running   󰎙 1
```

- **Current marker:** `●` in purple `#bb9af7` (the active-pane colour) on the
  pinned top row.
- **Window rows:** window index + name, indented; the session's **active**
  window is marked `>` in purple, others muted. `select-window` targets by
  index (`session:index`), so window names with colons/spaces are unambiguous.
- **Active window (session row):** the session's current window name
  (`#{window_name}` on `list-sessions` resolves to the active window), in blue
  `#7aa2f7`. Padded/truncated to a fixed 16 columns — plain text pads reliably.
- **Running:** `󰜎` + total busy-pane count, in muted `#565f89`.
- **Claude state:** `󰂚` bell = awaiting (yellow `#e0af68`) · `󰥔` clock = working
  (cyan `#7dcfff`) · `󰒲` snooze = idle (muted). Multiple states comma-joined.
- **Programs (trailing):** deduped non-Claude commands as `icon count`, muted
  `#565f89`, a quiet "what's here" hint. Map (nf-md where possible): `node`
  `󰎙`, `python` `󰌠`, `docker` `󰡨`, `git` `󰊢`, `go` `󰟓`, `psql/mysql` `󰆼`,
  `nvim/vim` `󰏫` (pencil — the font lacks a vim glyph), fallback `󰆍`. Claude's
  version-string panes are skipped
  (their state icons cover them), detected by a stamped `@claude-state` or a
  `N.N…` command.
- A session with no Claude shows only its running count; an idle Claude still
  counts toward `running` (it is a live process).
- **Header rows are non-selecting:** the picker loops so choosing a
  `─ … ─` header (empty name field) re-opens the list instead of closing the
  popup; a real session switches, Esc exits.

## Error handling / edge cases

- **No fzf** — existing `choose-tree -s -O time` fallback; no annotations there.
- **Not in tmux / no sessions** — `list-sessions` empty, picker is a no-op.
- **Claude run outside tmux** — helper is a no-op (`$TMUX_PANE` empty); no
  effect on Claude.
- **tmux absent when a hook fires** — helper's `2>/dev/null` + `exit 0` means
  Claude is never blocked.
- **Abrupt Claude kill (SIGKILL, terminal crash)** — no `Stop`/`SessionEnd`
  fires, so `@claude-state` lingers; the busy-guard catches it once the pane
  returns to a shell. If the pane keeps a non-shell command by coincidence, the
  state may briefly mislead — acceptable for a point-in-time picker.
- **Performance** — two `tmux` calls + one `awk` pass; negligible even with
  dozens of sessions and panes.
- **No new dependencies** — helper and picker use only `tmux`/`awk`/`sh`; no
  `jq` needed for the new hooks.

## Scope / non-goals (YAGNI)

- No child-process-tree counting.
- No live/continuous refresh — snapshot when the picker opens.
- No annotations in the `choose-tree` fallback.
- State is reported only by Claudes started **after** the hooks land — expected.
- The `window-picker.sh` is out of scope; this is sessions only.

## Files touched

| File | Change |
|------|--------|
| `claude/hooks/tmux-state.sh` | new — pane-stamping helper |
| `claude/settings.json` | add `SessionStart`/`UserPromptSubmit`/`Stop` hooks, extend `Notification`, add broad `PostToolUse`→working |
| `install.sh` | add `.claude/hooks  claude/hooks` link entry |
| `tmux/scripts/session-picker.sh` | rewrite fzf branch: aggregate panes, annotate, awaiting-first sort, robust name extraction |

## Verification (manual — no test harness in this repo)

1. `./install.sh` is idempotent and creates `~/.claude/hooks`.
2. In a fresh Claude pane: submit a prompt → `@claude-state` reads `working`
   (`tmux show-options -p @claude-state`); on finish → `idle`; trigger a
   permission prompt → `awaiting`.
3. Open the picker with a mix of sessions: awaiting sessions appear first,
   counts match reality, an idle shell shows 0 running, quitting Claude drops
   the stale state.
4. Confirm the picker still works with no Claude anywhere and outside tmux.
