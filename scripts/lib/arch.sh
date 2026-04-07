#!/usr/bin/env bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../lib/common.sh"

_install_yay() {
	if ! command -v yay >/dev/null 2>&1; then
		echo "Installing yay"
		sudo pacman -S --needed --noconfirm git base-devel
		git clone https://aur.archlinux.org/yay.git /tmp/yay
		(cd /tmp/yay && makepkg -si --noconfirm)
		rm -rf /tmp/yay
	fi
}

_install() {
	echo "Installing..."
	
	sudo pacman -Syu --needed --noconfirm stow git

	_bootstrap_stow
	_link_dotfiles
	
	sudo pacman -Syu --needed --noconfirm \
		wget curl unzip zsh fish \
		file ffmpeg 7zip poppler imagemagick resvg xdg-utils \
		base-devel make \
		lua \
		postgresql-libs \
		entr mc \
		tmux stow htop btop

	_install_yay
	yay -S --needed --noconfirm \
		fastfetch \
		ttf-jetbrains-mono-nerd \
		clazy \
		cppcheck \
		bear \
		heaptrack \
		tracy-bin

	sudo pacman -S --needed --noconfirm llvm clang ccache

	yay -S --needed --noconfirm spirv-tools glslang

	_install_mise_tools

	gh extension install dlvhdr/gh-dash 2>/dev/null || true

	if _is_wsl; then
		_install_wsl_config
		_install_win32yank
	fi

	_install_tpm
	_install_zed

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
}

_system_update() {
	echo "Updating system packages..."
	sudo pacman -Syu --noconfirm
	_install_yay
	yay -Syu --noconfirm
}

_dotfiles_main "$@"
