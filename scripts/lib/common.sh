#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "${SCRIPT_DIR}/../.." && pwd)"

STOW_PACKAGES=(
    bat
    bin
    carapace
    copilot
    delta
    fish
    gh
    gh-dash
    git
    just
    k9s
    lazydocker
    lazygit
    misc
    mise
    nvim
    posting
    sesh
    starship

    yazi
    tmux
    wezterm
    zsh
)

AI_PACKAGES=(
    claude
    copilot
    crush
    opencode
)

# Nested stow packages (require -d flag with subdirectory)
NESTED_STOW_PACKAGES=(
    skills/global
)

_bootstrap_stow() {
    if [ ! -f "${HOME}/.stow-global-ignore" ]; then
        cp "${DOTFILES_DIR}/stow-global-ignore" "${HOME}/.stow-global-ignore"
    fi
}

_link_dotfiles() {
    echo "Linking dotfiles with stow..."
    cd "${DOTFILES_DIR}" || exit 1
    if [ $# -eq 0 ]; then
        stow -vv "${STOW_PACKAGES[@]}"
        for pkg in "${NESTED_STOW_PACKAGES[@]}"; do
            local parent_dir=$(dirname "$pkg")
            local pkg_name=$(basename "$pkg")
            stow -vv -d "${DOTFILES_DIR}/${parent_dir}" -t "${HOME}" "${pkg_name}"
        done
    else
        stow -vv "$@"
    fi
}

_unlink_dotfiles() {
    echo "Unlinking dotfiles with stow..."
    cd "${DOTFILES_DIR}" || exit 1
    if [ $# -eq 0 ]; then
        stow -D -vv "${STOW_PACKAGES[@]}"
        for pkg in "${NESTED_STOW_PACKAGES[@]}"; do
            local parent_dir=$(dirname "$pkg")
            local pkg_name=$(basename "$pkg")
            stow -D -vv -d "${DOTFILES_DIR}/${parent_dir}" -t "${HOME}" "${pkg_name}"
        done
    else
        stow -D -vv "$@"
    fi
}

_install_mise() {
    if ! command -v mise >/dev/null 2>&1; then
        echo "Installing mise"
        curl -fsSL https://mise.run | sh
    fi

    export PATH="$HOME/.local/bin:$PATH"
    export PATH="$HOME/.local/share/mise/shims:$PATH"
}

_install_mise_tools() {
    _install_mise
    mise install
    $(mise which python) -m pip install --user pynvim
}

_install_tpm() {
    if [ ! -d "${HOME}/.tmux/plugins/tpm" ]; then
        echo "Installing tpm"
        git clone --depth=1 https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
        
        echo "Installing tpm plugins"
        ~/.tmux/plugins/tpm/scripts/install_plugins.sh
    fi
}

_install_fzf_git() {
    if [ ! -d "${HOME}/.local/share/fzf-git" ]; then
        echo "Installing fzf-git"
        git clone --depth=1 https://github.com/junegunn/fzf-git.sh.git ~/.local/share/fzf-git
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
        zsh -i -c "
            source ${ZINIT_HOME}/zinit.git/zinit.zsh
            zinit light zdharma-continuum/fast-syntax-highlighting
            zinit light zsh-users/zsh-autosuggestions
            zinit light zsh-users/zsh-history-substring-search
            zinit light Aloxaf/fzf-tab
            zinit snippet OMZP::git
            zinit snippet OMZP::command-not-found
            zinit snippet OMZP::colored-man-pages
            zinit snippet OMZP::common-aliases
            exit
        " 2>&1 | grep -v "^$"
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

_update_tpm() {
    if [ -d "${HOME}/.tmux/plugins/tpm" ]; then
        echo "Updating tpm..."
        git -C ~/.tmux/plugins/tpm pull --ff-only

        echo "Updating tpm plugins..."
        ~/.tmux/plugins/tpm/scripts/install_plugins.sh
        ~/.tmux/plugins/tpm/scripts/update_plugin.sh all
    fi
}

_update_zinit() {
    if [ -d "${HOME}/.local/share/zinit/zinit.git" ]; then
        echo "Updating zinit and zsh plugins..."
        export TERM=xterm-256color
        ZINIT_HOME="${HOME}/.local/share/zinit"
        zsh -i -c "
            source ${ZINIT_HOME}/zinit.git/zinit.zsh
            zinit self-update
            zinit update --all
            exit
        " 2>&1 | grep -v "^$"
        echo "Zinit plugins updated"
    fi
}

_update_fisher() {
    if command -v fish >/dev/null 2>&1 && fish -c 'type -q fisher' >/dev/null 2>&1; then
        echo "Updating fisher plugins..."
        fish -c 'fisher update'
    fi
}

_update_fzf_git() {
    if [ -d "${HOME}/.local/share/fzf-git" ]; then
        echo "Updating fzf-git..."
        git -C ~/.local/share/fzf-git pull --ff-only
    fi
}

_update_manual_tools() {
    echo "Updating manually installed tools..."

    if command -v go >/dev/null 2>&1; then
        echo "Updating regex-tui..."
        go install github.com/vitor-mariano/regex-tui@latest
    fi

    if [ -f "${HOME}/.local/bin/d4s" ]; then
        echo "Updating D4s..."
        curl -sSL https://raw.githubusercontent.com/shuntaka9576/d4s/main/install.sh | sh
    fi
}

_update_common() {
    echo "Updating common tools..."

    _install_mise
    mise upgrade
    mise install  # ensure any newly added tools in .mise.toml are installed
    $(mise which python) -m pip install --user pynvim

    _update_tpm
    _update_zinit
    _update_fisher
    _update_fzf_git
    _update_manual_tools
}
