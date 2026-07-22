# Aggregate tmux panes per session AND per window, and render a two-level
# picker list: a row per session (grouped current / needs-attention / recent),
# followed by a row per window when the session has more than one.
#
# Input (tab-separated, tagged). Pass the current session via -v cur=NAME.
# P and W lines must precede S lines:
#   P <tab> session <tab> window_index <tab> pane_current_command <tab> @claude-state
#   W <tab> session <tab> window_index <tab> window_name <tab> window_active
#   S <tab> session <tab> active_window_name   (session lines pre-sorted MRU)
#
# Output (tab-separated), for `sort -k1,1n -k2,2n -k3,3n | cut -f4-`:
#   group <tab> rank <tab> sub <tab> session <tab> window_index <tab> display
#   group: 0 current, 1 needs-attention, 2 recent. rank: MRU index.
#   sub: 0 for the session row, window_index+1 for window rows, so a session's
#   windows follow it in index order.
#   Header rows carry rank 0 and an empty session field, making them no-ops.
#   Window rows carry window_index so the picker can select-window.
#
# The display field carries ANSI SGR colour, so the picker must pass fzf --ansi.
# Colours + icons mirror tmux/conf/theme.conf (Tokyo Night Storm).

function picon(c) { return (c in ic) ? ic[c] : ic_def }

function addprog(key, c) {
  if (!((key SUBSEP c) in pc)) plist[key] = plist[key] (plist[key] == "" ? "" : SUBSEP) c
  pc[key SUBSEP c]++
}

# Truncate to the window column width so later columns stay aligned.
function trunc(s) { return (length(s) > WINW) ? substr(s, 1, WINW - 1) "…" : s }

# Render "N running", the state labels and the program strip for one
# aggregation key -- a session, or a session+window. Same vocabulary at both
# levels. States precede programs so they sit at a fixed offset and align.
function stats(key,   out, st, procs, n, arr, i) {
  out = c_muted i_run reset " " (run[key] + 0) " running"
  st = ""
  if (await[key] > 0) st = st (st == "" ? "" : ", ") c_await i_await sprintf(" %d awaiting", await[key]) reset
  if (work[key]  > 0) st = st (st == "" ? "" : ", ") c_work  i_work  sprintf(" %d working",  work[key])  reset
  if (idle[key]  > 0) st = st (st == "" ? "" : ", ") c_idle  i_idle  sprintf(" %d idle",     idle[key])  reset
  if (st != "") out = out "   " st
  if (plist[key] != "") {
    n = split(plist[key], arr, SUBSEP)
    procs = ""
    for (i = 1; i <= n; i++) procs = procs (procs == "" ? "" : "  ") picon(arr[i]) sprintf(" %d", pc[key SUBSEP arr[i]])
    out = out "   " c_muted procs reset
  }
  return out
}

BEGIN {
  FS = "\t"; OFS = "\t"
  esc = sprintf("%c", 27); reset = esc "[0m"
  c_await = esc "[38;2;224;175;104m"   # yellow  #e0af68
  c_work  = esc "[38;2;125;207;255m"   # cyan    #7dcfff
  c_idle  = esc "[38;2;86;95;137m"     # comment #565f89
  c_muted = esc "[38;2;86;95;137m"     # comment #565f89  (run icon + programs)
  c_cur   = esc "[38;2;187;154;247m"   # purple  #bb9af7  (current / active marker)
  c_win   = esc "[38;2;122;162;247m"   # blue    #7aa2f7  (window names)
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
  ic["nvim"]  = "󰏫"; ic["vim"] = "󰏫"    # pencil (nf-md; font lacks a vim glyph)
  ic_def      = "󰆍"                     # console (fallback)
  WINW = 16                             # window-name column width
}

$1 == "P" {
  sess = $2; widx = $3; cmd = $4; state = $5
  if (cmd=="zsh"||cmd=="-zsh"||cmd=="bash"||cmd=="-bash"||cmd=="sh"||cmd=="-sh"||cmd=="fish"||cmd=="login") next
  wkey = sess SUBSEP widx
  run[sess]++; run[wkey]++
  isclaude = (state != "") || (cmd ~ /^[0-9]+\.[0-9]+/)
  if (isclaude) {
    if (state == "working")       { work[sess]++;  work[wkey]++ }
    else if (state == "awaiting") { await[sess]++; await[wkey]++ }
    else if (state == "idle")     { idle[sess]++;  idle[wkey]++ }
  } else {
    addprog(sess, cmd); addprog(wkey, cmd)
  }
  next
}

$1 == "W" {
  sess = $2; widx = $3
  wname[sess, widx]   = $4
  wactive[sess, widx] = $5
  wlist[sess] = wlist[sess] (wlist[sess] == "" ? "" : SUBSEP) widx
  wcount[sess]++
  next
}

$1 == "S" {
  sess = $2; awin = $3
  rank++
  if (sess == cur)          g = 0
  else if (await[sess] > 0) g = 1
  else                      g = 2
  seen[g] = 1

  mark = (g == 0) ? (c_cur "●" reset " ") : "  "
  line = mark sprintf("%-12s ", sess) c_win sprintf("%-" WINW "s", trunc(awin)) reset "  " stats(sess)
  print g, rank, 0, sess, "", line

  # Window rows only when there is more than one -- a lone window would just
  # restate the session row.
  if (wcount[sess] > 1) {
    wn = split(wlist[sess], warr, SUBSEP)
    for (wi = 1; wi <= wn; wi++) {
      w = warr[wi]
      # ASCII marker: it pads predictably, unlike a multi-byte glyph.
      idx = (wactive[sess, w] == "1" ? "  > " : "    ") w
      wrow = "  " (wactive[sess, w] == "1" ? c_cur : c_muted) sprintf("%-12s", idx) reset " " \
             c_win sprintf("%-" WINW "s", trunc(wname[sess, w])) reset "  " stats(sess SUBSEP w)
      print g, rank, w + 1, sess, w, wrow
    }
  }
}

END {
  if (1 in seen) print 1, 0, 0, "", "", c_muted "─ needs attention ─" reset
  if (2 in seen) print 2, 0, 0, "", "", c_muted "─ recent ─" reset
}
