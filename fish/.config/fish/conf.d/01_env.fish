# Same base environment as zsh's .zshenv

set -l os (uname)

# XDG config dir — tools like k9s and lazydocker otherwise use
# ~/Library/Application Support on macOS instead of ~/.config
set -gx XDG_CONFIG_HOME "$HOME/.config"

if test $os = Darwin
    set -gx BROWSER open
else if set -q WSL_DISTRO_NAME
    set -gx BROWSER wsl-browser
end

# Automatic Windows PATH import is disabled in /etc/wsl.conf because misses
# across mounted Windows directories make shell startup substantially slower.
if set -q WSL_DISTRO_NAME; or begin; test -r /proc/version; and string match -qi '*microsoft*' </proc/version; end
    fish_add_path -g -a -P /mnt/c/bin
end

# Editors
set -gx EDITOR nvim
set -gx VISUAL nvim
set -gx PAGER less

# Mouse-wheel scrolling has been disabled by -X (disable screen clearing).
# Remove -X and -F (exit if the content fits on one screen) to enable it.
set -gx LESS '-F -g -i -M -R -S -w -X -z4'
# lesspipe.sh (Homebrew) or lesspipe (Debian/Ubuntu). Checked by path: a PATH
# lookup that misses crawls every Windows dir on WSL (~100ms)
if test $os = Darwin; and command -q lesspipe.sh
    set -gx LESSOPEN '| /usr/bin/env lesspipe.sh %s 2>&-'
else if test -x /usr/bin/lesspipe
    set -gx LESSOPEN '| /usr/bin/lesspipe %s'
end

set -q LANG; or set -gx LANG en_US.UTF-8

set -gx GOPATH "$HOME/go"

# Just Global Justfile
set -gx JUST_GLOBAL_JUSTFILE "$HOME/.config/just/justfile"

# eza theme (catppuccin); on macOS eza would otherwise look in
# ~/Library/Application Support/eza instead of ~/.config/eza
set -gx EZA_CONFIG_DIR "$HOME/.config/eza"

if test $os = Darwin
    # Homebrew's llvm (keg-only), when installed; otherwise Apple's clang applies
    if set -q HOMEBREW_PREFIX; and test -x $HOMEBREW_PREFIX/opt/llvm/bin/clang
        set -gx CC $HOMEBREW_PREFIX/opt/llvm/bin/clang
        set -gx CXX $HOMEBREW_PREFIX/opt/llvm/bin/clang++
        set -gx CLANGXX $HOMEBREW_PREFIX/opt/llvm/bin/clang++
    end
else if test $os = Linux
    set -gx CC clang
    set -gx CXX clang++
    set -gx CLANGXX clang++
end

# Machine-local environment overrides — not tracked in dotfiles.
# Format: KEY=value or export KEY=value (one per line, no spaces around =).
# Parsed natively (no bass/python spawn) with the expansions zsh's
# `set -a; source` applies to such lines: $VAR and ${VAR} (exported vars, incl.
# ones set earlier in the file; unset → empty) unless single-quoted, and a
# leading ~ when unquoted. No command substitution or other shell code runs.
function __env_local_load
    set -l __m
    for __line in (string match -rv '^\s*(#|$)' < ~/.env.local)
        set -l __kv (string match -r '^(?:export\s+)?([A-Za-z_][A-Za-z0-9_]*)=(.*)$' -- $__line)
        or continue
        set -l __rest $__kv[3]
        # strip one pair of surrounding quotes
        set -l __quote (string match -r '^([\'"]).*\1$' -- $__rest)[2]
        if set -q __quote[1]
            set __rest (string sub -s 2 -e -1 -- $__rest)
        else if string match -qr '^~(/|$)' -- $__rest
            set __rest (string join '' -- $HOME (string sub -s 2 -- $__rest))
        end
        if test "$__quote" = "'"
            set -gx $__kv[2] "$__rest"
            continue
        end
        set -l __out ''
        while set __m (string match -r -- '^(.*?)\$(?|\{([A-Za-z_][A-Za-z0-9_]*)\}|([A-Za-z_][A-Za-z0-9_]*))(.*)$' "$__rest")
            set -l __name $__m[3]
            set -l __val ''
            if set -qx $__name
                # lists (PATH-style vars) are exported colon-joined
                set -l __sep ' '
                string match -q '*PATH' -- $__name; and set __sep :
                set __val (string join -- $__sep $$__name)
            end
            set __out "$__out$__m[2]$__val"
            set __rest $__m[4]
        end
        set -gx $__kv[2] "$__out$__rest"
    end
end
if test -f ~/.env.local
    __env_local_load
end
functions -e __env_local_load
