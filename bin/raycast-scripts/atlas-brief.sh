#!/bin/zsh

# @raycast.schemaVersion 1
# @raycast.title Atlas — Generate today's brief
# @raycast.mode fullOutput
# @raycast.packageName Atlas
# @raycast.icon 📰
# @raycast.description Run /daily-brief on-demand
# @raycast.author Matt Chapman

set -euo pipefail

cd "$HOME/atlas"
# Invoke Claude Code CLI with the daily-brief skill
claude --skill daily-brief 2>&1
