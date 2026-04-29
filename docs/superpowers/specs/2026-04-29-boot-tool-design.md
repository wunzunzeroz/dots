# `boot` — worktree picker + dev server launcher

**Date:** 2026-04-29
**Status:** Design approved, ready for implementation plan
**Owner:** Matt

## Summary

A personal CLI utility that, when run inside a tmux pane (or any terminal), pops an fzf picker of the current repo's git worktrees, then `cd`s into the chosen worktree and launches the dev server with auto-incremented port handling.

The script lives in dotfiles (`~/dots/bin/boot`) and is symlinked onto the existing `~/.local/bin/boot` PATH entry. It is repo-agnostic in mechanics — anything with `git worktree` and a recognised JS lockfile works — and so is reusable across all of Matt's JS/TS projects.

## Goals

- One command (`boot`) goes from "empty pane" to "dev server running in chosen worktree".
- Works in any terminal: tmux popup overlay when `$TMUX` is set, inline fzf otherwise.
- Cross-repo: detect package manager from lockfile, run install + start.
- Auto-resolve Metro/Expo port conflicts by incrementing from 8081.
- Behaves like `yarn start` from the user's perspective once running — Ctrl-C, exit codes, pane lifecycle all unchanged.

## Non-goals

- Not a team-distributed tool (yet). Personal-only for now; trivial to lift later by moving from dotfiles into a repo's `scripts/`.
- Does not create or destroy worktrees. Listing only.
- Does not auto-install missing dependencies (fzf, lockfile-implied package managers). Hard-fail with a one-line hint instead.
- No persistent state — no "last used worktree", no cache.
- No watch/restart loop. When the dev server exits, `boot` is already gone (it `exec`s).

## Invocation model

The user opens a fresh tmux pane (or any terminal) and runs `boot`. The script:

1. Resolves the current repo via `git rev-parse --show-toplevel`. Errors and exits 1 if not in a git repo.
2. Lists worktrees via `git worktree list --porcelain`, parsed into `<path>\t<branch>` rows for fzf.
3. Pipes rows into a picker:
   - `fzf-tmux -p 80%,60%` if `$TMUX` is set
   - plain `fzf` otherwise
4. On selection, `cd`s into the chosen path.
5. Detects the package manager from the lockfile (see below).
6. Finds the lowest free port starting at 8081 (`lsof -i :$port` loop, capped at 8181).
7. Runs `<pm> install` to ensure deps are current.
8. `exec`s the start script with the chosen port. The `exec` is load-bearing: once the dev server takes over, signals and exit codes propagate as if the user had run `<pm> start` directly.

### Port passing

The chosen port is passed two ways for safety:

- As an argument: `<pm> start --port <port>`. This works for the sea-flux `start` script because it forwards args into `expo start`.
- As env vars exported into the `exec`'d process: `RCT_METRO_PORT=<port>` and `EXPO_PACKAGER_PORT=<port>`. These are honored by Expo/Metro even when the `start` script does not forward args.

Belt-and-braces: either path alone would work for sea-flux today, but both together make the script resilient when used in other Expo/RN repos with differently-shaped `start` scripts.

## Components

A single bash file at `~/dots/bin/boot`, organised into the following functions:

| Function | Responsibility |
|----------|----------------|
| `find_repo_root()` | `git rev-parse --show-toplevel`. Errors if not in a git repo. |
| `list_worktrees(root)` | Parses `git worktree list --porcelain` into tab-separated `<path>\t<branch>` rows. |
| `pick_worktree(rows)` | Pipes rows through `fzf-tmux -p 80%,60%` (when `$TMUX`) or plain `fzf`. Returns selected path. Silent exit 0 on cancel. |
| `detect_pm(dir)` | Returns `yarn` / `pnpm` / `bun` / `npm` based on lockfile. Errors if none found. |
| `find_free_port(start)` | Increments from `start` (default 8081) up to `start + 100`, returning the first port where `lsof -i :$port` reports no listener. |
| `main()` | Orchestrates the above; final step is `exec` of `<pm> start --port <port>` with port env vars set. |

### Lockfile → package manager mapping

Checked in this order, first match wins:

1. `yarn.lock` → `yarn`
2. `pnpm-lock.yaml` → `pnpm`
3. `bun.lockb` → `bun`
4. `package-lock.json` → `npm`

If none match, hard-fail.

## Data flow

```
user runs `boot` in any dir under a git worktree
  │
  ├─ git rev-parse --show-toplevel       → repo root or error
  ├─ git worktree list --porcelain       → parsed rows: path \t branch
  ├─ fzf / fzf-tmux                      → user picks a row, or cancels
  ├─ cd <selected path>
  ├─ detect_pm <path>                    → yarn | pnpm | bun | npm
  ├─ find_free_port 8081                 → first free port via lsof
  ├─ <pm> install                        → ensures deps current
  └─ exec <pm> start --port <port>       → boot is gone; dev server owns the pane
       env RCT_METRO_PORT=<port> EXPO_PACKAGER_PORT=<port>
```

## Error handling

All failures hard-fail with a single-line message and a non-zero exit code. No retries, no fallbacks, no auto-install.

| Condition | Message | Exit |
|-----------|---------|------|
| `fzf` not on PATH | `boot: fzf not found. brew install fzf` | 1 |
| Not in a git repo | `boot: not a git repository` | 1 |
| No worktrees (defensive — should not happen) | `boot: no worktrees found` | 1 |
| User cancels fzf (Esc/Ctrl-C) | (silent) | 0 |
| No supported lockfile | `boot: no lockfile in <path>; can't detect package manager` | 1 |
| `<pm> install` fails | propagated from package manager | (pm's exit code) |
| All ports 8081–8181 busy | `boot: no free port in 8081-8181` | 1 |

## Testing

Single bash file, personal tool — full automated test setup is overkill. Manual test plan, run before declaring complete:

1. **Main repo, no other dev server running**: `cd ~/dev/sea-flux-frontend && boot` → picks main → Expo on 8081.
2. **Inside a worktree**: `cd ~/dev/sea-flux-frontend/.worktrees/perf-reporting && boot` → fzf still lists all repo worktrees, including main.
3. **Port collision**: leave (1) running, open another pane, `boot` again, pick a different worktree → second instance lands on 8082.
4. **Not a git repo**: `cd /tmp && boot` → errors cleanly.
5. **Inside tmux**: picker renders as `fzf-tmux` popup.
6. **Outside tmux** (e.g. raw Terminal.app): picker renders inline.
7. **Cancel**: Esc the picker → silent exit, no `cd`, no install.
8. **Cross-repo (optional)**: drop into a `pnpm`-based or `npm`-based repo of Matt's, run `boot` → correct package manager detected, install + start succeed.

If any case is hard to reproduce, the implementation should call that out rather than claim success.

## Files touched

- **New:** `~/dots/bin/boot` (executable bash script).
- **New:** symlink `~/.local/bin/boot` → `~/dots/bin/boot`.
- **New:** this design doc at `~/dots/docs/superpowers/specs/2026-04-29-boot-tool-design.md`.

No changes to the sea-flux-frontend repo or any other project repo.

## Open questions

None blocking. Possible follow-ups, not in scope:

- Promote to a team-shared tool by moving into `sea-flux-frontend/scripts/boot` and exposing as `yarn boot`.
- Add a `--no-install` flag to skip the install step on warm worktrees.
- Add a "recent worktrees" reorder using `~/.cache/boot/recent`.
- Detect when port 8081 is already serving Metro for the *same* worktree and just attach instead of starting a new one.
