#!/usr/bin/env bash
# One-time: add Ghostty to macOS Login Items so tmux auto-starts on login.
# Idempotent -- safe to run repeatedly.
set -u

osascript <<'OSA'
tell application "System Events"
  if not (exists login item "Ghostty") then
    make login item at end with properties {path:"/Applications/Ghostty.app", hidden:false}
  end if
end tell
OSA

echo "Ghostty login item ensured."
