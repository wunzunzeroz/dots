#!/bin/zsh

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Brain — Action (today)
# @raycast.mode compact
# @raycast.packageName Brain

# Optional parameters:
# @raycast.icon ✅
# @raycast.argument1 { "type": "text", "placeholder": "Action" }
# @raycast.description Append an action to today's daily note
# @raycast.author Matt Chapman

set -euo pipefail

text="$1"
vault="$HOME/brain"
today="$(date +%Y-%m-%d)"
file="$vault/daily-notes/$today.md"
template="$vault/_TEMPLATE/daily-note.md"
ts="$(date +%Y-%m-%dT%H:%M)"

# Parse priority prefixes (! !! !!!)
priority=""
if [[ "$text" == "!!! "* ]]; then priority="⏬"; text="${text#!!! }"; fi
if [[ "$text" == "!! "* ]]; then priority="🔼"; text="${text#!! }"; fi
if [[ "$text" == "! "* ]]; then priority="🔺"; text="${text#! }"; fi

# Parse due date prefix (d:mon, d:2026-04-28, d:+3)
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

# Build task line
line="- [ ] $text"
[[ -n "$priority" ]] && line="$line $priority"
[[ -n "$due" ]] && line="$line 📅 $due"
line="$line <!-- captured $ts -->"

# Create file from template if missing
if [[ ! -f "$file" ]]; then
  mkdir -p "$(dirname "$file")"
  # Expand template date tokens manually (Templater won't run from CLI)
  sed -e "s/<% tp.date.now(\"YYYY-MM-DD\") %>/$today/g" \
      -e "s/<% tp.date.now(\"dddd\") %>/$(date +%A)/g" \
      "$template" > "$file"
fi

# Append under ## Actions heading
awk -v line="$line" '
  /^## Actions$/ { print; in_actions=1; next }
  in_actions && /^## / && !/^## Actions$/ { print line; in_actions=0 }
  { print }
  END { if (in_actions) print line }
' "$file" > "$file.tmp" && mv "$file.tmp" "$file"

echo "Added to today's Actions: $text"
