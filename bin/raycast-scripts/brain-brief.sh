#!/bin/zsh

# @raycast.schemaVersion 1
# @raycast.title Brain — Generate today's brief
# @raycast.mode fullOutput
# @raycast.packageName Brain
# @raycast.icon 📰
# @raycast.description Run /daily-brief on-demand
# @raycast.author Matt Chapman

set -euo pipefail

cd "$HOME/brain"
# Invoke Claude Code CLI with the daily-brief skill
claude --skill daily-brief 2>&1
