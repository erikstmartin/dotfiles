# Decides whether a command is saved to history (fish 4+ built-in hook).
# Defining this replaces fish's default rule, so the leading-space rule is
# re-implemented here. A skipped command can still be recalled once.
# Same rules as zsh's zshaddhistory (zsh/.zshrc).
function fish_should_add_to_history
    set -l cmd $argv[1]

    # Leading space: don't save (fish's default behaviour)
    string match -qr '^\s' -- $cmd; and return 1

    # Blank lines and single-char commands
    test (string length -- $cmd) -le 1; and return 1

    # cd / zoxide navigation (context-dependent, not useful to replay)
    string match -qr '^(cd|z)( .*)?$' -- $cmd; and return 1

    # Short noisy commands (including the eza aliases)
    string match -qr '^(ls|l|ll|la|lt|tree|eza|pwd|clear|cl|exit|history)( .*)?$' -- $cmd; and return 1

    # Force push/pull
    string match -qr '^git (push|pull)( .*)?(--force|-f)( .*)?$' -- $cmd; and return 1

    # Credentials passed to curl/wget
    string match -qir '^(curl|wget)\s.*(password|passwd|token|secret|api[_-]?key)' -- $cmd; and return 1

    # Secrets assigned to environment variables (export FOO_TOKEN=..., set -x API_KEY ...,
    # FOO_TOKEN=... cmd). The keyword must end the name or a _-separated part
    # of it (GH_TOKEN, DB_PASSWORD_FILE), so TOKENIZERS_PARALLELISM is kept.
    set -l secret '\w*(password|passwd|token|secret|api[_-]?key)(_\w*)?'
    string match -qir '^(export\s+|set\s+(-\w+\s+)*)'$secret'[\s=]' -- $cmd; and return 1
    string match -qir '(^|\s)'$secret'=' -- $cmd; and return 1

    return 0
end
