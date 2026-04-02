#!/bin/sh
# Saves all tmux sessions, windows, panes and their working directories.
# Format: session_name:window_index:window_name:pane_index:pane_current_path

SAVE_FILE="$HOME/.tmux/sessions.txt"
mkdir -p "$(dirname "$SAVE_FILE")"

: > "$SAVE_FILE"

tmux list-panes -a -F "#{session_name}:#{window_index}:#{window_name}:#{pane_index}:#{pane_current_path}" >> "$SAVE_FILE"

tmux display-message "Sessions saved to $SAVE_FILE"
