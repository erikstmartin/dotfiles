#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "${SCRIPT_DIR}/../.." && pwd)"

STOW_PACKAGES=(
    delta
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
    ranger
    starship
    task
    yazi
    tmux
    zsh
)

_link_dotfiles() {
    echo "Linking dotfiles with stow..."
    cd "${DOTFILES_DIR}" || exit 1
    
    if [ $# -eq 0 ]; then
        stow -vv "${STOW_PACKAGES[@]}"
    else
        stow -vv "$@"
    fi
}

_unlink_dotfiles() {
    echo "Unlinking dotfiles with stow..."
    cd "${DOTFILES_DIR}" || exit 1
    
    if [ $# -eq 0 ]; then
        stow -D -vv "${STOW_PACKAGES[@]}"
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
    mise install node ruby python rust go dart dotnet flutter pipx
    mise use -g node ruby python rust go dart dotnet flutter pipx
    mise install npm:shx npm:opencode-ai pipx:tmuxp
    mise use -g npm:opencode-ai pipx:tmuxp

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

_install_fzf() {
    if [ ! -d "${HOME}/.fzf" ]; then
        echo "Installing fzf"
        git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
        ~/.fzf/install --key-bindings --completion --no-update-rc
    fi
    
    if [ ! -d "${HOME}/.local/share/fzf-git" ]; then
        git clone --depth=1 https://github.com/junegunn/fzf-git.sh.git ~/.local/share/fzf-git
    fi
    
    mkdir -p "/tmp/$(whoami)/zsh-fzf-tab-$(whoami)"
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
            zinit light zdharma/fast-syntax-highlighting
            zinit light zsh-users/zsh-completions
            zinit light zsh-users/zsh-autosuggestions
            zinit light zsh-users/zsh-history-substring-search
            zinit light Aloxaf/fzf-tab
            zinit snippet OMZP::git
            zinit snippet OMZP::sudo
            zinit snippet OMZP::aws
            zinit snippet OMZP::azure
            zinit snippet OMZP::microk8s
            zinit snippet OMZP::podman
            zinit snippet OMZP::helm
            zinit snippet OMZP::command-not-found
            zinit snippet OMZP::colored-man-pages
            zinit snippet OMZP::common-aliases
            exit
        " 2>&1 | grep -v "^$"
        echo "Zinit plugins and snippets installed"
    fi
}

_update_manual_tools() {
    echo "Updating manually installed tools..."
    
    if command -v cargo >/dev/null 2>&1; then
        echo "Updating basalt-tui..."
        cargo install basalt-tui
        
        echo "Updating yazi..."
        cargo install --force yazi-build
    fi
    
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
    mise install npm:shx npm:opencode-ai pipx:tmuxp
    $(mise which python) -m pip install --user pynvim
    
    if [ -d "${HOME}/.tmux/plugins/tpm" ]; then
        echo "Updating tpm"
        cd ~/.tmux/plugins/tpm && git pull
    fi
    
    if [ -d "${HOME}/.fzf" ]; then
        echo "Updating fzf"
        cd ~/.fzf && git pull && ./install --key-bindings --completion --no-update-rc
    fi
    
    if [ -d "${HOME}/.local/share/fzf-git" ]; then
        cd ~/.local/share/fzf-git && git pull
    fi
    
    _update_manual_tools
}
