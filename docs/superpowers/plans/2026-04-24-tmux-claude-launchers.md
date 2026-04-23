# tmux Claude Launchers Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add `:claw` / `:clap` tmux user-commands and `prefix + W` / `prefix + P` keybindings that spawn a named claude-code session in a new window or pane, tying the tmux window name / pane title to `claude --name`.

**Architecture:** Pure tmux config — two `command-alias` entries and two `bind` entries in `keybindings.conf`, both routing through `command-prompt` so they share a single spawn template. `options.conf` enables pane border titles so the `clap` pane name is visible.

**Tech Stack:** tmux 3.2+ (for brace-grouped commands), claude-code CLI, zsh.

**Spec:** `docs/superpowers/specs/2026-04-24-tmux-claude-launchers-design.md`

**Verification note:** tmux config is verified manually after `prefix + r` reload — no automated test framework. Each task ends with a manual check and a commit.

---

### Task 1: Enable pane border titles

**Files:**
- Modify: `tmux/conf/options.conf`

- [ ] **Step 1: Read the current options.conf**

Run: `cat ~/dots/tmux/conf/options.conf`

Identify a sensible insertion point (near other display-related options; append at end if no obvious section).

- [ ] **Step 2: Append the pane border block**

Add at the end of `tmux/conf/options.conf`:

```tmux

##################################################
# PANE BORDER TITLES
#
# Shows a one-row header per pane with index and title.
# Used by :clap / prefix+P to make claude pane names visible.

set -g pane-border-status top
set -g pane-border-format " [#{pane_index}] #{pane_title} "
```

- [ ] **Step 3: Reload tmux config and verify**

From an existing tmux session: press `prefix + r` (which runs `source-file ~/.tmux.conf`).

Expected: every pane gains a one-row border at the top showing `[0]` followed by the current pane title (often the hostname or running command). No errors in the tmux status line.

If not already in tmux, run `tmux` first, then reload.

- [ ] **Step 4: Commit**

```bash
cd ~/dots
git add tmux/conf/options.conf
git commit -m "feat(tmux): enable pane border titles"
```

---

### Task 2: Add `claw` / `clap` command-aliases and keybindings

**Files:**
- Modify: `tmux/conf/keybindings.conf`

- [ ] **Step 1: Append the CLAUDE section**

Add at the end of `tmux/conf/keybindings.conf`:

```tmux

##################################################
# CLAUDE
#
# Spawn a named claude-code session.
#   :claw NAME       → new window named NAME, running `claude --name NAME`
#   :clap NAME       → new pane with title NAME, running `claude --name NAME`
#   prefix + W / P   → same, via interactive prompt
#
# Both command-alias and keybind route through command-prompt. The alias
# pre-fills via %1; pressing Enter confirms. A bare `:claw` (no arg)
# opens an empty prompt.

set -ga command-alias 'claw=command-prompt -p "claude window name:" -I "%1" { new-window -c "#{pane_current_path}" -n "%%" "claude --name %%" }'
set -ga command-alias 'clap=command-prompt -p "claude pane name:"   -I "%1" { split-window -h -c "#{pane_current_path}" -T "%%" "claude --name %%" }'

bind W command-prompt -p "claude window name:" { new-window -c "#{pane_current_path}" -n "%%" "claude --name %%" }
bind P command-prompt -p "claude pane name:"   { split-window -h -c "#{pane_current_path}" -T "%%" "claude --name %%" }
```

- [ ] **Step 2: Reload tmux config**

From an existing tmux session: press `prefix + r`.

Expected: status line shows `Config reloaded`, no errors.

- [ ] **Step 3: Verify `:claw` with a pre-filled name**

Press `prefix + :` to open the command prompt, type `claw test1`, press Enter.

Expected: a "claude window name:" prompt appears with `test1` pre-filled. Press Enter again.

Result: new tmux window named `test1`, claude starts with display name `test1`, cwd matches the originating pane.

Close the window (exit claude, close the shell) when done.

- [ ] **Step 4: Verify `:claw` with no arg**

Press `prefix + :`, type `claw`, press Enter.

Expected: empty "claude window name:" prompt. Type `test2`, press Enter.

Result: new window named `test2` running claude.

- [ ] **Step 5: Verify `prefix + W`**

Press `prefix + W`.

Expected: empty "claude window name:" prompt. Type `test3`, press Enter.

Result: new window named `test3` running claude.

- [ ] **Step 6: Verify `:clap` pre-filled**

Press `prefix + :`, type `clap test4`, press Enter, Enter.

Expected: current window splits horizontally (new pane to the right). The new pane's top border shows `[1] test4` (or similar index). Claude starts with name `test4`, cwd inherited from the originating pane.

- [ ] **Step 7: Verify `:clap` no-arg and `prefix + P`**

- Press `prefix + :`, type `clap`, press Enter, type `test5`, press Enter. New pane named `test5` appears.
- Press `prefix + P`, type `test6`, press Enter. New pane named `test6` appears.

- [ ] **Step 8: Verify default keybindings preserved**

- Press `prefix + w` (lowercase): the tmux window tree picker opens as normal. Press `q` to close.
- Press `prefix + p` (lowercase): focus moves to the previous pane. (Or is a no-op if only one pane.)

Both defaults still work — we only bound the uppercase variants.

- [ ] **Step 9: Clean up test windows/panes**

Close any leftover `test*` windows and panes: `prefix + &` to kill-window, `prefix + x` to kill-pane. Confirm with `y` when prompted.

- [ ] **Step 10: Commit**

```bash
cd ~/dots
git add tmux/conf/keybindings.conf
git commit -m "feat(tmux): add claw/clap claude launchers"
```

---

## Post-implementation check

After both tasks are committed, run:

```bash
cd ~/dots && git log --oneline -5
```

Expected to see the two new commits (`feat(tmux): add claw/clap claude launchers`, `feat(tmux): enable pane border titles`) plus the earlier spec commit.
