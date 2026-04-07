## Erik's dotfiles

A collection of tools, scripts, configuration to make my shell and vim more awesome

See [USAGE.md](USAGE.md) for keybindings, aliases and workflows.

### Install

Configuration files are symlinked into place with GNU Stow.

##### Download dotfiles
```bash
git clone git@github.com:erikstmartin/dotfiles.git ~/dotfiles
cd ~/dotfiles
git submodule update --init --recursive
```

##### Install

```bash
./scripts/dotfiles.sh install
```

**Available commands:**
- `install` - Full installation (dotfiles + all dependencies)
- `update` - Update everything (system packages + mise tools + common tools)
- `system-update` - Update system packages only (brew/apt/pacman+yay)
- `link [package1 package2...]` - Link dotfiles with stow (all or specific packages)
- `unlink [package1 package2...]` - Unlink dotfiles with stow (all or specific packages)
- `mise list|enable|disable [module...]` - Choose which mise modules this machine installs (see Tool Management)
- `check-links` - Check that every dotfile is still a link into this repo (a tool that saves by replacing its config file turns the link into a copy). `update` also runs this

**Update commands:**
- `system-update`: OS packages only
  - macOS: `brew update && brew upgrade`
  - Arch: `pacman -Syu && yay -Syu`
  - Ubuntu: `apt update && apt upgrade`
