---
name: sitrep
description: Use when Matt asks for a sitrep, asks to be caught up or brought up to speed, asks "where were we", returns to a chat after a gap, or wants the current state of in-flight work and the next step.
---

# Sitrep

A 15-second re-entry brief: what is in flight, why it matters, and the next
move. Pitched at Head of Engineering altitude — outcomes and decisions, not a
walkthrough of the diff.

## Gather facts first

One Bash call, before writing anything:

```bash
git status --short && git log --oneline -12 && git diff --stat
```

Then draw on this conversation (including anything already compacted into a
summary) and any in-flight file under `docs/superpowers/specs/` or
`docs/superpowers/plans/` that matches the current work.

Outside a git repo: drop the branch and uncommitted-count segments of the
header, drop all SHAs, and build the brief from conversation alone.

## The output contract

The reply is exactly these parts, in this order. It begins at the header line.

```
SITREP · <repo> · <branch> · <N> files uncommitted

<One sentence: the work in flight, present tense.>

WHY   <The problem being solved. Consequence, not mechanics.>

DONE  ✔ <outcome>                                        <sha>
      ✔ <outcome>                                        <sha>
      ~ <outcome>                                  uncommitted

NEXT  1 <action — most unblocking first>
      2 <action>

FLAG  <something that needs Matt — one line each>
```

| Block | Cap | Notes |
|---|---|---|
| Headline | 1 sentence | the work, present tense — not the session |
| WHY | 2 lines | always present; why this work is worth doing |
| DONE | 5 items | newest first; `✔` committed with short SHA, `~` uncommitted |
| NEXT | 3 items | append `+N more` when others exist |
| FLAG | 3 items | when there is nothing to flag, the block is absent |
| Total | 25 lines | over budget: thin DONE, keep NEXT whole |

## Where each fact goes

| Fact | Destination |
|---|---|
| Committed change | DONE, `✔` + short SHA |
| Change on disk, not yet committed | DONE, `~` + `uncommitted` |
| Claimed working in chat, no commit and no verification run | FLAG, as `unverified` |
| Verification step named but never run | FLAG |
| Open question only Matt can settle | FLAG, phrased as the decision |
| Dirty file unrelated to the work in flight | FLAG |
| Approach tried and abandoned | omitted |

## Common mistakes

- **DONE entries naming files instead of outcomes.** `✔ tmux/conf/options.conf
  edited` carries no information; `✔ picker lists every window` says what
  changed.
- **NEXT restating the goal.** "Finish the picker" is not an action; "decide:
  truncate vs wrap names over 32 chars" is.
- **DONE padded with every commit on the branch.** Five outcomes, newest
  first. Full history is what `git log` is for.
