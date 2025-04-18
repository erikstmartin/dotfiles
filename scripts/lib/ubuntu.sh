#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../lib/common.sh"



_install_kubectl(){
	# Install kubectl
	echo "Installing kubectl"
	curl -L "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" -o /tmp/kubectl
	sudo install -o root -g root -m 0755 /tmp/kubectl /usr/local/bin/kubectl
	rm /tmp/kubectl
}


_install_carapace() {
	curl -fsSL "https://dl.fury.io/carapace-sh/gpg.key" | sudo gpg --dearmor -o /usr/share/keyrings/carapace-sh.gpg
	echo "deb [signed-by=/usr/share/keyrings/carapace-sh.gpg] https://dl.fury.io/carapace-sh/ * *" | sudo tee /etc/apt/sources.list.d/carapace-sh.list
	sudo apt update && sudo apt install -y carapace-bin
}

_install_terraform(){
	sudo apt-get update && sudo apt-get install -y gnupg software-properties-common

	# Download and install HashiCorp's public key
	wget -O- https://apt.releases.hashicorp.com/gpg | \
	gpg --dearmor | \
	sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null

	# This only works for GA releases
	# echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
	# https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \

	# Add the official HashiCorp Linux repository
	echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
	https://apt.releases.hashicorp.com oracular main" | \
	sudo tee /etc/apt/sources.list.d/hashicorp.list

	# Update and install
	sudo apt update
	sudo apt-get install terraform

}

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
	
	sudo apt install -y wget curl zsh fish \
		build-essential make autoconf patch \
		postgresql-client \
		jqp yq entr mc \
		tmux stow direnv htop btop ripgrep silversearcher-ag \
		llvm clang \
		clazy \
		cppcheck \
		ccache \
		heaptrack \
		spirv-tools \
		glslang-tools \
		libssl-dev libyaml-dev zlib1g-dev libffi-dev libgmp-dev \
		libreadline-dev libncurses5-dev libgdbm-dev libdb-dev \
		libgssapi-krb5-2

	# libicu version varies by Ubuntu release (needed for dotnet)
	. /etc/lsb-release
	case "$DISTRIB_CODENAME" in
		noble)   sudo apt install -y libicu74 ;;
		jammy)   sudo apt install -y libicu70 ;;
		*)       sudo apt install -y libicu-dev ;;
	esac

	_install_mise_tools

	gh extension install dlvhdr/gh-dash

	curl -fsSL https://d4scli.io/install.sh | sh -s -- ~/.local/bin

	go install github.com/vitor-mariano/regex-tui@latest
	go install github.com/joshmedeski/sesh/v2@latest

	pipx install posting

	if [ -z "$WSL_DISTRO_NAME" ]; then
		sudo apt install xclip
	fi

	mkdir -p ~/.cache/zinit/completions

	_install_tpm
	_install_jetbrains_nerd_font



	if [ ! -f /usr/include/curl/curl.h ] && [ ! -f /usr/local/include/curl/curl.h ] && [ ! -f /include/curl/curl.h ]; then
		sudo ln -s /usr/include/x86_64-linux-gnu/curl /usr/include/curl
	fi



	_install_fzf_git
	
	_install_zinit
	_install_fisher

	_install_terraform
	_install_carapace
	_install_kubectl
	
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
	sudo apt update && sudo apt upgrade -y
}

_update() {
	echo "Updating..."

	_system_update
	_update_common




	_install_kubectl
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
