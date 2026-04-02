#!/bin/sh
# Fuzzy session picker.
# Uses fzf if available, otherwise falls back to tmux choose-tree.

if command -v fzf >/dev/null 2>&1; then
    session=$(tmux list-sessions -F "#{session_name}: #{session_windows} windows (#{session_attached} attached)" 2>/dev/null \
        | fzf --reverse --prompt="Switch session: " \
        | cut -d: -f1)
    if [ -n "$session" ]; then
        tmux switch-client -t "$session"
    fi
else
    tmux choose-tree -s
fi
