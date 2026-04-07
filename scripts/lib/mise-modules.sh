#!/usr/bin/env bash
# mise modules: mise/.config/mise/modules/<name>.toml are enabled per machine
# by linking them into conf.d/ (git-ignored), which mise loads automatically.

MISE_CONFIG_DIR="${MISE_CONFIG_DIR:-$HOME/.config/mise}"
# Module files come from the repo (this file may be sourced on its own, so
# find it from here): ~/.config/mise may not be linked yet on a fresh machine
_MISE_MODULES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../mise/.config/mise/modules" && pwd)"
_MISE_CONFD_DIR="$MISE_CONFIG_DIR/conf.d"

_mise_module_names() {
    local f
    for f in "$_MISE_MODULES_DIR"/*.toml; do
        [[ -e "$f" ]] && basename "$f" .toml
    done
}

_mise_module_enabled() {
    [[ -e "$_MISE_CONFD_DIR/$1.toml" ]]
}

_mise_module_exists() {
    [[ -n "$1" && -f "$_MISE_MODULES_DIR/$1.toml" ]]
}

# Fail (listing the bad names) unless every argument is a module name
_mise_modules_check() {
    local name bad=""
    for name in "$@"; do
        _mise_module_exists "$name" || bad="$bad $name"
    done
    [[ -z "$bad" ]] && return 0
    echo "Unknown module(s):$bad (see: scripts/dotfiles.sh mise list)" >&2
    return 1
}

# Dotfiles (stow) packages a module brings, from its "# dotfiles packages:" line
_mise_module_packages() {
    sed -n 's/^# dotfiles packages: *\([^(]*\).*/\1/p' "$_MISE_MODULES_DIR/$1.toml" 2>/dev/null
}

# Base packages plus those of the enabled modules
_all_stow_packages() {
    local name
    printf '%s\n' "${STOW_PACKAGES[@]}"
    for name in $(_mise_module_names); do
        if _mise_module_enabled "$name"; then _mise_module_packages "$name"; fi
    done
}

# (Un)link a module's packages, when this runs with common.sh loaded
_mise_module_stow() {
    local action="$1" name="$2" pkg
    type _stow_pkg >/dev/null 2>&1 || return 0
    for pkg in $(_mise_module_packages "$name"); do
        ( cd "$DOTFILES_DIR" && "$action" "$pkg" )
    done
}

_mise_modules_list() {
    local name desc mark
    for name in $(_mise_module_names); do
        desc="$(head -n 1 "$_MISE_MODULES_DIR/$name.toml" | sed 's/^# *//')"
        if _mise_module_enabled "$name"; then mark="*"; else mark=" "; fi
        printf ' %s %-12s %s\n' "$mark" "$name" "$desc"
    done
    echo "(* = enabled)"
}

_mise_modules_enable() {
    local name
    # shellcheck disable=SC2046 # module names have no spaces
    [[ "$1" == "all" ]] && set -- $(_mise_module_names)
    _mise_modules_check "$@" || return 1
    mkdir -p "$_MISE_CONFD_DIR"
    for name in "$@"; do
        # Relative when conf.d sits next to the repo's modules (the usual
        # linked ~/.config/mise), so the link survives moving the checkout
        if [[ "$(cd "$_MISE_CONFD_DIR/../modules" 2>/dev/null && pwd -P)" == "$(cd "$_MISE_MODULES_DIR" && pwd -P)" ]]; then
            ln -sfn "../modules/$name.toml" "$_MISE_CONFD_DIR/$name.toml"
        else
            ln -sfn "$_MISE_MODULES_DIR/$name.toml" "$_MISE_CONFD_DIR/$name.toml"
        fi
        _mise_module_stow _stow_pkg "$name"
        echo "Enabled $name"
    done
}

_mise_modules_disable() {
    local name
    _mise_modules_check "$@" || return 1
    for name in "$@"; do
        rm -f "$_MISE_CONFD_DIR/$name.toml"
        _mise_module_stow _unstow_pkg "$name"
        echo "Disabled $name"
    done
    echo "Installed versions stay until 'mise prune'."
}

# Ask which modules to enable, the first time only (no modules enabled yet)
_mise_modules_prompt() {
    local f answer
    for f in "$_MISE_CONFD_DIR"/*.toml; do
        [[ -e "$f" ]] && return 0
    done
    [[ -t 0 ]] || return 0
    echo ""
    echo "mise modules (the base tools are always installed):"
    _mise_modules_list
    while true; do
        read -r -p "Modules to enable (space-separated, 'all', or Enter for none): " answer || return 0
        [[ -z "$answer" ]] && return 0
        # shellcheck disable=SC2086 # split the answer into module names
        if [[ "$answer" == "all" ]] || _mise_modules_check $answer; then
            # shellcheck disable=SC2086
            _mise_modules_enable $answer
            return 0
        fi
    done
}

# scripts/dotfiles.sh mise <list|enable|disable> [module...]
_mise_modules_cmd() {
    local sub="${1:-list}"
    shift || true
    case "$sub" in
        list) _mise_modules_list ;;
        enable)
            [[ $# -gt 0 ]] || { echo "Usage: scripts/dotfiles.sh mise enable <module...|all>" >&2; return 1; }
            _mise_modules_enable "$@" && mise install
            ;;
        disable)
            [[ $# -gt 0 ]] || { echo "Usage: scripts/dotfiles.sh mise disable <module...>" >&2; return 1; }
            _mise_modules_disable "$@"
            ;;
        *) echo "Usage: scripts/dotfiles.sh mise <list|enable|disable> [module...]" >&2; return 1 ;;
    esac
}
