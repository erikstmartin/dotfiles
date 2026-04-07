# Aliases (interactive only)
status is-interactive; or return

# eza — modern ls replacement
alias eza "eza --color=auto --git --icons=auto --group-directories-first"
alias l eza
alias ll "eza --long --header --time-style=relative"
alias la "eza --long --all --header --time-style=relative"
alias tree "eza --tree --icons=always"
alias lt "eza --tree --level=2 --icons=always"

# Editors
alias vim nvim
alias vi nvim
alias v nvim
alias n nvim

# Git shorthand
alias g git

# Docker
alias d docker

# Kubernetes
alias k kubectl

# Just (j itself is a function: conf.d/functions.fish)
if command -q just
    alias jg "just --global-justfile"
end

# workmux
if command -q workmux
    alias wm workmux
end

# Clear
alias cl clear

# Ask before removing or overwriting files (same in zsh and PowerShell)
alias rm "rm -i"
alias cp "cp -i"
alias mv "mv -i"
