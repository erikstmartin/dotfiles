# Just Global Justfile
set -gx JUST_GLOBAL_JUSTFILE "$HOME/.config/just/justfile"

if test (uname) = Darwin
    set -gx CC /opt/homebrew/opt/llvm/bin/clang
    set -gx CXX /opt/homebrew/opt/llvm/bin/clang++
    set -gx CLANGXX /opt/homebrew/opt/llvm/bin/clang++
else if test (uname) = Linux
    set -gx CC clang
    set -gx CXX clang++
    set -gx CLANGXX clang++
end

# Machine-local environment overrides — not tracked in dotfiles.
# Format: KEY=value (one per line, no export keyword, no spaces around =)
if test -f ~/.env.local
    bass source ~/.env.local
end

# Derive GITHUB_TOKEN from gh keychain if not already set (e.g. via .env.local)
if not set -q GITHUB_TOKEN; and command -q gh
    set -l _gh_token (gh auth token 2>/dev/null)
    if test -n "$_gh_token"
        set -gx GITHUB_TOKEN $_gh_token
    end
end