# Windows dotfiles installer
# Requires: Developer Mode enabled (for file symlinks) or run as Administrator
#
# Enable script execution if needed:
#   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

$dotfiles = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path

# ── Helpers ────────────────────────────────────────────────────────────────

function Test-DeveloperMode {
    try {
        $key = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock"
        return (Get-ItemProperty -Path $key -Name AllowDevelopmentWithoutDevLicense -ErrorAction SilentlyContinue).AllowDevelopmentWithoutDevLicense -eq 1
    } catch {
        return $false
    }
}

function Test-IsAdmin {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($identity)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# Create a symlink, safely removing any existing target first
# Junctions for directories (no elevation needed), SymbolicLink for files (needs Developer Mode or admin)
function Link-Config {
    param(
        [string]$Target,
        [string]$Source    # relative to $dotfiles
    )
    $sourcePath = Join-Path $dotfiles $Source
    if (-not (Test-Path $sourcePath)) {
        Write-Warning "Source not found, skipping: $sourcePath"
        return
    }
    $sourcePath = (Resolve-Path $sourcePath).Path

    $parent = Split-Path -Parent $Target
    if ($parent -and -not (Test-Path $parent)) {
        New-Item -ItemType Directory -Force -Path $parent | Out-Null
    }

    # Safely remove existing target (avoid Remove-Item -Recurse on junctions — PS 5.1 follows them)
    if (Test-Path $Target) {
        $item = Get-Item $Target -Force
        if ($item.Attributes -band [IO.FileAttributes]::ReparsePoint) {
            # Junction or symlink — delete the link itself, not what it points to
            $item.Delete()
        } else {
            Remove-Item -Force -Recurse $Target
        }
    }

    $isDir = Test-Path $sourcePath -PathType Container
    if ($isDir) {
        New-Item -Path $Target -ItemType Junction -Value $sourcePath | Out-Null
    } else {
        if (-not $script:canSymlink) {
            # Fall back to copying the file
            Copy-Item -Path $sourcePath -Destination $Target -Force
            Write-Host "  Copied: $Target <- $sourcePath"
            return
        }
        New-Item -Path $Target -ItemType SymbolicLink -Value $sourcePath | Out-Null
    }
    Write-Host "  Linked: $Target -> $sourcePath"
}

# ── Pre-flight checks ─────────────────────────────────────────────────────

$script:canSymlink = (Test-DeveloperMode) -or (Test-IsAdmin)
if (-not $script:canSymlink) {
    Write-Warning "Developer Mode not enabled and not running as Admin."
    Write-Warning "File symlinks will fall back to copies (directories still use junctions)."
    Write-Warning "Enable Developer Mode in Settings > For Developers for full symlink support."
}

# ── Scoop ──────────────────────────────────────────────────────────────────
if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
    Write-Host "Installing Scoop..."
    Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
}

scoop bucket add nerd-fonts 2>&1 | Out-Null
scoop bucket add extras 2>&1 | Out-Null
scoop install innounp git gcc zig make msys2 JetBrainsMono-NF

# Tools also available via mise, but needed early for bootstrapping
scoop install neovim

# Optional yazi preview dependencies
scoop install ffmpeg 7zip poppler resvg imagemagick ghostscript

# ── Symlinks ───────────────────────────────────────────────────────────────
Write-Host "`nCreating config symlinks..."

# Neovim
Link-Config "$HOME\AppData\Local\nvim" "nvim\.config\nvim"

# Git
Link-Config "$HOME\.gitconfig" "git\.gitconfig"
Link-Config "$HOME\.gitignore" "git\.gitignore"

# Delta
Link-Config "$HOME\.config\delta" "delta\.config\delta"

# Mise
Link-Config "$HOME\.config\mise" "mise\.config\mise"

# Starship
Link-Config "$HOME\.config\starship.toml" "starship\.config\starship.toml"

# WezTerm
Link-Config "$HOME\.config\wezterm" "wezterm\.config\wezterm"

# Lazygit
Link-Config "$HOME\AppData\Roaming\lazygit" "lazygit\.config\lazygit"

# Lazydocker
Link-Config "$HOME\AppData\Roaming\lazydocker" "lazydocker\.config\lazydocker"

# K9s
Link-Config "$HOME\AppData\Roaming\k9s" "k9s\.config\k9s"

# Bat
Link-Config "$HOME\AppData\Roaming\bat" "bat\.config\bat"

# Yazi
Link-Config "$HOME\AppData\Roaming\yazi\config" "yazi\.config\yazi"

# Carapace
Link-Config "$HOME\AppData\Roaming\carapace" "carapace\.config\carapace"

# Just (global justfile)
Link-Config "$HOME\.config\just" "just\.config\just"

# Glow
Link-Config "$HOME\.config\glow" "glow\.config\glow"

# GitHub CLI
Link-Config "$HOME\AppData\Roaming\GitHub CLI" "gh\.config\gh"

# gh-dash
Link-Config "$HOME\.config\gh-dash" "gh-dash\.config\gh-dash"

# OpenCode
Link-Config "$HOME\.config\opencode" "opencode\.config\opencode"

# Copilot
Link-Config "$HOME\.copilot" "copilot\.copilot"

# Superpowers / agent skills
Link-Config "$HOME\.agents" "skills\global\.agents"

# PowerShell profile — use $PROFILE path to handle OneDrive redirection
$profileDir = Split-Path -Parent $PROFILE.CurrentUserAllHosts
if (-not (Test-Path $profileDir)) {
    New-Item -ItemType Directory -Force -Path $profileDir | Out-Null
}
Link-Config $PROFILE.CurrentUserCurrentHost "powershell\Documents\PowerShell\Microsoft.PowerShell_profile.ps1"

# ── Git config ─────────────────────────────────────────────────────────────
# Windows-specific git settings go in .gitconfig-local (included by .gitconfig)
# so we don't pollute the shared dotfile
$gitconfigLocal = Join-Path $HOME ".gitconfig-local"
if (-not (Test-Path $gitconfigLocal)) {
    @"
[core]
    sshCommand = C:/Windows/System32/OpenSSH/ssh.exe
    autocrlf = true
"@ | Set-Content -Path $gitconfigLocal -Encoding UTF8
    Write-Host "  Created: $gitconfigLocal (Windows SSH config)"
} else {
    Write-Host "  Skipped: $gitconfigLocal already exists"
}

# ── Mise tools ─────────────────────────────────────────────────────────────
Write-Host "`nInstalling mise..."
if (-not (Get-Command mise -ErrorAction SilentlyContinue)) {
    scoop install mise 2>&1 | Out-Null
}

Write-Host "Installing mise tools (this may take a while)..."
mise install

# Language provider support for Neovim
$pythonPath = (mise which python)
& $pythonPath -m pip install --user pynvim
mise exec -- gem install neovim

# ── GitHub CLI extensions ──────────────────────────────────────────────────
if (Get-Command gh -ErrorAction SilentlyContinue) {
    Write-Host "Installing gh extensions..."
    gh extension install dlvhdr/gh-dash 2>&1 | Out-Null
}

# ── PSFzf module (fzf integration for PowerShell) ─────────────────────────
Write-Host "Installing PSFzf module..."
Install-Module -Name PSFzf -Scope CurrentUser -Force -SkipPublisherCheck -ErrorAction SilentlyContinue

Write-Host "`nDone! Restart your terminal for changes to take effect."
