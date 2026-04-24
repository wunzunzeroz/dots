#!/bin/sh
# Tokyo Night Storm fzf theme. Source this file to set FZF_DEFAULT_OPTS
# before invoking fzf. Palette mirrors tmux/conf/theme.conf.

export FZF_DEFAULT_OPTS="\
--layout=reverse \
--border=rounded \
--border-label-pos=3 \
--pointer='▶' \
--marker='✓' \
--prompt='→ ' \
--color=bg:#1a1b26,bg+:#414868 \
--color=fg:#a9b1d6,fg+:#c0caf5:bold \
--color=hl:#7aa2f7,hl+:#bb9af7 \
--color=pointer:#bb9af7,marker:#9ece6a \
--color=spinner:#7dcfff,header:#7dcfff \
--color=info:#7aa2f7,prompt:#bb9af7 \
--color=border:#7aa2f7,label:#a9b1d6"
