#!/bin/sh
# Fuzzy session picker.
# With fzf: sessions annotated with running counts + Claude state
# (awaiting-first, then most-recently-attached). Without fzf: choose-tree.
#
# Pipeline: pane data + MRU-sorted session names -> session-annotate.awk
# -> sort (awaiting first, MRU within) -> fzf. Each fzf row is
# "<name><TAB><display>"; --with-nth=2.. hides the name, cut -f1 recovers it.

[ -f "$HOME/.tmux/scripts/fzf-theme.sh" ] && . "$HOME/.tmux/scripts/fzf-theme.sh"

ANNOTATE="$HOME/.tmux/scripts/session-annotate.awk"
TAB=$(printf '\t')

if command -v fzf >/dev/null 2>&1; then
    line=$(
        {
            tmux list-panes -a -F "P${TAB}#{session_name}${TAB}#{pane_current_command}${TAB}#{@claude-state}" 2>/dev/null
            tmux list-sessions -F "#{session_last_attached}${TAB}S${TAB}#{session_name}" 2>/dev/null \
                | sort -rn | cut -f2-
        } \
            | awk -f "$ANNOTATE" \
            | sort -t"$TAB" -k1,1n -k2,2n \
            | cut -f3- \
            | fzf --ansi --delimiter="$TAB" --with-nth=2.. \
                  --header='󰮪 Switch session' --border-label=' sessions '
    )
    session=$(printf '%s' "$line" | cut -f1)
    [ -n "$session" ] && tmux switch-client -t "$session"
else
    tmux choose-tree -s -O time
fi
