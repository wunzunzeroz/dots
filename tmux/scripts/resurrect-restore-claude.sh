#!/usr/bin/env bash
# resurrect post-restore hook (@resurrect-hook-post-restore-all):
# Resume each saved Claude conversation in its pane. Runs after resurrect has
# rebuilt panes (as bare shells in the right cwd); we respawn the Claude ones.
set -u

rdir="$(tmux show-option -gqv @resurrect-dir 2>/dev/null)"
rdir="${rdir:-$HOME/.local/share/tmux/resurrect}"
case "$rdir" in "~/"*) rdir="$HOME/${rdir#\~/}";; esac
in="$rdir/claude-panes.tsv"
[ -f "$in" ] || exit 0
wrapper="${HOME}/.tmux/scripts/claude-pane.sh"

while IFS=$'\t' read -r s w p cwd sid name; do
  [ -z "${sid:-}" ] && continue
  target="${s}:${w}.${p}"
  cmd="$wrapper $(printf '%q' "${name:-claude}") $(printf '%q' "$sid")"
  tmux respawn-pane -k -c "$cwd" -t "$target" "$cmd" 2>/dev/null || true
done < "$in"
