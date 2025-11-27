# You may need to enable script execution if it's not allowed
# Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
#
# Install Scoop & dependencies
#Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
scoop install innounp neovim git gcc zig jq make direnv ag fzf main/nmap msys2 yq fd ripgrep zoxide yazi k9s starship kubectl kubectx mise
# Install the optional yazi dependencies (recommended):
scoop install ffmpeg 7zip poppler resvg imagemagick ghostscript opencode
gem install neovim

# Install mise tools and set global defaults
mise install node ruby python rust go dart dotnet flutter pipx
mise use -g node ruby python rust go dart dotnet flutter pipx
mise install npm:shx npm:opencode-ai
mise use -g npm:opencode-ai

# Install pynvim for neovim Python support
$pythonPath = mise which python
& $pythonPath -m pip install --user pynvim

# git config --global credential.helper manager
# TODO: Fix neovim
#
# TODO: Setup symlinks for configuration files (git, nvim, ruby, .ag, etc.)
New-Item -Path $HOME\AppData\Local\nvim -ItemType SymbolicLink -Value .\nvim\.config\nvim

# Setup git to use OpenSSH for 1Password authentication
git config --global core.sshCommand "C:/Windows/System32/OpenSSH/ssh.exe"

# Set git to use LF line endings in the repository and convert to CRLF on checkout
git config --global core.autocrlf true
