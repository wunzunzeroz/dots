# Aggregate tmux panes per session and annotate with a running count, the
# programs running (icon + count), and Claude state (icon + word), grouped into
# current / needs-attention / recent sections.
#
# Input (tab-separated, tagged). Pass the current session via -v cur=NAME:
#   P <tab> session <tab> pane_current_command <tab> @claude-state
#   S <tab> session                 (session lines pre-sorted MRU by caller)
#
# Output (tab-separated), ready for `sort -k1,1n -k2,2n | cut -f3-`:
#   group <tab> rank <tab> session <tab> display
#   group: 0 current, 1 needs-attention (awaiting), 2 recent. rank is MRU index.
# Section header rows are emitted in END as `group <tab> 0 <tab> <empty> <tab>
# display`, so they sort to the top of their section; the empty session field
# makes selecting a header a no-op in the picker.
#
# The display field carries ANSI SGR colour, so the picker must pass fzf --ansi.
# Colours + icons mirror tmux/conf/theme.conf (Tokyo Night Storm) and the
# statusbar's Nerd Font family.

function picon(c) { return (c in ic) ? ic[c] : ic_def }

BEGIN {
  FS = "\t"; OFS = "\t"
  esc = sprintf("%c", 27); reset = esc "[0m"
  c_await = esc "[38;2;224;175;104m"   # yellow  #e0af68
  c_work  = esc "[38;2;125;207;255m"   # cyan    #7dcfff
  c_idle  = esc "[38;2;86;95;137m"     # comment #565f89
  c_muted = esc "[38;2;86;95;137m"     # comment #565f89  (run icon + programs)
  c_cur   = esc "[38;2;187;154;247m"   # purple  #bb9af7  (current marker)
  c_win   = esc "[38;2;122;162;247m"   # blue    #7aa2f7  (active window name)
  WINW    = 16                          # active-window column width
  i_await = "󰂚"                         # bell
  i_work  = "󰥔"                         # clock
  i_idle  = "󰒲"                         # snooze
  i_run   = "󰜎"                         # running
  ic["node"]  = "󰎙"; ic["nodejs"] = "󰎙"
  ic["python"]= "󰌠"; ic["python3"]= "󰌠"
  ic["docker"]= "󰡨"
  ic["git"]   = "󰊢"
  ic["go"]    = "󰟓"
  ic["psql"]  = "󰆼"; ic["mysql"] = "󰆼"; ic["postgres"] = "󰆼"
  ic["nvim"]  = "󰏫"; ic["vim"] = "󰏫"       # pencil (nf-md; font lacks a vim glyph)
  ic_def      = "󰆍"                     # console (fallback)
}

$1 == "P" {
  sess = $2; cmd = $3; state = $4
  if (cmd=="zsh"||cmd=="-zsh"||cmd=="bash"||cmd=="-bash"||cmd=="sh"||cmd=="-sh"||cmd=="fish"||cmd=="login") next
  run[sess]++
  isclaude = (state != "") || (cmd ~ /^[0-9]+\.[0-9]+/)
  if (isclaude) {
    if (state == "working")       work[sess]++
    else if (state == "awaiting") await[sess]++
    else if (state == "idle")     idle[sess]++
  } else {
    if (!((sess SUBSEP cmd) in pc)) plist[sess] = plist[sess] (plist[sess] == "" ? "" : SUBSEP) cmd
    pc[sess SUBSEP cmd]++
  }
  next
}

$1 == "S" {
  sess = $2; win = $3
  rank++
  if (sess == cur)          g = 0
  else if (await[sess] > 0) g = 1
  else                      g = 2
  seen[g] = 1

  mark = (g == 0) ? (c_cur "●" reset " ") : "  "
  # Active window name: plain text, so it pads reliably. Truncate to keep the
  # columns after it aligned.
  if (length(win) > WINW) win = substr(win, 1, WINW - 1) "…"
  line = mark sprintf("%-12s ", sess) c_win sprintf("%-" WINW "s", win) reset \
         "  " c_muted i_run reset " " (run[sess] + 0) " running"

  # State labels come first so they sit at a fixed offset after "N running"
  # (the run icon is the same glyph on every row) and thus align across rows.
  states = ""
  if (await[sess] > 0) states = states (states == "" ? "" : ", ") c_await i_await sprintf(" %d awaiting", await[sess]) reset
  if (work[sess]  > 0) states = states (states == "" ? "" : ", ") c_work  i_work  sprintf(" %d working",  work[sess])  reset
  if (idle[sess]  > 0) states = states (states == "" ? "" : ", ") c_idle  i_idle  sprintf(" %d idle",     idle[sess])  reset
  if (states != "") line = line "   " states

  # Programs trail at the end: their icons render at unpredictable widths, so
  # keeping them last means nothing that must align sits after them.
  if (plist[sess] != "") {
    n = split(plist[sess], arr, SUBSEP)
    procs = ""
    for (i = 1; i <= n; i++) procs = procs (procs == "" ? "" : "  ") picon(arr[i]) sprintf(" %d", pc[sess SUBSEP arr[i]])
    line = line "   " c_muted procs reset
  }

  print g, rank, sess, line
}

END {
  if (1 in seen) print 1, 0, "", c_muted "─ needs attention ─" reset
  if (2 in seen) print 2, 0, "", c_muted "─ recent ─" reset
}
