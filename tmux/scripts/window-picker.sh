#!/bin/sh
# Fuzzy window picker.
# Uses fzf if available, otherwise falls back to tmux choose-tree.

[ -f "$HOME/.tmux/scripts/fzf-theme.sh" ] && . "$HOME/.tmux/scripts/fzf-theme.sh"

if command -v fzf >/dev/null 2>&1; then
    target=$(tmux list-windows -a -F "#{session_name}:#{window_index} #{window_name}#{?window_active, (active),}" 2>/dev/null \
        | fzf --header=' Switch window' --border-label=' windows ' \
        | awk '{print $1}')
    if [ -n "$target" ]; then
        tmux switch-client -t "$target"
    fi
else
    tmux choose-tree -Zw
fi
