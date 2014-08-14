# Source Prezto.
if [[ -s $HOME/.zprezto/init.zsh ]]; then
  source $HOME/.zprezto/init.zsh
fi

# aliases
#alias vim='vim -g'

brew-load() {
  launchctl load ~/Library/LaunchAgents/homebrew.mxcl.$1.plist
}

brew-unload() {
  launchctl unload ~/Library/LaunchAgents/homebrew.mxcl.$1.plist
}

# Git blows up because of CA for SSL, ignore it
export GIT_SSL_NO_VERIFY=true

# Customize to your needs...
export GOPATH=~
export JIRA_URL=https://jira.clarityservices.com
export PYTHONPATH=/usr/local/lib/python2.7/site-packages

conflicts='grep -rI "<<<" *'

# Utils
#alias retag_ruby="/usr/local/bin/ctags --extra=+f --exclude=.git --exclude=test --exclude='*.html' --exclude='*.haml' --exclude=Makefile --exclude='*.js' --exclude='*.css' --exclude='*.sass' --exclude='*.yml' --exclude=Rakefile --exclude=tmp --exclude=spec --exclude=Gemfile --exclude=Gemfile.lock --exclude=README --exclude=log -R * `rvm gemdir`/gems/*"
#alias retag_go='pushd .;cd $GOPATH;/usr/local/bin/ctags --exclude=.git --exclude="*_test.go" --totals=yes -R $GOPATH/src/**/*.go $GOROOT/src/pkg/**/*.go;popd'
alias reload='source ~/.zshrc'

# Git aliases
alias g='hub'

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
alias gx='gitx'

export PATH=./bin:$GOPATH/bin:/Users/erik/node_modules/.bin:/opt/local/bin:/usr/local/mysql/bin:/usr/local/sbin:/usr/local/bin:$PATH

# Tab Completion of .ssh/known_hosts
local knownhosts
knownhosts=( ${${${${(f)"$(<$HOME/.ssh/known_hosts)"}:#[0-9]*}%%\ *}%%,*} ) 
zstyle ':completion:*:(ssh|scp|sftp):*' hosts $knownhosts

eval "$(direnv hook $0)"
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
#
#export DOCKER_HOST=tcp://192.168.1.166:2375
