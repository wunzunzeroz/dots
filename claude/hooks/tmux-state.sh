#!/bin/sh
# Stamp the current tmux pane with Claude Code's lifecycle state
# (working | awaiting | idle), read by tmux/scripts/session-picker.sh.
# No-op outside tmux; never blocks Claude even if tmux is absent.
[ -n "${TMUX_PANE:-}" ] && tmux set-option -p -t "$TMUX_PANE" @claude-state "$1" 2>/dev/null
exit 0
