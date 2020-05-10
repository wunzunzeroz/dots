#  mttchpmn  _               _
#          | |__   __ _ ___| |__  _ __ ___
#          | '_ \ / _` / __| '_ \| '__/ __|
#         _| |_) | (_| \__ \ | | | | | (__
#        (_)_.__/ \__,_|___/_| |_|_|  \___|
#

##################################################
# UBUNTU DEFAULTS

# Load defaults if they exist
if [ -f ~/.bashdefaults ]; then
  . ~/.bashdefaults
fi

# Set default editor
export EDITOR=vim

##################################################
# ALIASES

# Utility
alias cl='clear'
alias x='exit'
alias duh='du -h --max-depth=1'
alias dfh='df -h'
alias cp='cp -v'
alias rm='rm -i'

# Show interactive prompt when using rm -rf
nuke() {
  FILEPATHS=$@
  if (whiptail --title "ARE YOU SURE" --yesno --yes-button "NUKE THE FUCKER" --no-button "Nah, forget it" "THIS WILL FORCIBLY DELETE: $(echo $FILEPATHS)" 8 78); then
    rm -rfv $FILEPATHS
  else
    return
  fi
}

commit() {
  # Initialize vars so we can modify later if calling function recursively
  LABEL=${1:-Enter the commit message}
  PLACEHOLDER=${2:-""}

  MSG=$(whiptail --title "GIT COMMIT" --ok-button "COMMIT" --inputbox "$LABEL" 8 78 "$PLACEHOLDER" 3>&1 1>&2 2>&3) # A trick to swap stdout and stderr.
  exitstatus=$?

  # User has selected commit
  if [ $exitstatus = 0 ]; then
    if [ "${#MSG}" -le 50 ]; then
      # Commit msg < 50 chars
      git commit -m "$MSG"
    else
      # Commit msg > 50 chars
      LABEL="COMMIT MESSAGE LONGER THAN 50 CHARS ("${#MSG}") - Enter shorter message"
      # Call function recursively, changing label and placeholder vars
      commit "$LABEL" "$MSG"
    fi
  else
    # User selected cancel
    return
  fi
}

# Git
alias gs='git status'
alias ga='git add'
alias gd='git diff'
alias gc='git commit -m'
alias gco='git checkout $1'
alias gcb='git checkout -b $1'
alias gps='git push'
alias gpl='git pull'

gclone() {
  git clone git@github.com:$1/$2.git $3
}

# Tmux
alias tls='tmux ls'
alias tns='tmux new -s $1'
alias tas='tmux attach-session -t $1'
alias tks='tmux kill-session -t $1'
alias tka='tmux kill-session -a'

##################################################
# SHELL PROMPT

# Color aliases
COL_YELLOW="\033[0;33m"
COL_GREEN="\033[0;32m"
COL_LGREEN="\033[1;32m"
COL_PURPLE="\033[0;35m"
COL_BLUE="\033[0;34m"
COL_CYAN="\033[0;36m"
COL_WHITE="\033[0;37m"
COL_BLACK="\033[0;30m"

BG_WHITE="\033[0;47m"

RS="\033[0m" # Reset colors

# Git prompt setup
GIT_PS1_SHOWDIRTYSTATE="true"
#GIT_PS1_SHOWUNTRACKEDFILES="true"
#GIT_PS1_SHOWUPSTREAM="auto"
#GIT_PS1_STATESEPARATOR="  "

# Define custom prompt
export PS1="\[$COL_LGREEN\]\A\[$RS\] \[$COL_CYAN\]\u\[$RS\]@\[$RS\]\[$COL_PURPLE\]\h\[$RS\]:[\[$COL_YELLOW\]\w\[$RS\]]:\[$COL_LGREEN\]\$(__git_ps1)\[$RS\] "

[ -f ~/.fzf.bash ] && source ~/.fzf.bash
