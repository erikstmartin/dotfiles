source $HOME/.zshenv

# Path to your oh-my-zsh installation.
export ZSH="/home/erik/.oh-my-zsh"
ZSH_THEME="robbyrussell"

plugins=(
	archlinux
	bundler
	cargo
	direnv
	docker
	git
	golang
	helm
	kubectl
	microk8s
	nmap
	node
	pip
	postgres
	rails
	rake
	rbenv
	rsync
	ruby
	rust
	rustup
	systemd
	tmux
)
source $ZSH/oh-my-zsh.sh

bindkey -e
#export KEYTIMEOUT=1

if [[ -s $HOME/.ztheme ]]; then
  source $HOME/.ztheme
fi

alias vim=nvim
alias vi=nvim

# Git aliases
alias g='git'
unalias gb

#alias gl='g l'
#alias grl='g rl'
#alias gls='g ls'
#alias gs='g s'
#alias ga='g a'
#alias gc='g c'
#alias gau='g au'
#alias grm='g rm'
#alias gb='g b'
#alias gco='g co'
#alias gm='g m'
#alias gmff='g mff'
#alias gp='g p'
#alias gpu='g pu'
#alias gf='g f'
#alias gst='g st'
#alias gstp='g stp'
#alias gd='g d'

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

# Base16 Shell
BASE16_SHELL="$HOME/dotfiles/_vendor/base16-shell/"
[ -n "$PS1" ] && \
    [ -s "$BASE16_SHELL/profile_helper.sh" ] && \
        eval "$("$BASE16_SHELL/profile_helper.sh")"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
eval "$(op completion zsh)"; compdef _op op
eval "$(starship init zsh)"

#export QT_FONT_DPI=120
export QT_QPA_PLATFORMTHEME="gtk3"

source /home/erik/.config/broot/launcher/bash/br
