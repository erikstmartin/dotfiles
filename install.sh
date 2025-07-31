# Versions
#NVIM_VERSION=nightly
NVIM_VERSION=v0.11.3
GO_VERSION=1.24.5
TERMSHARK_VERSION=v2.4.0

_install_starship() {
	echo "Installing starship"
	curl -sS https://starship.rs/install.sh | sudo sh
}

_install_neovim() {
	# Install neovim
	echo "Installing neovim ${NVIM_VERSION}"
	curl -L https://github.com/neovim/neovim/releases/download/${NVIM_VERSION}/nvim-linux-x86_64.tar.gz -o /tmp/nvim-linux-x86_64.tar.gz

	sudo tar -C /usr/local -xzf /tmp/nvim-linux-x86_64.tar.gz --strip-components=1
	rm /tmp/nvim-linux-x86_64.tar.gz
}

_install_go(){
	# Install Go
	echo "Installing go ${GO_VERSION}"
	curl -L https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz -o /tmp/go${GO_VERSION}.linux-amd64.tar.gz
	sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf /tmp/go${GO_VERSION}.linux-amd64.tar.gz
	rm /tmp/go${GO_VERSION}.linux-amd64.tar.gz
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
	/usr/local/go/bin/go install github.com/go-task/task/v3/cmd/task@latest
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
	# Install tools
	sudo apt install git wget curl zsh \
		build-essential make \
		ruby rbenv ruby-dev ruby-bundler python3 python3-venv rustup nodejs npm \
		python3-pynvim lua-curl luarocks libcurl4-openssl-dev \
		postgresql-client socat \
		jq jqp yq entr mc bat zoxide delta eza git-delta tshark \
		tmux python3-tmuxp stow direnv htop neofetch ripgrep silversearcher-ag fd-find  

	rustup install stable
	rustup default stable

	sudo npm install -g shx@latest

	# Only install xclip if not running in WSL
	if [ -z "$WSL_DISTRO_NAME" ]; then
		sudo apt install xclip
	fi

	mkdir ~/.cache/zinit/completions

	# Install tpm
	if [ ! -d "${HOME}/.tmux/plugins/tpm" ]; then
		echo "Installing tpm"
		git clone --depth=1 https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

		# Install plugins
		echo "Installing tpm plugins"
		~/.tmux/plugins/tpm/scripts/install_plugins.sh
	fi

	_install_starship
	_install_neovim

	# Ensure luarocks can find curl headers
	if [ ! -f /usr/include/curl/curl.h ] && [ ! -f /usr/local/include/curl/curl.h ] && [ ! -f /include/curl/curl.h ]; then
		sudo ln -s /usr/include/x86_64-linux-gnu/curl /usr/include/curl
	fi

	_install_task

	# Install fzf
	echo "Installing fzf"
	git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
	~/.fzf/install
	git clone --depth=1 https://github.com/junegunn/fzf-git.sh.git ~/.local/share/fzf-git
	mkdir -p "/tmp/$(whoami)/zsh-fzf-tab-$(whoami)"

	_install_terraform
	_install_kubectl

	# Install npiperelay for 1Password integration
	curl -L "https://github.com/jstarks/npiperelay/releases/download/v0.1.0/npiperelay_windows_amd64.zip" -o /tmp/npiperelay_windows_amd64.zip
	unzip /tmp/npiperelay_windows_amd64.zip -d /tmp/npiperelay
	mkdir -p ~/bin
	mv /tmp/npiperelay/npiperelay.exe ~/bin/npiperelay.exe

	# Install termshark
	/usr/local/go/bin/go install github.com/gcla/termshark/v2/cmd/termshark@${TERMSHARK_VERSION}
	
	# Install yazi
	cargo install --locked yazi-fm yazi-cli

	# Change shell
	chsh -s /usr/bin/zsh
}

_update() {
	echo "Updating..."

	# Update tpm
	echo "Updating tpm"
	cd ~/.tmux/plugins/tpm && git pull

	_install_starship

	CURRENT_NVIM_VERSION=$(nvim --version | awk 'BEGIN{FS=OFS=" ";} /NVIM/ { print $2; }')
	if [ "$CURRENT_NVIM_VERSION" != "$NVIM_VERSION" ]; then
		_install_neovim
	fi

	# Update Go
	CURRENT_GO_VERSION=$(go version | awk 'BEGIN{FS=OFS=" ";} { print $3; }')
	if [ "$CURRENT_GO_VERSION" != "go$GO_VERSION" ]; then
		echo "Updating go"
		_install_go
	fi

	# Update task
	_install_task

	# Update fzf
	echo "Updating fzf"
	cd ~/.fzf && git pull && ./install
	cd ~/.local/share/fzf-git && git pull
	
	# Update kubectl
	_install_kubectl

	# Update yazi
	echo "Updating yazi"
	cargo install --locked yazi-fm yazi-cli
	ya pack -u
}

if [ $# -gt  1 ]; then
	echo "Usage: $0 <install|update|system-update>";
	exit 1
elif [ "$1" = "update" ]; then
	_update
elif [ "$1" = "system-update" ]; then
	sudo apt update && sudo apt upgrade -y
	rustup update
else
	_install
fi
