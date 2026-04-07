# Completions

# Docker CLI completions
if test -d "$HOME/.docker/completions"
    set -a fish_complete_path "$HOME/.docker/completions"
end

# Carapace multi-shell completions (handles kubectl, terraform, and 600+ others)
if command -q carapace
    set -x CARAPACE_BRIDGES 'zsh,fish,bash,inshellisense'
    set -x CARAPACE_MATCH 1
    carapace _carapace | source
end

# GitHub CLI completions
if command -q gh
    gh completion -s fish | source
end
