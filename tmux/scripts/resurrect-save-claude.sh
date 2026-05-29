#!/usr/bin/env bash
# resurrect post-save hook (@resurrect-hook-post-save-all):
# Persist each Claude pane's positional address, cwd, session id and label so
# the restore hook can resume the exact conversation in the exact pane.
# Tab-separated columns: session  window  pane  cwd  session-id  name
set -u

# Resolve resurrect's snapshot dir (honour @resurrect-dir; else XDG default).
rdir="$(tmux show-option -gqv @resurrect-dir 2>/dev/null)"
rdir="${rdir:-$HOME/.local/share/tmux/resurrect}"
case "$rdir" in "~/"*) rdir="$HOME/${rdir#\~/}";; esac
out="$rdir/claude-panes.tsv"
mkdir -p "$rdir"
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
