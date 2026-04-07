# Fish shell configuration
# Environment, PATH, and tool initialization
# Aliases, wrappers, and tool-specific config live in conf.d/

# Disable greeting
set -g fish_greeting

# PATH — use -g (global/session scope) so paths are not written to fish_variables,
# keeping the universal variable store clean across machines.
fish_add_path -g $HOME/.local/bin
fish_add_path -g $HOME/.cargo/bin
fish_add_path -g $HOME/go/bin
fish_add_path -g /usr/local/bin

# llvm is installed under Homebrew on macOS
if test (uname) = Darwin
    fish_add_path -g /opt/homebrew/opt/llvm/bin
end

# mise — must be first so shims are available to everything else
if type -q mise
    mise activate fish | source
end

# fzf — must load after mise so fzf is in PATH
if type -q fzf
    fzf --fish | source

    # Remap Ctrl-T → Ctrl-Alt-F to match zsh binding
    bind ctrl-alt-f fzf-file-widget
    bind -M insert ctrl-alt-f fzf-file-widget

    # fzf-git integration
    if test -f $HOME/.local/share/fzf-git/fzf-git.fish
        source $HOME/.local/share/fzf-git/fzf-git.fish
    end
end

# starship prompt
if type -q starship
    starship init fish | source
end

# zoxide — smart cd
if type -q zoxide
    zoxide init --cmd z fish | source
end

# direnv
if type -q direnv
    direnv hook fish | source
end
