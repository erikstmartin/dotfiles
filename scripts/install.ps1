# You may need to enable script execution if it's not allowed
# Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
#
# Install Scoop & dependencies
#Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
# Add nerd-fonts bucket for JetBrains Mono Nerd Font
scoop bucket add nerd-fonts
scoop bucket add extras
scoop install extras/carapace-bin
scoop install innounp neovim git gcc zig make direnv ag main/nmap msys2 yq yazi k9s kubectl kubectx mise
# Install the optional yazi dependencies (recommended):
scoop install ffmpeg 7zip poppler resvg imagemagick ghostscript opencode JetBrainsMono-NF
gem install neovim

# Install mise tools (all tools defined in .mise.toml)
mise install

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
