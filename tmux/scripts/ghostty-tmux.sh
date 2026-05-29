#!/bin/zsh -l
# Ghostty launch command: every Ghostty surface drops into tmux.
# Login shell (-l) guarantees tmux is on PATH even when Ghostty is GUI-launched
# with a minimal environment. Matt's zsh rc has no tmux auto-start, so no
# recursion risk.
#
# First launch starts the server (continuum auto-restores the last snapshot);
# subsequent windows attach to the running server.

if tmux has-session 2>/dev/null; then
  exec tmux attach
fi

# No server yet: starting it triggers continuum-restore (fires on server start),
# which rebuilds the saved sessions. The loop covers the restore-vs-attach race.
tmux start-server
for _ in 1 2 3 4 5 6 7 8 9 10; do
  tmux has-session 2>/dev/null && break
  sleep 0.3
done

exec tmux attach 2>/dev/null || exec tmux new-session
