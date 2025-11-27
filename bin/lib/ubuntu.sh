#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../lib/common.sh"

# Versions
#NVIM_VERSION=nightly
NVIM_VERSION=v0.11.6



_install_neovim() {
	# Install neovim
	echo "Installing neovim ${NVIM_VERSION}"
	curl -L https://github.com/neovim/neovim/releases/download/${NVIM_VERSION}/nvim-linux-x86_64.tar.gz -o /tmp/nvim-linux-x86_64.tar.gz

	sudo tar -C /usr/local -xzf /tmp/nvim-linux-x86_64.tar.gz --strip-components=1
	rm /tmp/nvim-linux-x86_64.tar.gz
}

_install_kubectl(){
	# Install kubectl
	echo "Installing kubectl"
	curl -L "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" -o /tmp/kubectl
	sudo install -o root -g root -m 0755 /tmp/kubectl /usr/local/bin/kubectl
	rm /tmp/kubectl
}

_install_task(){
	# Install Taskfile & completions
	echo "Installing task"
	go install github.com/go-task/task/v3/cmd/task@latest
	sudo curl -L https://raw.githubusercontent.com/go-task/task/main/completion/zsh/_task -o /usr/local/share/zsh/site-functions/_task
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

_install() {
	echo "Installing..."
	
	sudo apt install -y git stow
	
	_link_dotfiles
	
	sudo apt install -y wget curl zsh \
		build-essential make \
		lua-curl luarocks libcurl4-openssl-dev \
		postgresql-client socat \
		jq jqp yq entr mc \
		tmux stow direnv htop neofetch ripgrep silversearcher-ag

	_install_mise_tools

	gh extension install dlvhdr/gh-dash

	curl -fsSL https://d4scli.io/install.sh | sh -s -- ~/.local/bin

	go install github.com/vitor-mariano/regex-tui@latest

	cargo install basalt-tui

	cargo install --force yazi-build

	pipx install posting

	if [ -z "$WSL_DISTRO_NAME" ]; then
		sudo apt install xclip
	fi

	mkdir -p ~/.cache/zinit/completions

	_install_tpm

	_install_neovim

	if [ ! -f /usr/include/curl/curl.h ] && [ ! -f /usr/local/include/curl/curl.h ] && [ ! -f /include/curl/curl.h ]; then
		sudo ln -s /usr/include/x86_64-linux-gnu/curl /usr/include/curl
	fi

	_install_task

	_install_fzf
	
	_install_zinit

	_install_terraform
	_install_kubectl

	if [ -n "$WSL_DISTRO_NAME" ]; then
		curl -L "https://github.com/jstarks/npiperelay/releases/download/v0.1.0/npiperelay_windows_amd64.zip" -o /tmp/npiperelay_windows_amd64.zip
		unzip /tmp/npiperelay_windows_amd64.zip -d /tmp/npiperelay
		mkdir -p ~/bin
		mv /tmp/npiperelay/npiperelay.exe ~/bin/npiperelay.exe
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
	sudo apt update && sudo apt upgrade -y
}

_update() {
	echo "Updating..."

	_system_update
	_update_common

	CURRENT_NVIM_VERSION=$(nvim --version | awk 'BEGIN{FS=OFS=" ";} /NVIM/ { print $2; }')
	if [ "$CURRENT_NVIM_VERSION" != "$NVIM_VERSION" ]; then
		_install_neovim
	fi

	_install_task
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