- `update`: runs the global justfile's `update` recipe (`jg update` / `just --global-justfile update`) on every OS:
  - `system-update` (on Windows: winget and scoop)
  - mise: `mise upgrade` + `mise install` (and `mise self-update` on Linux, where mise isn't package-managed)
  - pynvim, `uv tool` upgrades (Windows), GitHub CLI extensions, Helm plugins (helm-diff, signature-verified)
  - tmux/zsh/fish plugins, fzf-git
  - Neovim plugins (`Lazy! sync`) and Treesitter parsers
  - cleanup: `mise prune`, `brew cleanup` / `scoop cleanup`, then reinstalling any Python-based tool (mise `pypi:` or `uv tool`) whose interpreter a Python upgrade removed

  A failed step doesn't stop the rest; failures are listed at the end and the command exits non-zero.
- `jg outdated`: shows what `update` would change (mise, Homebrew / pacman / apt / winget / scoop) without changing anything

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
4. Install mise, ask which mise modules to enable (first install only), then install the base tools plus those modules
5. Install common tools (tpm, fzf, etc.)
6. Configure shell and tools

Dotfiles are linked first so tools that create config files during installation don't conflict with them.

### Tool Management

Most CLI tools, language runtimes and editor tooling are managed by [mise](https://mise.jdx.dev/) (`mise/.config/mise/`), the same on macOS, Linux and Windows. Tools track `latest`; `jg update` upgrades them.

The config is split so each machine only installs what it's used for:
- **`config.toml` (base, every machine):** runtimes the base tools need (node, python, uv), shell tools (rg, fd, fzf, bat, eza, yazi, starship, zoxide, just), git tools (gh, lazygit, delta, difftastic, diffnav), workmux, posting, trivy, and Neovim with language support for files found everywhere (Lua, shell, Markdown, YAML, JSON, TOML, Copilot)
- **`modules/<name>.toml` (opt-in):** go, rust, python, ruby, dotnet, cpp, web, kubernetes, azure, terraform, containers, sql, proto, xml, godot, llm, and one per AI agent CLI (claude, codex, copilot, omp, opencode). The agent modules turn off the agents' own self-updaters; `mise upgrade` updates them. Each module carries its runtime and the tools built on it.

Modules are enabled per machine by linking them into `conf.d/` (git-ignored), which mise loads automatically. A module can also bring dotfiles packages (its `# dotfiles packages:` line, e.g. `k9s` for kubernetes, `azure` for azure, `opencode` for opencode): those are linked while the module is enabled and unlinked when it's disabled:
```bash
./scripts/dotfiles.sh mise list            # * marks the modules enabled here
./scripts/dotfiles.sh mise enable go rust  # or: all; installs their tools
./scripts/dotfiles.sh mise disable kubernetes  # installed versions stay until `mise prune`
```
On Windows: `scripts/dotfiles.ps1 mise list|enable|disable ...`. A first `install` prompts for modules.

To override a mise tool, install your own copy into `~/.local/bin`, `~/.cargo/bin` (`cargo install`) or `~/go/bin` (`go install`): those folders come ahead of mise's tools on PATH (the `_.path` setting in `config.toml`).

Outside mise: system packages from the OS package manager (tmux, docker, lua, postgresql, ...), eza on macOS (Homebrew; there are no macOS release binaries), and the tools mise has no build for.

Don't install or update a mise-declared tool (e.g. `npm:prettier`, `gem:rubocop`, `go:...`) with its underlying package manager (`npm install -g`, `gem install`, `go install`); that bypasses mise and can conflict with the mise version on PATH. Use `mise install <tool>` or `mise upgrade <tool>`.

### AI Harness Plugins

Custom cross-agent skills (`deslop`, `simplify`) live in `agents/.agents/skills/`; `./scripts/dotfiles.sh link` installs them at `~/.agents/skills/`.

- **OpenCode**, **GitHub Copilot CLI**, **Claude Code** and **Oh My Pi** - configs tracked in this repo, linked while the agent's mise module is enabled (see below)
- **Claude Code** (Superpowers) - one-time marketplace install:

  ```bash
  claude plugin install superpowers@claude-plugins-official
  ```

- **Codex** (Superpowers) - one-time marketplace install:

  ```bash
  codex plugin add superpowers@openai-curated
  ```

The Codex plugin install stays manual because `~/.codex/config.toml` mixes plugin
state with machine-local trust settings and paths.

Each agent's config comes with its mise module (`opencode`, `copilot`, `claude`,
`omp`): enabling the module installs the agent and links its config, disabling it
unlinks it. `link`/`install` link the configs of the modules already enabled.

```bash
./scripts/dotfiles.sh mise enable copilot opencode
# Windows: .\scripts\dotfiles.ps1 mise enable copilot opencode
```

Don't link these with a plain `stow copilot opencode`: their folders also hold the
agents' runtime data (sessions, caches, logs), so the scripts link them file by
file (stow `--no-folding`); a folded folder link would write that data into the repo.

##### Manual Linking
```bash
cd <path-to-dotfiles>
stow -vv nvim zsh starship tmux
```

##### 1Password SSH agent

**macOS**: Enable the SSH agent in 1Password (Settings → Developer → Use the SSH agent).
The shell configs use it via `~/.ssh/config`.

**WSL**: Enable the SSH agent in 1Password on your Windows host (Settings → Developer → Use the SSH agent).
Then add `WSL_1PASSWORD_SSH=1` to `~/.env.local`. The shell configs use Windows OpenSSH
for `ssh`, `ssh-add`, and git, forwarding SSH requests to the 1Password agent on Windows.
Without this opt-in, WSL uses its native OpenSSH.

Optional: Git commit signing: open the SSH key in 1Password → ⋮ → Configure Commit Signing → check "Configure for WSL"

Other WSL setup:
- `wsl/.wslconfig` (linked to `%USERPROFILE%\.wslconfig` by `dotfiles.ps1`): mirrored networking, and WSL stays up for an hour after the last tab closes. Apply with `wsl --shutdown`.
- `BROWSER` is `wsl-browser` (`bin/.local/bin`), which opens URLs in the Windows default browser.
- `ubuntu.sh` installs `win32yank.exe` (clipboard for Neovim and tmux), and skips the fonts and Zed, which belong on Windows.

Docs: https://developer.1password.com/docs/ssh/integrations/wsl


### Machine-local Overrides

Per-machine settings (work vs. personal) that aren't committed. Create these on any machine that needs them:

#### `~/.gitconfig-local`
Git identity and other per-machine git settings:
```gitconfig
[user]
  email = erik@company.com
  name = Erik St. Martin

[credential]
  helper = /mnt/c/Program\\ Files/Git/mingw64/bin/git-credential-manager.exe
```
Included unconditionally at the bottom of `.gitconfig`. Git silently ignores a missing file.

#### `~/.env.local`
Environment variables for this machine, read by both zsh and fish:
```sh
# Plain KEY=value format — no export keyword, no spaces around =
WORK_PROXY=http://proxy.company.com:8080
SOME_API_KEY=abc123
NOTES_DIR=$HOME/notes
```
- **zsh**: sourced in `.zshenv` via `set -a / set +a` (auto-exports all vars)
- **fish**: parsed natively in `conf.d/01_env.fish` (no plugin needed). Like zsh, it expands `$VAR` / `${VAR}` (unless single-quoted) and a leading `~` (when unquoted), but never runs code (no `$(...)`)

#### `~/.config/mise/config.local.toml`
Mise loads this on top of `config.toml`. Use it for machine-specific tool settings or registry overrides, e.g. a work machine that requires an internal npm/pip mirror:
```toml
[env]
NPM_CONFIG_REGISTRY = "https://npm.company.internal/registry"
NPM_CONFIG_USERCONFIG = "~/.npmrc-corporate"
HTTPS_PROXY = "http://proxy.company.com:8080"

[settings]
disable_tools = ["npm:some-tool-corp-blocks"]
```
`disable_tools` skips tools on that machine instead of failing `mise install`, e.g. when a mirror doesn't carry a package.

Machine-local, never committed: `~/.env.local` and `~/.gitconfig-local` live outside the repo; `~/.config/mise/config.local.toml` resolves into the repo and is git-ignored.

#### `~/.ssh/config`
Not tracked; edit it on each machine. WezTerm builds its SSH domain list (`Leader + Ctrl-Space` picker) from every `Host` entry here:
```sshconfig
Host homelab
  HostName 192.168.1.50
  User erikstmartin
```
