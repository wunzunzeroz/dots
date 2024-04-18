
export EDITOR=nvim

##################################################
# PATH

# Dotnet
#export PATH=$PATH:$HOME/dotnet:$HOME/.dotnet/tools
#export DOTNET_ROOT=$HOME/dotnet

##################################################
# HISTORY

export HISTSIZE=1000000
export HISTFILESIZE=100000000
export HISTTIMEFORMAT="[%h %d %H:%M:%S] "
#export HISTCONTROL=ignoreboth:erasedups
#export HISTIGNORE="ls:ll:cd*:gs:gd:gdf:gc:gco:gcb:git*:c:r:history"

##################################################
# ALIASES AND FUNCTIONS

# Utility
alias bashrc='lvim ~/.bashrc'                
alias zshrc='lvim ~/.vimrc'
alias sz='source ~/.zshrc'
alias vimrc='lvim ~/.vimrc'

alias n='nvim'
alias h='history'
alias c='clear'
alias r='reset'
alias x='exit'
alias la='ls -a'
alias ll='ls -FGalh --color=auto'
alias ts='tree -CshF -L 2'
alias duh='du -h --max-depth=1'
alias dfh='df -h'
alias cp='cp -v'
alias rm='rm -i'
alias cgrep='grep -Hn --color=always'
alias cat='ccat' // Needs 'brew install ccat'

alias csi='dotnet repl' // Install with 'dotnet tool install -g dotnet-repl'

# Work
alias lead='cd ~/dev/code/PartnerExperience/LeadService'
alias bill='cd ~/dev/code/Ecosystem.Billing.API'
alias anal='cd ~/dev/code/analytics-pipeline'

alias rangr='cd ~/dev/personal/RANGR'

listport() {
        lsof -i :$1
}

killport() {
        kill $(lsof -t -i :$1)
}

alias pip='pip3'

# Docker
alias dps='docker ps --all --format "table {{.ID}}\t{{.Names}}\t| {{.RunningFor}}\t{{.Status}}\t| {{.Ports}}"'

alias dsa='docker stop $(docker ps -aq)' # Stop all
alias dra='docker rm $(docker ps -aq)' # Remove all
alias drf='docker rm $(docker ps --all --quiet --filter "name=$@")' # Remove filtered

alias dsp='docker system prune --all'
alias dspv='docker system prune --all --volumes'

alias dst='docker stats --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}"'
alias dlt='docker logs -f "$@"'

# Git
alias gu="gitui" # Rust based terminal git client; install with `brew install gitui`
alias gs='git status'
alias ga='git add'
alias gap='git add -p'
# alias gd='git diff --color-moved'
alias gd='git diff'
alias gdc='git diff --compact-summary'
alias gc='git commit -m'
alias gl="git log --pretty=format:'%C(yellow)%h %Cred%ad %Cblue%an%Cgreen%d %Creset%s' --date=short"
alias gco='git checkout $1'
alias gcb='git checkout -b $1'
alias gpu='git push'
alias gpd='git pull'
alias grm='git restore --staged'

function pretty_diff() {
   # Check if diff-so-fancy installed
   if ! diff-so-fancy -v &> /dev/null; then
     git diff --color-words
     else
       git diff --color | diff-so-fancy
   fi
}

gclone() {
  git clone git@github.com:$1/$2.git $3
}

# Vim mode
bindkey -v

# Tmux
alias tls='tmux ls'
alias tns='tmux new -s $1'
alias tas='tmux attach-session -t $1'
alias tks='tmux kill-session -t $1'
alias tka='tmux kill-session -a'

eval "$(oh-my-posh init zsh)"
export NVM_DIR="$HOME/.nvm"
  [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
  [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion

  export PATH=/Users/matthew.chapman/.local/bin:/Users/matthew.chapman/dev/bin:/Users/matthew.chapman/.nvm/versions/node/v20.11.0/bin:/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:/System/Cryptexes/App/usr/bin:/usr/bin:/bin:/usr/sbin:/sbin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/local/bin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/bin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/appleinternal/bin:/usr/local/share/dotnet:~/.dotnet/tools


autoload -U +X bashcompinit && bashcompinit
complete -o nospace -C /opt/homebrew/bin/terraform terraform
