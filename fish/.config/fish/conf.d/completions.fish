# Completions (interactive only)
status is-interactive; or return

# Docker CLI completions
if test -d "$HOME/.docker/completions"
    set -a fish_complete_path "$HOME/.docker/completions"
end

# Carapace multi-shell completions (handles kubectl, terraform, and 600+ others)
if command -q carapace
    set -gx CARAPACE_BRIDGES 'zsh,fish,bash'
    set -gx CARAPACE_MATCH 1
    __cached_source carapace _carapace fish
end
