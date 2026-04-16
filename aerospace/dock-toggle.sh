#!/usr/bin/env bash
#
# dock-toggle.sh — Smart dock/undock for Aerospace
# Detects monitor count and redistributes workspaces accordingly.
# Idempotent: safe to run multiple times.
#
# Usage: bound to cmd-ctrl-d in aerospace.toml
#        exec-and-forget bash ~/.config/aerospace/dock-toggle.sh

set -euo pipefail

AEROSPACE="/opt/homebrew/bin/aerospace"
MONITOR_COUNT=$("$AEROSPACE" list-monitors --json | /usr/bin/jq length)

LG_PATTERN="LG ULTRAWIDE"
BUILTIN_PATTERN="Built-in Retina Display"

# Find the monitor ID for the LG (if connected)
LG_ID=$("$AEROSPACE" list-monitors --json | /usr/bin/jq -r ".[] | select(.\"monitor-name\" | test(\"$LG_PATTERN\"; \"i\")) | .\"monitor-id\"")

if [ "$MONITOR_COUNT" -ge 2 ] && [ -n "$LG_ID" ]; then
    # Docked: move main workspaces to the LG
    "$AEROSPACE" move-workspace-to-monitor --workspace "main:1:dev" "$LG_ID" 2>/dev/null || true
    "$AEROSPACE" move-workspace-to-monitor --workspace "main:2:code" "$LG_ID" 2>/dev/null || true
    "$AEROSPACE" move-workspace-to-monitor --workspace "main:3:data" "$LG_ID" 2>/dev/null || true
else
    # Undocked: move everything to the single available monitor
    BUILTIN_ID=$("$AEROSPACE" list-monitors --json | /usr/bin/jq -r ".[0].\"monitor-id\"")
    for ws in $("$AEROSPACE" list-workspaces --all); do
        "$AEROSPACE" move-workspace-to-monitor --workspace "$ws" "$BUILTIN_ID" 2>/dev/null || true
    done
fi
