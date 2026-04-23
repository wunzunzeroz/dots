# tmux Claude Launchers (`claw` / `clap`)

## Overview

Two tmux user-commands and matching keybindings that spawn a named [claude-code](https://github.com/anthropics/claude-code) session in a new window (`claw`) or a new pane (`clap`), tying the tmux window name / pane title to `claude --name`. A single invocation sets both identifiers so the label is visible in the tmux status bar and in claude's own UI.

## Problem

Today, spawning a claude session in a dedicated window/pane takes multiple steps: create the window, rename it, run `claude --name NAME`. The name has to be typed twice and the two names can drift. We want one command that takes a single NAME and wires everything up.

## Design

### Invocation

Both forms route through tmux's `command-prompt`, pre-filled when an argument is provided:

| Form | Behaviour |
|------|-----------|
| `:claw FOOBAR` | prompt appears pre-filled with `FOOBAR`; Enter confirms |
| `:claw` (no arg) | prompt appears empty; user types the name |
| `prefix + W` | same empty prompt |
| `:clap FOOBAR` / `prefix + P` | pane analogues of the above |

Rationale for always-prompt: a bare `:claw` cannot accidentally launch a session with an empty name, and the keybinding and command-alias share a single template. Cost is one extra Enter when typing a name on the command line.

### Template

Both paths call the same `new-window` / `split-window` template:

- `-c "#{pane_current_path}"` — inherit cwd from the current pane (matches existing `v`/`s` split bindings)
- Window: `-n NAME` sets the tmux window name
- Pane: `-T NAME` sets the pane title
- Command: `claude --name NAME`

### Keybinding choices

- `prefix + W` — claude window. Uppercase `W` is unbound by default; lowercase `w` (default window picker) is preserved.
- `prefix + P` — claude pane. Uppercase `P` is unbound by default; lowercase `p` (default previous-window) is preserved.

Mnemonic: uppercase for "create named claude", lowercase left alone for tmux's browse/navigation defaults.

### Split direction

`clap` splits horizontally (`split-window -h`, panes side-by-side). Claude benefits from width more than height, and matches the user's existing `v` split. Vertical claude panes are out of scope — user can run `prefix + s` then `claude --name NAME` manually if needed.

### Pane border titles

Pane titles from `clap` are only useful if they're visible. Enable in `options.conf`:

```tmux
set -g pane-border-status top
set -g pane-border-format " [#{pane_index}] #{pane_title} "
```

Always-on pane border (top row per pane). Shows pane index and title. Claude panes get the name set via `-T`; regular panes show whatever the shell sets as title (usually the current command or hostname). Trade-off: one extra row per pane, accepted for unambiguous claude-session identification.

### No new scripts

Everything is expressible in tmux config. No shell wrappers, no `~/dots/bin` additions.

## Files changed

- **`tmux/conf/keybindings.conf`** — add `# CLAUDE` section with two `set -ga command-alias` entries and two `bind` entries.
- **`tmux/conf/options.conf`** — add `pane-border-status` and `pane-border-format`.

## Out of scope

- Vertical `clap` variant
- Tracking/reusing existing claude sessions (`claude --resume`) — separate future concern
- Project-aware default names (basename of cwd) — can revisit if prompting proves annoying
- Shell-level aliases (e.g. `claw` outside tmux) — this is a tmux-native workflow

## Testing

Manual verification after `prefix + r` reload:

1. `:claw test1` → prompt pre-filled, Enter, new window named `test1` runs claude
2. `:claw` with no arg → prompt empty, type `test2`, Enter, new window `test2`
3. `prefix + W` → empty prompt, type `test3`, Enter, new window `test3`
4. `:clap test4` → new pane with title `test4`, border shows title
5. `prefix + P` → empty prompt, type `test5`, Enter, new pane `test5`
6. Normal shell panes still render without a title clutter
7. cwd of spawned window/pane matches the originating pane
