# Fish completion for j (smart just wrapper)
# Provides completion for both recipes and command-line flags

# Disable carapace completion for j to avoid conflicts
complete -c j --erase

function __j_complete_recipes
    # Check if local justfile exists (same logic as j function)
    if just --justfile justfile --summary >/dev/null 2>&1
        # Local justfile exists - suppress any error output
        just --list 2>/dev/null | tail -n +2 | grep -o '^[[:space:]]*[^[:space:]]*' | sed 's/^[[:space:]]*//' | grep -v '^$' | grep -v '^\[.*\]$'
    else
        # Use global justfile - suppress any error output
        just --global-justfile --list 2>/dev/null | tail -n +2 | grep -o '^[[:space:]]*[^[:space:]]*' | sed 's/^[[:space:]]*//' | grep -v '^$' | grep -v '^\[.*\]$'
    end
end

function __j_complete_flags
    printf "%s\n" \
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