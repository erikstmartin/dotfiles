#!/usr/bin/env bash
# Check that the stow-managed dotfiles are still linked. Every git-tracked file
# in STOW_PACKAGES should resolve to its file in the repo. Tools that save by
# writing a new file and renaming it over the old one replace the link with a
# plain copy, which silently stops tracking it.

_resolve_path() {
    if command -v realpath >/dev/null 2>&1; then
        realpath "$1" 2>/dev/null
    else
        python3 -c 'import os, sys; print(os.path.realpath(sys.argv[1]))' "$1"
    fi
}

# Load stow's ignore list for a package, like stow: its own .stow-local-ignore,
# else ~/.stow-global-ignore (falling back to the repo's copy). Patterns
# containing "/" match the path from the package root, others any path segment.
_stow_ignore_load() {
    local pkg_dir="$1" file pattern
    _IGNORE_PATH='/\.stow-local-ignore'
    _IGNORE_SEGMENT=""
    file="$pkg_dir/.stow-local-ignore"
    [ -f "$file" ] || file="$HOME/.stow-global-ignore"
    [ -f "$file" ] || file="$DOTFILES_DIR/stow-global-ignore"
    [ -f "$file" ] || return 0
    while IFS= read -r pattern || [ -n "$pattern" ]; do
        pattern="$(printf '%s' "$pattern" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
        case "$pattern" in "" | \#*) continue ;; esac
        pattern="$(printf '%s' "$pattern" | sed -e 's/[[:space:]][[:space:]]*#.*//' -e 's/\\#/#/g')"
        if [[ "$pattern" == */* ]]; then
            _IGNORE_PATH="$_IGNORE_PATH|$pattern"
        else
            _IGNORE_SEGMENT="${_IGNORE_SEGMENT:+$_IGNORE_SEGMENT|}$pattern"
        fi
    done < "$file"
}

# Does stow skip this file? `path` is relative to the package root; call
# _stow_ignore_load for the package first.
_stow_ignored() {
    local path="$1" path_re segment_re rest segment
    path_re="(^|/)($_IGNORE_PATH)(/|\$)"
    [[ "/$path" =~ $path_re ]] && return 0
    [ -n "$_IGNORE_SEGMENT" ] || return 1
    segment_re="^($_IGNORE_SEGMENT)\$"
    rest="$path"
    while [ -n "$rest" ]; do
        segment="${rest%%/*}"
        [[ "$segment" =~ $segment_re ]] && return 0
        [ "$segment" = "$rest" ] && break
        rest="${rest#*/}"
    done
    return 1
}

_check_links() {
    local repo pkg rel path target expected copies="" missing="" elsewhere="" dangling="" dirs="" dir link
    repo="$(cd "$DOTFILES_DIR" && pwd -P)"

    for pkg in $(_all_stow_packages); do
        _stow_ignore_load "$repo/$pkg"
        while IFS= read -r rel; do
            [ -n "$rel" ] || continue
            path="${rel#"$pkg"/}"
            _stow_ignored "$path" && continue
            target="$HOME/$path"
            expected="$repo/$rel"
            dirs="$dirs
$(dirname "$target")"
            if [ ! -e "$target" ] && [ ! -L "$target" ]; then
                missing="$missing
  $pkg: ~/$path"
            elif [ "$(_resolve_path "$target")" != "$expected" ]; then
                if [ -L "$target" ]; then
                    elsewhere="$elsewhere
  $pkg: ~/$path -> $(readlink "$target")"
                else
                    copies="$copies
  $pkg: ~/$path"
                fi
            fi
        done < <(git -C "$repo" ls-files -- "$pkg")
    done

    # Links into the repo whose file was removed from it
    while IFS= read -r dir; do
        [ -d "$dir" ] || continue
        for link in "$dir"/* "$dir"/.[!.]*; do
            if [ -L "$link" ] && [ ! -e "$link" ] && [[ "$(readlink "$link")" == *"$(basename "$repo")/"* ]]; then
                dangling="$dangling
  ~${link#"$HOME"} -> $(readlink "$link")"
            fi
        done
    done < <(printf '%s\n' "$dirs" | sort -u)

    if [ -z "$copies$missing$elsewhere$dangling" ]; then
        echo "✓ All dotfiles are linked"
        return 0
    fi
    [ -n "$copies" ] && printf '\nReplaced by a copy (merge any changes into the repo, delete it, then `dotfiles.sh link <package>`):%s\n' "$copies"
    [ -n "$elsewhere" ] && printf '\nLinked somewhere else:%s\n' "$elsewhere"
    [ -n "$missing" ] && printf '\nNot linked (`dotfiles.sh link <package>`):%s\n' "$missing"
    [ -n "$dangling" ] && printf '\nLinks to files no longer in the repo (safe to delete):%s\n' "$dangling"
    return 1
}
