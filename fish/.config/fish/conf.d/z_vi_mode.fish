# Vi key bindings for fish  
# Accept fzf's intentional design: Shift-Tab for fzf completion, Tab for native Fish completion

# Set vi mode declaratively
set -g fish_key_bindings fish_vi_key_bindings

# fish_user_key_bindings runs after vi mode initialization and on every binding reset
function fish_user_key_bindings
    # fzf functions exist - bind them to override presets
    if functions -q fzf-history-widget
        bind -M insert ctrl-r fzf-history-widget
        bind -M default ctrl-r fzf-history-widget
    end
    if functions -q fzf-file-widget
        bind -M insert ctrl-t fzf-file-widget
        bind -M default ctrl-t fzf-file-widget
    end
    if functions -q fzf-cd-widget
        bind -M insert alt-c fzf-cd-widget
        bind -M default alt-c fzf-cd-widget
    end
end

# Note: fzf intentionally uses Shift-Tab for completion in Fish
# Tab retains Fish's excellent native completion (enhanced by Carapace)
