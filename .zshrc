#
# Matt's     _
#    _______| |__  _ __ ___
#   |_  / __| '_ \| '__/ __|
#  _ / /\__ \ | | | | | (__
# (_)___|___/_| |_|_|  \___|
#
#############################################
# BASE SETUP
#############################################

# Cause Nano is for bitch-ass niggas
export EDITOR=vim


#############################################
# ANTIGEN (Plugin and Theme Manager)
#############################################

# Note - Install Antigen using Homebrew

# Let's get this shit started fool
source /usr/local/share/antigen/antigen.zsh

# Load the oh-my-zsh plugin library
#antigen use oh-my-zsh

# Load the standard stuff from oh-my-zsh
antigen bundle robbyrussell/oh-my-zsh plugins/git
antigen bundle robbyrussell/oh-my-zsh plugins/tmux
antigen bundle robbyrussell/oh-my-zsh plugins/tmuxinator

# All the pretty colors (This must be the last bundle)
antigen bundle zsh-users/zsh-syntax-highlighting

# Theme it upppp
#antigen theme agnoster

#TEMP
ANTIGEN_LOG=~/antigen.log

# ENGAGE!
antigen apply


#############################################
# FUNCTIONS
#############################################

# Make ASCII text and pipe into clipboard
function ascii() {
  figlet -f big $* | pbcopy
}

# Shutdown the computer
function nightnight() {
  sudo shutdown -h now
}

# Create a quick note with specified filename
function note() {
  touch ~/notes/$1.txt
  vim ~/notes/$1.txt
}

# Save clipboard contents into editable file 
# of specified type
function clip() {
  if [ -f ~/notes/clip.$1]
  then
    rm ~/notes/clip.$1
  fi
  pbpaste > ~notes/clip.$1
  vim ~/notes/clip.$1
}

# Not for bewbs
function hide() {
  dir=$1
  chflags hidden $dir
  mv $dir $dir.noindex
}

function show() {
  dir=$1.noindex
  chflags nohidden $dir
  mv $dir $dir
}


#############################################
# ALIASES
#############################################

# There's no place like home
alias home='cd ~/'

# Typing 5 letters is too slow bro
alias cl='clear'

# What's my IP address
alias ip='ifconfig en0 | grep -w inet'

# Cause fuck having no information
alias cp='rsync -av'

# You're a fuckwit - here's a safety margin
alias rm='rm -i'

# List me like one of your French girls
alias ls='ls -aFC'

# Longer, but more memorable, yo
alias symlink='ln -s'

# Cause finding shit is hard
alias grep='grep --color=auto'

# Tmuxinator is a long-ass word
alias mux='tmuxinator'

# Edit this file quick, fool
alias zshrc='vim ~/.zshrc'

# Reload this file quick, fool
alias sourcez='source ~/.zshrc'


#############################################
# WHEREWOLF SETTINGS
#############################################

# Set it up nigga
export WW_CODE_DIR=~/code
source $WW_CODE_DIR/helperscripts/bash/core
export PATH=$PATH:~/code/helperscripts

# Make it quicker to edit app files
function editapp() {
  cd $WW_CODE_DIR/wherewolf-whitelabel/app
  vim -p controllers/MasterController.js resources/base/client-specific.css
}