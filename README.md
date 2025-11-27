## Erik's dotfiles

A collection of tools, scripts, configuration to make my shell and vim more awesome

**📖 [Usage Guide - Keybindings, Aliases & Workflows](USAGE.md)**

### Install

This repo is meant to store configuration files which are then symlinked by using GNU Stow.

##### Download dotfiles
```bash
git clone git@github.com:erikstmartin/dotfiles.git ~/dotfiles
cd ~/dotfiles
git submodule update --init --recursive
```

##### Install Dependencies

**Unified script (auto-detects OS):**
```bash
./bin/dotfiles.sh install
```

**Or run platform-specific scripts:**
```bash
# macOS
./bin/lib/macos.sh install

# Ubuntu/Debian
./bin/lib/ubuntu.sh install

# Arch Linux
./bin/lib/arch.sh install
```

**Available commands:**
- `install` - Full installation (dotfiles + all dependencies)
- `update` - Update everything (system packages + mise tools + common tools)
- `system-update` - Update system packages only (brew/apt/pacman+yay)
- `link [package1 package2...]` - Link dotfiles with stow (all or specific packages)
- `unlink [package1 package2...]` - Unlink dotfiles with stow (all or specific packages)

**Update commands explained:**
- `system-update`: Fast, safe updates of OS packages only
  - macOS: `brew update && brew upgrade`
  - Arch: `pacman -Syu && yay -Syu`
  - Ubuntu: `apt update && apt upgrade`
- `update`: Comprehensive update of everything
  - Runs `system-update` first
  - Updates mise tools: `mise upgrade` (updates language runtimes and CLI tools)
  - Updates common tools (tpm, fzf, pynvim, etc.)

**Examples:**
```bash
# Link all dotfiles
./bin/dotfiles.sh link

# Link only specific packages
./bin/dotfiles.sh link zsh nvim tmux

# Unlink all dotfiles
./bin/dotfiles.sh unlink

# Unlink specific packages
./bin/dotfiles.sh unlink zsh nvim
```

The install script will:
1. Install git and stow
2. Link dotfiles using stow (customizable in `bin/lib/common.sh`)
3. Install system packages (OS-specific dependencies)
4. Install mise and all tools defined in `.mise.toml`
5. Install common tools (tpm, fzf, etc.)
6. Configure shell and tools

**Note**: The script links your dotfiles first to prevent conflicts with tools that create config files during installation.

### Tool Management

Most CLI tools are managed by [mise](https://mise.jdx.dev/) via the `.mise.toml` config file. This provides:
- **Cross-platform consistency** - Same tools, same versions across macOS/Linux/Arch
- **Version pinning** - Lock tool versions for reproducibility
- **Simple updates** - `mise upgrade` updates everything at once

**Tools managed by mise:**
- Language runtimes: node, python, ruby, rust, go, dart, dotnet, flutter
- CLI tools: just, task, glow, gh, lazygit, lazydocker, yazi, starship, fzf, bat, eza, fd, ripgrep, zoxide, delta, kdash

**Tools managed by OS package managers:**
- System dependencies: tmux, neovim, kubectl, docker, lua, postgresql
- Platform-specific tools and libraries

**Tools installed manually:**
- Niche tools: D4s, regex-tui, basalt-tui (not available in aqua registry)

##### Manual Linking (optional)
If you prefer to link configuration files individually:
```bash
cd <path-to-dotfiles>
stow -vv nvim zsh starship tmux
```

##### Using the dotfiles command
The `dotfiles.sh` script is located in the `bin/` directory of wherever you cloned the repo:
```bash
<path-to-dotfiles>/bin/dotfiles.sh update
<path-to-dotfiles>/bin/dotfiles.sh link
<path-to-dotfiles>/bin/dotfiles.sh unlink nvim
```

##### 1Password for ssh keys
You must turn on the SSH Agent in 1Password. You can find it under Settings->Developer
