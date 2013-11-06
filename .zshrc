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
export GOROOT=/Users/erikstmartin/go/go
export GOPATH=/Users/erikstmartin/go
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

export PATH=$GOPATH/bin:/usr/local/share/npm/bin/:$GOROOT/bin:/opt/local/bin:/usr/local/mongodb/bin:/usr/local/mysql/bin:/usr/local/sbin:/usr/local/bin:$PATH
PATH=$PATH:$HOME/.rvm/bin # Add RVM to PATH for scripting
