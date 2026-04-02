#!/bin/sh
# Prints the current git branch for the active pane's directory.
# Returns empty string if not in a git repo.

cd "$1" 2>/dev/null || exit 0
branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
if [ -n "$branch" ]; then
    printf " %s" "$branch"
fi
