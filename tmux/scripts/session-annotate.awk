# Aggregate tmux panes per session and annotate with Claude state.
# Input (tab-separated, tagged):
#   P <tab> session <tab> pane_current_command <tab> @claude-state
#   S <tab> session                 (session lines pre-sorted MRU by caller)
# Output (tab-separated):
#   prio <tab> rank <tab> session <tab> display
# where prio=0 if the session has an awaiting Claude (else 1), rank is MRU index.
# The display field carries ANSI SGR colour on the state labels, so the picker
# must pass fzf --ansi. Colours mirror tmux/conf/theme.conf (Tokyo Night Storm).
BEGIN {
  FS = "\t"; OFS = "\t"
  esc = sprintf("%c", 27); reset = esc "[0m"
  c_await = esc "[38;2;224;175;104m"   # yellow  #e0af68
  c_work  = esc "[38;2;125;207;255m"   # cyan    #7dcfff
  c_idle  = esc "[38;2;86;95;137m"     # comment #565f89
  i_await = "󰂚"                         # bell
  i_work  = "󰥔"                         # clock
  i_idle  = "󰒲"                         # snooze
}

$1 == "P" {
  sess = $2; cmd = $3; state = $4
  if (cmd != "zsh" && cmd != "-zsh" && cmd != "bash" && cmd != "-bash" && cmd != "sh" && cmd != "-sh" && cmd != "fish" && cmd != "login") {
    run[sess]++
    if (state == "working")       work[sess]++
    else if (state == "awaiting") await[sess]++
    else if (state == "idle")     idle[sess]++
  }
  next
}

$1 == "S" {
  sess = $2
  rank++
  states = ""
  if (await[sess] > 0) states = states (states == "" ? "" : ", ") c_await i_await sprintf(" %d awaiting", await[sess]) reset
  if (work[sess]  > 0) states = states (states == "" ? "" : ", ") c_work  i_work  sprintf(" %d working",  work[sess])  reset
  if (idle[sess]  > 0) states = states (states == "" ? "" : ", ") c_idle  i_idle  sprintf(" %d idle",     idle[sess])  reset
  disp = sprintf("%-12s %d running", sess, run[sess] + 0)
  if (states != "") disp = disp "   " states
  prio = (await[sess] > 0) ? 0 : 1
  print prio, rank, sess, disp
}
