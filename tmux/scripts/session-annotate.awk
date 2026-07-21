# Aggregate tmux panes per session and annotate with Claude state.
# Input (tab-separated, tagged):
#   P <tab> session <tab> pane_current_command <tab> @claude-state
#   S <tab> session                 (session lines pre-sorted MRU by caller)
# Output (tab-separated):
#   prio <tab> rank <tab> session <tab> display
# where prio=0 if the session has an awaiting Claude (else 1), rank is MRU index.
BEGIN { FS = "\t"; OFS = "\t" }

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
  ann = ""
  if (await[sess] > 0) ann = ann sprintf(" ⏸%d", await[sess])
  if (work[sess]  > 0) ann = ann sprintf(" ⚡%d", work[sess])
  if (idle[sess]  > 0) ann = ann sprintf(" ✓%d", idle[sess])
  disp = sprintf("%-12s %d running%s", sess, run[sess] + 0, ann)
  prio = (await[sess] > 0) ? 0 : 1
  print prio, rank, sess, disp
}
