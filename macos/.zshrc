
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
alias history='history 1' # zsh is weird with history
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
alias v='lvim'
alias h='history'
alias c='clear'
alias r='reset'
alias s='function _s() { pattern="$1"; lvim -p $(ag -l "$pattern") -c "argdo /$pattern"; }; _s'
alias x='exit'
alias la='ls -a'
alias ll='ls -FGalh --color=auto'
alias ts='tree -CshF -L 2'
alias duh='du -h --max-depth=1'
alias dfh='df -h'
alias cp='cp -v'
alias rm='rm -i'
alias cgrep='grep -Hn --color=always'
alias cat='ccat' #// Needs 'brew install ccat'

# REPLs
alias repl-cs='dotnet repl' # Install with 'dotnet tool install -g dotnet-repl'
alias repl-ts='node-prototype-repl' # Install with 'npm install -g nodejs/repl'
alias repl-js='node-prototype-repl' # Install with 'npm install -g nodejs/repl'


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
alias grl="git reflog --date=local"
alias gco='git checkout $1'
alias gcb='git checkout -b $1'
alias gpu='git push'
alias gpd='git pull'
alias grm='git restore --staged'
alias gsps='git stash && git pull && git stash apply'

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
alias tx='tmuxinator' # `brew install tmuxinator`
alias tls='tmux ls'
alias tns='tmux new -s $1'
alias tas='tmux attach-session -t $1'
alias tks='tmux kill-session -t $1'
alias tka='tmux kill-session -a'

eval "$(oh-my-posh init zsh)"
export NVM_DIR="$HOME/.nvm"
  [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
  [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion

  export PATH=$PATH:/Users/matthew.chapman/.pyenv/versions/3.12.3/bin:/Users/matthew.chapman/.local/bin:/Users/matthew.chapman/dev/bin:/Users/matthew.chapman/.nvm/versions/node/v20.11.0/bin:/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:/System/Cryptexes/App/usr/bin:/usr/bin:/bin:/usr/sbin:/sbin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/local/bin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/bin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/appleinternal/bin:/usr/local/share/dotnet:~/.dotnet/tools


export PATH=/Users/mattchapman/.local/bin:$PATH

autoload -U +X bashcompinit && bashcompinit
complete -o nospace -C /opt/homebrew/bin/terraform terraform

export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init - zsh)"

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/mattchapman/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/mattchapman/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/mattchapman/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/mattchapman/google-cloud-sdk/completion.zsh.inc'; fi

# Add Doom emacs 'Doom' command to path
export PATH="$HOME/.emacs.d/bin:$PATH"

export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$ANDROID_HOME/emulator:$ANDROID_HOME/tools:$ANDROID_HOME/tools/bin:$ANDROID_HOME/platform-tools:$PATH

