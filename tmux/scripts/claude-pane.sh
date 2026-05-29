#!/usr/bin/env bash
# Launch or resume a Claude Code session in the current tmux pane, stamping the
# pane with its session id + display name so it can be saved and restored across
# reboots (see resurrect-save-claude.sh / resurrect-restore-claude.sh).
#
#   claude-pane.sh <name>              # new session (fresh uuid)
#   claude-pane.sh <name> <session-id> # resume an existing session by id
set -u

name="${1:-claude}"
sid="${2:-}"

if [ -z "$sid" ]; then
  sid="$(uuidgen | tr '[:upper:]' '[:lower:]')"
  set -- --session-id "$sid"
else
  set -- --resume "$sid"
fi

# Stamp the pane: read by the resurrect save hook and by the status bar.
if [ -n "${TMUX_PANE:-}" ]; then
  tmux set-option -p -t "$TMUX_PANE" @claude-session-id "$sid"
  tmux set-option -p -t "$TMUX_PANE" @claude-pane "$name"
fi

exec claude "$@" --name "$name"
