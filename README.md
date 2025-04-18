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

```bash
./scripts/dotfiles.sh install
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
./scripts/dotfiles.sh link

# Link only specific packages
./scripts/dotfiles.sh link zsh nvim tmux

# Unlink all dotfiles
./scripts/dotfiles.sh unlink

# Unlink specific packages
./scripts/dotfiles.sh unlink zsh nvim
```

The install script will:
1. Install git and stow
2. Link dotfiles using stow (customizable in `scripts/lib/common.sh`)
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
- CLI tools: just, glow, gh, lazygit, lazydocker, yazi, starship, fzf, bat, eza, fd, ripgrep, zoxide, delta, kdash

**Tools managed by OS package managers:**
- System dependencies: tmux, neovim, kubectl, docker, lua, postgresql
- Platform-specific tools and libraries

**Tools installed manually:**
- Niche tools: D4s, regex-tui (not available in aqua registry)

##### Manual Linking (optional)
If you prefer to link configuration files individually:
```bash
cd <path-to-dotfiles>
stow -vv nvim zsh starship tmux
```

##### Using the dotfiles command
The `dotfiles.sh` script is located in the `scripts/` directory of wherever you cloned the repo:
```bash
<path-to-dotfiles>/scripts/dotfiles.sh update
<path-to-dotfiles>/scripts/dotfiles.sh link
<path-to-dotfiles>/scripts/dotfiles.sh unlink nvim
```

##### 1Password SSH agent

**macOS**: Enable the SSH agent in 1Password (Settings → Developer → Use the SSH agent).
The shell configs will automatically use it via `~/.ssh/config` — no extra setup needed.

**WSL**: Enable the SSH agent in 1Password on your Windows host (Settings → Developer → Use the SSH agent).
The shell configs automatically alias `ssh` → `ssh.exe` and `ssh-add` → `ssh-add.exe` on WSL,
forwarding SSH requests to the 1Password agent on Windows via WSL interoperability.

Optional WSL extras:
- Configure Git to use `ssh.exe`: `git config --global core.sshCommand "ssh.exe"`
- Configure Git commit signing: open the SSH key in 1Password → ⋮ → Configure Commit Signing → check "Configure for WSL"

Docs: https://developer.1password.com/docs/ssh/integrations/wsl


### Machine-local Overrides

Some settings differ between machines (work vs. personal) and should not be committed to the repo. Two files handle this — create them on any machine that needs overrides:

#### `~/.gitconfig-local`
Overrides git identity and any other git settings for this machine:
```gitconfig
[user]
  email = erik@company.com
  name = Erik St. Martin
```
Included unconditionally at the bottom of `.gitconfig`. Git silently ignores a missing file.

#### `~/.env.local`
Overrides or adds environment variables for this machine. Shared by both zsh and fish:
```sh
# Plain KEY=value format — no export keyword, no spaces around =
WORK_PROXY=http://proxy.company.com:8080
SOME_API_KEY=abc123
```
- **zsh**: sourced in `.zshenv` via `set -a / set +a` (auto-exports all vars)
- **fish**: loaded via `bass source ~/.env.local` in `conf.d/env.fish` (requires the `bass` plugin)

Neither file is tracked in this repo — both are listed in `.gitignore`.
