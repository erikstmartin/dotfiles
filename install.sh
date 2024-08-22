# TODO: Install terraform
# TODO: Update tpm & plugins, fzf, fzf-git via git pull
# TODO: Update Neovim, Terraform, Go, Kubectl only if newer version available

# Versions
NVIM_VERSION=v0.10.1
#NVIM_VERSION=nightly
GO_VERSION=1.23.0

# Install tools
sudo apt install git wget curl zsh \
	build-essential make \
	ruby ruby-dev ruby-bundler python3 python3-venv rustup nodejs npm \
	python3-pynvim lua-curl luarocks libcurl4-openssl-dev xclip \
	postgresql-client socat \
	jq jqp yq entr mc bat zoxide delta eza git-delta tshark \
	tmux python3-tmuxp stow direnv htop neofetch ripgrep silversearcher-ag fd-find  

# Install atac
# https://github.com/public-apis/public-apis
rustup default 1.79
cargo install atac

# Instal tpm
if [ ! -d "${HOME}/.tmux/plugins/tpm" ]; then
	echo "Installing tpm"
	git clone --depth=1 https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

	# Install plugins
	echo "Installing tpm plugins"
	~/.tmux/plugins/tpm/scripts/install_plugins.sh
fi

# Install starship
curl -sS https://starship.rs/install.sh | sh

# Install neovim
echo "Installing neovim ${NVIM_VERSION}"
curl -L https://github.com/neovim/neovim/releases/download/${NVIM_VERSION}/nvim-linux64.tar.gz -o /tmp/nvim-linux64.tar.gz

sudo tar -C /usr/local -xzf /tmp/nvim-linux64.tar.gz --strip-components=1
rm /tmp/nvim-linux64.tar.gz

# Ensure luarocks can find curl headers
if [ ! -f /usr/include/curl/curl.h ] && [ ! -f /usr/local/include/curl/curl.h ] && [ ! -f /include/curl/curl.h ]; then
	sudo ln -s /usr/include/x86_64-linux-gnu/curl /usr/include/curl
fi

# Install Go
echo "Installing go ${GO_VERSION}"
curl -L https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz -o /tmp/go${GO_VERSION}.linux-amd64.tar.gz
sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf /tmp/go${GO_VERSION}.linux-amd64.tar.gz
rm /tmp/go${GO_VERSION}.linux-amd64.tar.gz

# Install Taskfile & completions
echo "Installing task"
/usr/local/go/bin/go install github.com/go-task/task/v3/cmd/task@latest
sudo curl -L https://raw.githubusercontent.com/go-task/task/main/completion/zsh/_task -o /usr/local/share/zsh/site-functions/_task

# Install fzf
echo "Installing fzf"
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install
git clone --depth=1 https://github.com/junegunn/fzf-git.sh.git ~/.local/share/fzf-git

# Install kubectl
echo "Installing kubectl"
curl -L "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" -o /tmp/kubectl
sudo install -o root -g root -m 0755 /tmp/kubectl /usr/local/bin/kubectl
rm /tmp/kubectl


# Install npiperelay for 1Password integration
curl -L "https://github.com/jstarks/npiperelay/releases/download/v0.1.0/npiperelay_windows_amd64.zip" -o /tmp/npiperelay_windows_amd64.zip
unzip /tmp/npiperelay_windows_amd64.zip -d /tmp/npiperelay
mkdir -p ~/bin
mv /tmp/npiperelay/npiperelay.exe ~/bin/npiperelay.exe

# Install termshark
/usr/local/go/bin/go install github.com/gcla/termshark/v2/cmd/termshark@v2.4.0

# Change shell
chsh -s /usr/bin/zsh
