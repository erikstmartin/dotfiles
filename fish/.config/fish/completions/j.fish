# Fish completion for j (smart just wrapper)
# Provides completion for both recipes and command-line flags

# Disable carapace completion for j to avoid conflicts
complete -c j --erase

function __j_complete_recipes
    # Same check as the j function: a justfile here or in a parent dir,
    # otherwise the global justfile
    set -l recipes (just --summary 2>/dev/null)
    or set recipes (just --global-justfile --summary 2>/dev/null)
    string split ' ' -- $recipes
end

function __j_complete_flags
    printf "%b\n" \
        "--list\tList available recipes" \
        "--dry-run\tShow what would be done without executing" \
        "--verbose\tUse verbose output" \
        "--quiet\tSuppress all output except recipe output" \
        "--set\tOverride a setting" \
        "--shell\tInvoke a shell instead of recipe" \
        "--working-directory\tUse a different working directory" \
        "--justfile\tUse a different justfile" \
        "--global-justfile\tUse the global justfile" \
        "--color\tPrint colorful output" \
        "--no-dotenv\tDo not load .env file" \
        "--dotenv-filename\tLoad environment from a .env file" \
        "--dotenv-path\tSearch for .env file starting from a directory"
end

# Complete flags when current token starts with -
complete -c j -f -a '(__j_complete_flags)' -n '__fish_is_first_token; and __fish_is_token_n 1; and string match -q -- "-*" (commandline -ct)'

# Complete recipes when not starting with -
complete -c j -f -a '(__j_complete_recipes)' -n '__fish_is_first_token; and not string match -q -- "-*" (commandline -ct)'