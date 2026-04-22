#!/bin/zsh

# @raycast.schemaVersion 1
# @raycast.title Brain — Inbox
# @raycast.mode compact
# @raycast.packageName Brain
# @raycast.icon 📥
# @raycast.argument1 { "type": "text", "placeholder": "Inbox item" }
# @raycast.description Append an item to the inbox
# @raycast.author Matt Chapman

set -euo pipefail

text="$1"
vault="$HOME/brain"
file="$vault/inbox.md"
ts="$(date +%Y-%m-%dT%H:%M)"

# Priority/date prefix parsing (same as brain-action.sh)
priority=""
if [[ "$text" == "!!! "* ]]; then priority="⏬"; text="${text#!!! }"; fi
if [[ "$text" == "!! "* ]]; then priority="🔼"; text="${text#!! }"; fi
if [[ "$text" == "! "* ]]; then priority="🔺"; text="${text#! }"; fi

due=""
if [[ "$text" =~ ^d:([^ ]+)\ (.*)$ ]]; then
  raw="${match[1]}"
  text="${match[2]}"
  case "$raw" in
    +*)
      days="${raw#+}"
      due="$(date -v+${days}d +%Y-%m-%d)"
      ;;
    mon|tue|wed|thu|fri|sat|sun)
      due="$(date -v+1d -v"${raw}" +%Y-%m-%d 2>/dev/null || date +%Y-%m-%d)"
      ;;
    *)
      due="$raw"
      ;;
  esac
fi

line="- [ ] $text"
[[ -n "$priority" ]] && line="$line $priority"
[[ -n "$due" ]] && line="$line 📅 $due"
line="$line <!-- captured $ts -->"

# Append under ## Unprocessed heading
awk -v line="$line" '
  /^## Unprocessed$/ { print; in_section=1; next }
  in_section && /^## / && !/^## Unprocessed$/ { print line; in_section=0 }
  { print }
  END { if (in_section) print line }
' "$file" > "$file.tmp" && mv "$file.tmp" "$file"

echo "Added to inbox: $text"
