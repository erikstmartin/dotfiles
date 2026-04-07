# Fish shell configuration
# Environment, PATH, and tool initialization
# Aliases, wrappers, and tool-specific config live in conf.d/

# Disable greeting
set -g fish_greeting

# PATH — -g so paths aren't written to fish_variables (shared across machines).
# One call keeps the given order (separate calls would each prepend, reversing
# it); same order as zsh's .zshenv and mise's _.path.
fish_add_path -g $HOME/.local/bin $HOME/.cargo/bin $HOME/go/bin

# Everything below is interactive-only
status is-interactive; or return

# fzf — must load after mise so fzf is in PATH
if type -q fzf
    __cached_source fzf --fish

    # Add Ctrl-Alt-F alongside fzf's default Ctrl-T binding.
    bind ctrl-alt-f fzf-file-widget
    bind -M insert ctrl-alt-f fzf-file-widget

    # fzf-git integration
    if test -f $HOME/.local/share/fzf-git/fzf-git.fish
        source $HOME/.local/share/fzf-git/fzf-git.fish
    end
end

# starship prompt
if type -q starship
    __cached_source starship init fish --print-full-init
end

# zoxide — smart cd
if type -q zoxide
    __cached_source zoxide init --cmd z fish
end

# direnv (from mise; skips the hook if a system package already installed one)
if command -q direnv; and not functions -q __direnv_export_eval
    __cached_source direnv hook fish
end
