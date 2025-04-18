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
		wget curl zsh fish \
		base-devel make \
		lua \
		postgresql-libs \
		yq entr mc \
		tmux stow direnv htop btop the_silver_searcher \
		kubectl

	_install_yay
	yay -S --needed --noconfirm \
		jqp \
		sesh-bin \
		fastfetch \
		nerd-fonts-jetbrains-mono \
		clazy \
		cppcheck \
		heaptrack \
		tracy-bin

	sudo pacman -S --needed --noconfirm llvm clang ccache

	yay -S --needed --noconfirm spirv-tools glslang

	yay -S --needed --noconfirm carapace-bin
	_install_mise_tools

	gh extension install dlvhdr/gh-dash

	pipx install posting

	curl -fsSL https://d4scli.io/install.sh | sh -s -- ~/.local/bin

	go install github.com/vitor-mariano/regex-tui@latest

	_install_tpm

	_install_fzf_git
	
	_install_zinit
	_install_fisher

	if ! command -v terraform >/dev/null 2>&1; then
		yay -S --needed --noconfirm terraform
	fi

	if ! command -v kubectl >/dev/null 2>&1; then
		sudo pacman -S --needed --noconfirm kubectl
	fi

	if [ "$SHELL" != "$(which zsh)" ] && [ "$SHELL" != "/usr/bin/zsh" ]; then
		echo ""
		echo "================================================"
		echo "To change your default shell to zsh, run:"
		echo "  chsh -s \$(which zsh)"
		echo "================================================"
		echo ""
	fi
}

_system_update() {
	echo "Updating system packages..."
	sudo pacman -Syu --noconfirm
	_install_yay
	yay -Syu --noconfirm
}

_update() {
	echo "Updating..."
	_system_update
	_update_common

	if ! command -v terraform >/dev/null 2>&1; then
		yay -S --needed --noconfirm terraform
	fi
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
