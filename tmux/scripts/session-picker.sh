#!/bin/sh
# Fuzzy session picker.
# With fzf: sessions grouped current / needs-attention / recent, annotated with
# a running count, the programs running (icon + count), and Claude state.
# Without fzf: choose-tree.
#
# The current session ($1, passed from the keybind as #{session_name}) is
# pinned to the top. Pipeline: pane data + MRU-sorted session names ->
# session-annotate.awk -> sort (by group, then MRU) -> fzf. Each fzf row is
# "<name><TAB><display>"; --with-nth=2.. hides the name, cut -f1 recovers it.
# Section-header rows carry an empty name, so selecting one is a no-op.

[ -f "$HOME/.tmux/scripts/fzf-theme.sh" ] && . "$HOME/.tmux/scripts/fzf-theme.sh"

ANNOTATE="$HOME/.tmux/scripts/session-annotate.awk"
TAB=$(printf '\t')

# Current session: the keybind passes it as $1; fall back to display-message
# if it is missing or arrived unexpanded.
CURRENT="${1:-}"
case "$CURRENT" in
    *'#{'* | '') CURRENT=$(tmux display-message -p '#{session_name}' 2>/dev/null) ;;
esac

if command -v fzf >/dev/null 2>&1; then
    line=$(
        {
            tmux list-panes -a -F "P${TAB}#{session_name}${TAB}#{pane_current_command}${TAB}#{@claude-state}" 2>/dev/null
            tmux list-sessions -F "#{session_last_attached}${TAB}S${TAB}#{session_name}" 2>/dev/null \
                | sort -rn | cut -f2-
        } \
            | awk -v cur="$CURRENT" -f "$ANNOTATE" \
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
