#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../lib/common.sh"



_install_jetbrains_nerd_font() {
	# Install JetBrains Mono Nerd Font from GitHub releases
	echo "Installing JetBrains Mono Nerd Font"
	url=$(curl -s https://api.github.com/repos/ryanoasis/nerd-fonts/releases/latest | jq -r '.assets[] | select(.name | test("JetBrainsMono.*zip")) | .browser_download_url')
	curl -sL "$url" -o /tmp/JetBrainsMono.zip
	mkdir -p ~/.local/share/fonts
	unzip -o /tmp/JetBrainsMono.zip -d ~/.local/share/fonts
	fc-cache -fv ~/.local/share/fonts
	rm /tmp/JetBrainsMono.zip
}

_install() {
	echo "Installing..."
	
	sudo apt install -y git stow

	# Ensure locale exists — many minimal Ubuntu installs omit it
	sudo apt install -y locales
	sudo locale-gen en_US.UTF-8
	sudo update-locale LANG=en_US.UTF-8

	_bootstrap_stow
	_link_dotfiles

	local sevenzip="7zip"
	if ! apt-cache show "$sevenzip" >/dev/null 2>&1; then
		sevenzip="p7zip-full"
	fi
	local yazi_packages=(file ffmpeg "$sevenzip" poppler-utils imagemagick xdg-utils)
	if apt-cache show resvg >/dev/null 2>&1; then
		yazi_packages+=(resvg)
	fi

	sudo apt install -y wget curl zsh fish unzip \
		"${yazi_packages[@]}" \
		build-essential make autoconf patch \
		postgresql-client \
		entr mc \
		tmux stow htop btop \
		llvm clang \
		clazy \
		cppcheck \
		bear \
		ccache \
		heaptrack \
		spirv-tools \
		glslang-tools \
		libssl-dev libyaml-dev zlib1g-dev libffi-dev libgmp-dev \
		libreadline-dev libncurses5-dev libgdbm-dev libdb-dev \
		libgssapi-krb5-2

	# libicu version varies by Ubuntu release (needed for dotnet). Read the
	# codename in a subshell: /etc/lsb-release doesn't exist on Debian
	local codename=""
	if [ -r /etc/os-release ]; then
		codename="$(. /etc/os-release && echo "${VERSION_CODENAME:-}")"
	fi
	case "$codename" in
		noble)   sudo apt install -y libicu74 ;;
		jammy)   sudo apt install -y libicu70 ;;
		*)       sudo apt install -y libicu-dev ;;
	esac

	_install_mise_tools

	gh extension install dlvhdr/gh-dash 2>/dev/null || true

	if _is_wsl; then
		_install_wsl_config
		_install_win32yank
	else
		sudo apt install -y xclip
	fi

	mkdir -p ~/.cache/zinit/completions

	_install_tpm
	# On WSL, Windows renders the terminal font and runs GUI apps
	if ! _is_wsl; then
		_install_jetbrains_nerd_font
		_install_zed
	fi

	sudo ln -s "/usr/include/$(dpkg-architecture -qDEB_HOST_MULTIARCH)/curl" /usr/include/curl 2>/dev/null || true

	_install_fzf_git
	
	_install_zinit
	_install_fisher

	local fish_path
	fish_path="$(which fish 2>/dev/null)"
	if [ -n "$fish_path" ] && [ "$SHELL" != "$fish_path" ]; then
		if ! grep -qF "$fish_path" /etc/shells; then
			echo "$fish_path" | sudo tee -a /etc/shells
		fi
		chsh -s "$fish_path"
	fi

	echo ""
	echo "✓ Installation complete. Open a new terminal to start using fish."
}

_system_update() {
	echo "Updating system packages..."
	sudo apt update && sudo apt upgrade -y
}

_dotfiles_main "$@"
