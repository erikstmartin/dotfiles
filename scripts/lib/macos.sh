#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../lib/common.sh"

# System dependencies and tools that require OS integration
BREW_PACKAGES=(
    stow
    zsh
    fish
    git
    mise
    eza   # no macOS release binaries for mise (Linux/Windows get it from mise)

    tmux
    ffmpeg
    resvg
    imagemagick
    font-symbols-only-nerd-font
    font-jetbrains-mono-nerd-font
    sevenzip
    llvm
    clazy
    cppcheck
    bear
    ccache
    tracy

    spirv-tools
    glslang

    poppler
    font-cascadia-code
    zlib
    readline
    libyaml
    libffi
    gmp
    openssl
    lua
    postgresql
    htop
    btop
    fastfetch
    wget
    curl
    entr
    mc
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

    brew install 1password-cli

    brew install --cask hammerspoon || brew upgrade --cask hammerspoon
    brew install --cask zed || brew upgrade --cask zed
    # WezTerm's stable cask has been stuck on 20240203 since the maintainer
    # moved to a nightly-only release model; nightly is the tracked channel.
    brew install --cask wezterm@nightly || brew upgrade --cask wezterm@nightly

    _install_mise_tools
    
    gh extension install dlvhdr/gh-dash 2>/dev/null || true

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

_dotfiles_main "$@"
