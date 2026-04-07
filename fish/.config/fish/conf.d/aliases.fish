# Aliases

# eza — modern ls replacement
alias eza "eza --color=always --git --icons=always --group-directories-first"
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

# Kubernetes
alias k kubectl

# Yazi file manager
if command -q yazi
    alias y yazi
end

# Just
if command -q just
    alias j just
    alias jg "just --global-justfile"
end

# Clear
alias cl clear
