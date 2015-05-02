bindkey -v
export KEYTIMEOUT=1

# Source Prezto.
if [[ -s $HOME/.zprezto/init.zsh ]]; then
  source $HOME/.zprezto/init.zsh
fi

if [[ -s $HOME/.ztheme ]]; then
  source $HOME/.ztheme
fi

brew-load() {
  launchctl load ~/Library/LaunchAgents/homebrew.mxcl.$1.plist
}

brew-unload() {
  launchctl unload ~/Library/LaunchAgents/homebrew.mxcl.$1.plist
}

conflicts='grep -rI "<<<" *'

# Git aliases
alias g='git'

alias gl='g l'
alias grl='g rl'
alias gls='g ls'
alias gs='g s'
alias ga='g a'
alias gc='g c'
alias gau='g au'
alias grm='g rm'
alias gb='g b'
alias gco='g co'
alias gm='g m'
alias gmff='g mff'
alias gp='g p'
alias gpu='g pu'
alias gf='g f'
alias gst='g st'
alias gstp='g stp'
alias gd='g d'

# Kill all running containers.
alias dockerkillall='docker kill $(docker ps -q)'

# Delete all stopped containers.
alias dockercleanc='printf "\n>>> Deleting stopped containers\n\n" && docker rm $(docker ps -a -q)'

# Delete all untagged images.
alias dockercleani='printf "\n>>> Deleting untagged images\n\n" && docker rmi $(docker images -q -f dangling=true)'

# Delete all stopped containers and untagged images.
alias dockerclean='dockercleanc || true && dockercleani'

# Direnv only if it's installed
if command -v direnv >/dev/null 2>&1; then
  eval "$(direnv hook zsh)"
fi

# Tab Completion of .ssh/known_hosts
local knownhosts
knownhosts=( ${${${${(f)"$(<$HOME/.ssh/known_hosts)"}:#[0-9]*}%%\ *}%%,*} ) 
zstyle ':completion:*:(ssh|scp|sftp):*' hosts $knownhosts

###-begin-npm-completion-###
#
# npm command completion script
#
# Installation: npm completion >> ~/.bashrc  (or ~/.zshrc)
# Or, maybe: npm completion > /usr/local/etc/bash_completion.d/npm
#

COMP_WORDBREAKS=${COMP_WORDBREAKS/=/}
COMP_WORDBREAKS=${COMP_WORDBREAKS/@/}
export COMP_WORDBREAKS

if type complete &>/dev/null; then
  _npm_completion () {
    local si="$IFS"
    IFS=$'\n' COMPREPLY=($(COMP_CWORD="$COMP_CWORD" \
                           COMP_LINE="$COMP_LINE" \
                           COMP_POINT="$COMP_POINT" \
                           npm completion -- "${COMP_WORDS[@]}" \
                           2>/dev/null)) || return $?
    IFS="$si"
  }
  complete -F _npm_completion npm
elif type compdef &>/dev/null; then
  _npm_completion() {
    si=$IFS
    compadd -- $(COMP_CWORD=$((CURRENT-1)) \
                 COMP_LINE=$BUFFER \
                 COMP_POINT=0 \
                 npm completion -- "${words[@]}" \
                 2>/dev/null)
    IFS=$si
  }
  compdef _npm_completion npm
elif type compctl &>/dev/null; then
  _npm_completion () {
    local cword line point words si
    read -Ac words
    read -cn cword
    let cword-=1
    read -l line
    read -ln point
    si="$IFS"
    IFS=$'\n' reply=($(COMP_CWORD="$cword" \
                       COMP_LINE="$line" \
                       COMP_POINT="$point" \
                       npm completion -- "${words[@]}" \
                       2>/dev/null)) || return $?
    IFS="$si"
  }
  compctl -K _npm_completion npm
fi
###-end-npm-completion-###

BASE16_SHELL="$HOME/dotfiles/_vendor/base16-shell/base16-default.dark.sh"
[[ -s $BASE16_SHELL ]] && source $BASE16_SHELL
