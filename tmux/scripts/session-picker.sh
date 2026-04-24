#!/bin/sh
# Fuzzy session picker.
# Uses fzf if available, otherwise falls back to tmux choose-tree.

[ -f "$HOME/.tmux/scripts/fzf-theme.sh" ] && . "$HOME/.tmux/scripts/fzf-theme.sh"

if command -v fzf >/dev/null 2>&1; then
    session=$(tmux list-sessions -F "#{session_name}: #{session_windows} windows (#{session_attached} attached)" 2>/dev/null \
        | fzf --header='󰮪 Switch session' --border-label=' sessions ' \
        | cut -d: -f1)
    if [ -n "$session" ]; then
        tmux switch-client -t "$session"
    fi
else
    tmux choose-tree -s
fi
