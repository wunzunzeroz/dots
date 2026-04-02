#!/bin/sh
# Restores tmux sessions from saved state.
# Skips sessions that already exist. Does not restore running processes.

SAVE_FILE="$HOME/.tmux/sessions.txt"

if [ ! -f "$SAVE_FILE" ]; then
    tmux display-message "No saved sessions found at $SAVE_FILE"
    exit 0
fi

while IFS=: read -r session_name window_index window_name pane_index pane_dir; do
    # Skip empty lines
    [ -z "$session_name" ] && continue

    # Check if session exists
    if ! tmux has-session -t "$session_name" 2>/dev/null; then
        tmux new-session -d -s "$session_name" -c "$pane_dir"
        # First window is created with the session, rename it
        tmux rename-window -t "${session_name}:1" "$window_name"
        continue
    fi

    # Check if window exists in session
    if ! tmux list-windows -t "$session_name" -F "#{window_index}" | grep -q "^${window_index}$"; then
        tmux new-window -t "${session_name}:${window_index}" -n "$window_name" -c "$pane_dir"
        continue
    fi

    # Add pane if pane_index > 0 (first pane already exists with the window)
    if [ "$pane_index" -gt 0 ] 2>/dev/null; then
        tmux split-window -t "${session_name}:${window_index}" -c "$pane_dir"
    fi
done < "$SAVE_FILE"

tmux display-message "Sessions restored from $SAVE_FILE"
