#!/bin/bash

_LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "${_LIB_DIR}/../.." && pwd)"
# The user-facing script, for usage/error messages: the OS scripts
# (lib/<os>.sh) are run by scripts/dotfiles.sh, which exports what the user
# typed; their own $0 would point into lib/.
DOTFILES_SCRIPT="${DOTFILES_SCRIPT:-${DOTFILES_DIR}/scripts/dotfiles.sh}"

# shellcheck source=mise-modules.sh
source "${_LIB_DIR}/mise-modules.sh"

# Base packages, linked on every machine. Packages for a mise module's tools
# (k9s, opencode, azure, ...) are listed in the module file and linked only
# while that module is enabled (see mise-modules.sh).
STOW_PACKAGES=(
    agents
    bat
    bin
    carapace
    delta
    eza
    fd
    fish
    gh
    gh-dash
    ghostty
    git
    hammerspoon
    just
    lazygit
    misc
    mise
    nvim
    posting
    starship
    yazi
    tmux
    wezterm
    workmux
    yamllint
    zsh
)

# Packages whose target dirs also hold the tool's own runtime data (caches,
# sessions, plugins): link files individually so that data stays out of the repo
NO_FOLDING_PACKAGES=(agents azure claude copilot omp opencode)

_is_no_folding() {
    local p
    for p in "${NO_FOLDING_PACKAGES[@]}"; do
        [ "$p" = "$1" ] && return 0
    done
    return 1
}

