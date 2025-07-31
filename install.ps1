# You may need to enable script execution if it's not allowed
# Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
#
# Install Scoop & dependencies
#Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
scoop install innounp neovim git gcc zig nodejs python go jq make direnv ag rustup fzf main/nmap msys2 ruby yq fd ripgrep zoxide yazi k9s starship kubectl kubectx
# Install the optional yazi dependencies (recommended):
scoop install ffmpeg 7zip poppler resvg imagemagick ghostscript
gem install neovim

# git config --global credential.helper manager
# TODO: Fix neovim
#
# TODO: Setup symlinks for configuration files (git, nvim, ruby, .ag, etc.)
New-Item -Path $HOME\AppData\Local\nvim -ItemType SymbolicLink -Value .\nvim\.config\nvim

# Setup git to use OpenSSH for 1Password authentication
git config --global core.sshCommand "C:/Windows/System32/OpenSSH/ssh.exe"

# Set git to use LF line endings in the repository and convert to CRLF on checkout
git config --global core.autocrlf true
