#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../lib/common.sh"

# System dependencies and tools that require OS integration
BREW_PACKAGES=(
    carapace
    stow
    zsh
    fish
    git
    mise

    tmux
    kubectl
    docker
    the_silver_searcher
    ffmpeg
    resvg
    sesh
    imagemagick
    font-symbols-only-nerd-font
    font-jetbrains-mono-nerd-font
    sevenzip
    llvm
    clazy
    cppcheck
    ccache
    tracy

    spirv-tools
    glslang

    jqp
    poppler
    font-cascadia-code
    zlib
    readline
    libyaml
    libffi
    gmp
    openssl
    lua
    postgresql@15
    htop
    btop
    neofetch
    wget
    curl
    entr
    mc
    yq
    direnv
    )

_install() {
    brew update
    brew install stow git || brew upgrade stow git

    _bootstrap_stow
    _link_dotfiles
    
    # Update Homebrew and install core packages
    brew upgrade

    for pkg in "${BREW_PACKAGES[@]}"; do
        brew install "$pkg" || brew upgrade "$pkg"
    done

    brew tap hashicorp/tap
    brew install hashicorp/tap/terraform

    brew install 1password-cli

    _install_mise_tools
    
    gh extension install dlvhdr/gh-dash

    curl -fsSL https://d4scli.io/install.sh | sh -s -- ~/.local/bin

    go install github.com/vitor-mariano/regex-tui@latest

    _install_tpm
    _install_fzf_git
    
    _install_zinit
    _install_fisher

    echo "macOS setup complete!"
}

_system_update() {
    echo "Updating system packages..."
    brew update
    brew upgrade
}

_update() {
    _system_update
    _update_common
}

if [ $# -lt 1 ]; then
    echo "Usage: $0 <install|update|system-update|link|unlink> [packages...]";
    exit 1
fi

COMMAND="$1"
shift

case "$COMMAND" in
    update)
        _update
        ;;
    system-update)
        _system_update
        ;;
    link)
        _link_dotfiles "$@"
        ;;
    unlink)
        _unlink_dotfiles "$@"
        ;;
    install)
        _install
        ;;
    *)
        echo "Unknown command: $COMMAND"
        echo "Usage: $0 <install|update|system-update|link|unlink> [packages...]"
        exit 1
        ;;
esac