# A link into the repo from an older layout makes stow fail: it treats the
# link as its own and tries to read where it points. Stow checks the links in
# every target dir it visits, so clear those dirs of links into the repo whose
# target is missing or no longer tracked (git pull leaves untracked files, and
# so their old directories, behind).
_remove_stale_links() {
    local pkg="$1" rel dir link target abs repo dirs="$HOME"
    repo="$(cd "$DOTFILES_DIR" && pwd -P)"
    while IFS= read -r rel; do
        rel="${rel#"$pkg"/}"
        while [[ $rel == */* ]]; do
            rel="${rel%/*}"
            dirs="$dirs
$HOME/$rel"
        done
    done < <(git -C "$repo" ls-files -- "$pkg")
    while IFS= read -r dir; do
        # Skip missing dirs and folded links (those point into the repo)
        { [ -d "$dir" ] && [ ! -L "$dir" ]; } || continue
        for link in "$dir"/* "$dir"/.[!.]*; do
            [ -L "$link" ] || continue
            target="$(readlink "$link")"
            [[ /$target == */"$(basename "$repo")"/* ]] || continue
            if [ -e "$link" ]; then
                abs="$(cd "$(dirname "$link")" && cd "$(dirname "$target")" && pwd -P)/$(basename "$target")"
                [[ $abs == "$repo"/* ]] || continue
                [ -n "$(git -C "$repo" ls-files -- "${abs#"$repo"/}" | head -n 1)" ] && continue
            fi
            echo "Removing stale link ~${link#"$HOME"} -> $target"
            command rm -f "$link"
        done
    done < <(printf '%s\n' "$dirs" | sort -u)
}

_stow_pkg() {
    _remove_stale_links "$1"
    if _is_no_folding "$1"; then
        stow -R -vv --no-folding "$1"
    else
        stow -vv "$1"
    fi
}

_unstow_pkg() {
    _remove_stale_links "$1"
    if _is_no_folding "$1"; then
        stow -D -vv --no-folding "$1"
    else
        stow -D -vv "$1"
    fi
}

# Nested stow packages (require -d flag with subdirectory)
NESTED_STOW_PACKAGES=()

# Install (or refresh, when the repo copy changed) stow's global ignore list
_bootstrap_stow() {
    if ! cmp -s "${DOTFILES_DIR}/stow-global-ignore" "${HOME}/.stow-global-ignore"; then
        command cp -f "${DOTFILES_DIR}/stow-global-ignore" "${HOME}/.stow-global-ignore"
    fi
}

_link_dotfiles() {
    echo "Linking dotfiles with stow..."
    cd "${DOTFILES_DIR}" || exit 1
    if [ $# -eq 0 ]; then
        for pkg in $(_all_stow_packages); do
            _stow_pkg "$pkg"
        done
        for pkg in "${NESTED_STOW_PACKAGES[@]}"; do
            local parent_dir pkg_name
            parent_dir=$(dirname "$pkg")
            pkg_name=$(basename "$pkg")
            stow -vv -d "${DOTFILES_DIR}/${parent_dir}" -t "${HOME}" "${pkg_name}"
        done
    else
        for pkg in "$@"; do
            _stow_pkg "$pkg"
        done
    fi
}

_unlink_dotfiles() {
    echo "Unlinking dotfiles with stow..."
    cd "${DOTFILES_DIR}" || exit 1
    if [ $# -eq 0 ]; then
        for pkg in $(_all_stow_packages); do
            _unstow_pkg "$pkg"
        done
        for pkg in "${NESTED_STOW_PACKAGES[@]}"; do
            local parent_dir pkg_name
            parent_dir=$(dirname "$pkg")
            pkg_name=$(basename "$pkg")
            stow -D -vv -d "${DOTFILES_DIR}/${parent_dir}" -t "${HOME}" "${pkg_name}"
        done
    else
        for pkg in "$@"; do
            _unstow_pkg "$pkg"
        done
    fi
}

_install_mise() {
    export PATH="$HOME/.local/bin:$PATH"
    export PATH="$HOME/.local/share/mise/shims:$PATH"

    if ! command -v mise >/dev/null 2>&1; then
        echo "Installing mise"
        curl -fsSL https://mise.run | sh
        # Re-export after install in case the installer just placed the binary
        export PATH="$HOME/.local/bin:$PATH"
        export PATH="$HOME/.local/share/mise/shims:$PATH"
    fi

    if ! command -v mise >/dev/null 2>&1; then
        echo "ERROR: mise not found after install. Check ~/.local/bin exists and curl succeeded."
        exit 1
    fi
}

_install_mise_tools() {
    _install_mise

    if ! gh auth status >/dev/null 2>&1; then
        echo ""
        echo "⚠ GitHub CLI is not authenticated — github: backend tools may be rate-limited."
        echo "  Run 'gh auth login', then re-run 'mise install'."
        echo ""
    fi

    _mise_modules_prompt

    mise install  # base tools plus the enabled modules

    "$(mise which python)" -m pip install --user pynvim
}

_install_tpm() {
    if [ ! -d "${HOME}/.tmux/plugins/tpm" ]; then
        echo "Installing tpm"
        git clone --depth=1 https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
        
        echo "Installing tpm plugins"
        ~/.tmux/plugins/tpm/scripts/install_plugins.sh
    fi
}

_install_zed() {
    if ! command -v zed >/dev/null 2>&1; then
        echo "Installing Zed"
        curl -f https://zed.dev/install.sh | sh
    fi
}

_install_fzf_git() {
    if [ ! -d "${HOME}/.local/share/fzf-git" ]; then
        echo "Installing fzf-git"
        git clone --depth=1 https://github.com/junegunn/fzf-git.sh.git ~/.local/share/fzf-git
    fi
}

_is_wsl() {
    [ -n "${WSL_DISTRO_NAME:-}" ] || grep -qi microsoft /proc/version 2>/dev/null
}

_install_wsl_config() {
    if ! cmp -s "${DOTFILES_DIR}/wsl/wsl.conf" /etc/wsl.conf; then
        echo "Installing WSL distro configuration"
        sudo install -m 644 "${DOTFILES_DIR}/wsl/wsl.conf" /etc/wsl.conf
    fi
}

# WSL clipboard: Neovim uses win32yank when it's on PATH (otherwise every paste
# runs powershell.exe), and so does tmux's paste binding
_install_win32yank() {
    if [ ! -x "$HOME/.local/bin/win32yank.exe" ]; then
        echo "Installing win32yank"
        curl -fsSL https://github.com/equalsraf/win32yank/releases/latest/download/win32yank-x64.zip -o /tmp/win32yank.zip
        mkdir -p ~/.local/bin
        unzip -o /tmp/win32yank.zip win32yank.exe -d ~/.local/bin
        chmod +x ~/.local/bin/win32yank.exe
        rm /tmp/win32yank.zip
    fi
}

_install_zinit() {
    if [ ! -d "${HOME}/.local/share/zinit/zinit.git" ]; then
        echo "Installing zinit"
        mkdir -p "${HOME}/.local/share/zinit"
        git clone --depth=1 https://github.com/zdharma-continuum/zinit.git "${HOME}/.local/share/zinit/zinit.git"
    fi
    
    if [ -d "${HOME}/.local/share/zinit/zinit.git" ]; then
        echo "Pre-installing zinit plugins and snippets (this may take a minute)..."
        export TERM=xterm-256color
        ZINIT_HOME="${HOME}/.local/share/zinit"
        zsh -c "
            source ${ZINIT_HOME}/zinit.git/zinit.zsh
            zinit light zdharma-continuum/fast-syntax-highlighting
            zinit light zsh-users/zsh-autosuggestions
            zinit light zsh-users/zsh-history-substring-search
            zinit snippet OMZP::command-not-found
            zinit snippet OMZP::colored-man-pages
            exit
        " 2>&1 | grep -v "^$" || true
        echo "Zinit plugins and snippets installed"
    fi
}

_install_fisher() {
    if ! fish -c 'type -q fisher' >/dev/null 2>&1; then
        echo "Installing fisher"
        fish -c 'curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher'
    fi

    # Install plugins from fish_plugins manifest
    if [ -f "${HOME}/.config/fish/fish_plugins" ]; then
        echo "Installing fisher plugins from fish_plugins manifest"
        fish -c 'fisher update'
    fi
}

# Run the global justfile's `update` recipe (system packages, mise, plugins,
# cleanup); it calls back into `dotfiles.sh system-update` for OS packages
_update_via_just() {
    _install_mise
    if ! command -v just >/dev/null 2>&1; then
        echo "just not found; run '${DOTFILES_SCRIPT} install' first (mise installs it)" >&2
        exit 1
    fi
    just --global-justfile update
}

_dotfiles_usage() {
    cat << EOF
Usage: ${DOTFILES_SCRIPT} <command> [options]

Commands:
    install                     Install all dotfiles and dependencies
    update                      Update installed tools and dependencies
    system-update               Update system packages only
    link [package1 package2...] Link dotfiles with stow (all or specific packages)
    unlink [package1 package2...] Unlink dotfiles with stow (all or specific packages)
    mise list                   List mise modules (* = enabled on this machine)
    mise enable <module...|all> Enable mise modules and install their tools
    mise disable <module...>    Disable mise modules
    check-links                 Check that every dotfile is still a link into this repo
EOF
}

# Shared command dispatch; the OS scripts (macos.sh, arch.sh, ubuntu.sh) define
# _install and _system_update, then end with: _dotfiles_main "$@"
_dotfiles_main() {
    if [ $# -lt 1 ]; then
        _dotfiles_usage
        exit 1
    fi
    local command="$1"
    shift
    case "$command" in
        install) _install ;;
        update) _update_via_just ;;
        system-update) _system_update ;;
        link) _link_dotfiles "$@" ;;
        unlink) _unlink_dotfiles "$@" ;;
        mise) _mise_modules_cmd "$@" ;;
        check-links)
            # shellcheck source=check-links.sh
            source "${_LIB_DIR}/check-links.sh"
            _check_links
            ;;
        *)
            echo "Unknown command: $command"
            _dotfiles_usage
            exit 1
            ;;
    esac
}
