# Windows dotfiles installer
# Requires: Developer Mode enabled (for file symlinks) or run as Administrator
#
# Enable script execution if needed:
#   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
#
# Usage: dotfiles.ps1 [install|update|system-update|link|unlink|mise]
#   install        Full installation (default)
#   update         Everything (runs `just --global-justfile update`)
#   system-update  winget upgrade --all only
#   link           (Re-)create config symlinks only
#   unlink         Remove config symlinks
#   check-links    Check that every config is still a link into this repo
#   mise list | enable <module...|all> | disable <module...>
#                  mise modules (mise\.config\mise\modules) enabled on this machine

param(
    [ValidateSet("install", "update", "system-update", "link", "unlink", "check-links", "mise")]
    [string]$Command = "install",
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$Rest = @()
)

$dotfiles = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path

# -- Helpers ----------------------------------------------------------------

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

function Install-Winget {
    param([string]$Id)
    winget install --id $Id --source winget --accept-package-agreements --accept-source-agreements --disable-interactivity
}

function Initialize-MiseDataDir {
    $defaultDataDir = "$HOME\AppData\Local\mise"
    $shortDataDir = "C:\mise"
    New-Item -ItemType Directory -Force -Path $defaultDataDir -ErrorAction Stop | Out-Null

    $item = Get-Item -LiteralPath $shortDataDir -Force -ErrorAction SilentlyContinue
    if ($item) {
        $target = @($item.Target)[0]
        if (-not ($item.Attributes -band [IO.FileAttributes]::ReparsePoint) -or
            $target.TrimEnd('\') -ne $defaultDataDir.TrimEnd('\')) {
            throw "$shortDataDir must link to $defaultDataDir"
        }
    } else {
        New-Item -ItemType Junction -Path $shortDataDir -Target $defaultDataDir -ErrorAction Stop | Out-Null
    }

    $env:MISE_DATA_DIR = $shortDataDir
    [Environment]::SetEnvironmentVariable("MISE_DATA_DIR", $shortDataDir, "User")
}

function Initialize-YaziFileOne {
    $fileOne = Join-Path $env:ProgramFiles "Git\usr\bin\file.exe"
    if (-not (Test-Path -LiteralPath $fileOne -PathType Leaf)) {
        throw "Yazi requires Git for Windows file.exe at $fileOne"
    }
    $env:YAZI_FILE_ONE = $fileOne
    [Environment]::SetEnvironmentVariable("YAZI_FILE_ONE", $fileOne, "User")
}

# Create a symlink, replacing an existing link. A real file or folder in the
# way (e.g. a config a tool replaced with a copy) is renamed to
# <target>.bak-<timestamp>, never deleted.
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
    if ($parent) {
        $parentItem = Get-Item -LiteralPath $parent -Force -ErrorAction SilentlyContinue
        if ($parentItem -and ($parentItem.Attributes -band [IO.FileAttributes]::ReparsePoint)) {
            $parentTarget = @($parentItem.Target)[0]
            if ($parentTarget -and -not [IO.Path]::IsPathRooted($parentTarget)) {
                $parentTarget = [IO.Path]::GetFullPath((Join-Path (Split-Path -Parent $parent) $parentTarget))
            }
            if ($parentTarget -and -not (Test-Path -LiteralPath $parentTarget -PathType Container)) {
                $parentItem.Delete()
                $parentItem = $null
            }
        }
        if ($parentItem -and -not (Test-Path -LiteralPath $parent -PathType Container)) {
            throw "Link parent is not a directory: $parent"
        }
        if (-not $parentItem) {
            New-Item -ItemType Directory -Force -Path $parent -ErrorAction Stop | Out-Null
        }
    }

    # Get-Item rather than Test-Path, which is false for a dangling link
    $item = Get-Item -LiteralPath $Target -Force -ErrorAction SilentlyContinue
    if ($item) {
        if ($item.Attributes -band [IO.FileAttributes]::ReparsePoint) {
            # Junction or symlink - delete the link itself, not what it points to
            # (no Remove-Item -Recurse: PS 5.1 follows junctions)
            $item.Delete()
        } else {
            $backup = "$Target.bak-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
            Rename-Item -LiteralPath $Target -NewName (Split-Path -Leaf $backup)
            Write-Warning "Not a link, moved aside: $Target -> $backup (merge any changes into the repo)"
        }
    }

    $isDir = Test-Path $sourcePath -PathType Container
    if ($isDir) {
        New-Item -Path $Target -ItemType Junction -Value $sourcePath -ErrorAction Stop | Out-Null
    } else {
        New-Item -Path $Target -ItemType SymbolicLink -Value $sourcePath -ErrorAction Stop | Out-Null
    }
    Write-Host "  Linked: $Target -> $sourcePath"
}

function Unlink-Config {
    param([string]$Target)
    if (Test-Path $Target) {
        $item = Get-Item $Target -Force
        if ($item.Attributes -band [IO.FileAttributes]::ReparsePoint) {
            $item.Delete()
            Write-Host "  Unlinked: $Target"
        } else {
            Write-Warning "Not a link, skipping: $Target"
        }
    }
}

# Folders that also hold the tool's own runtime data (logs, sessions, caches):
# link each entry inside them instead of the whole folder, so that data isn't
# written into the repo (like stow's --no-folding on macOS/Linux)
$entryLinkedDirs = [ordered]@{
    "$HOME\.config\opencode" = "opencode\.config\opencode"
    "$HOME\.copilot"         = "copilot\.copilot"
}

# All symlink targets, keyed by dotfiles-relative source. Shared by link/unlink.
# Links for this machine: base packages plus those of enabled mise modules.
# -Packages limits it to the given packages (used by `mise enable/disable`).
function Get-ConfigLinks([string[]]$Packages) {
    # The PowerShell 7 profile, also when this runs in Windows PowerShell 5.1
    # (whose $PROFILE is under Documents\WindowsPowerShell)
    $pwshProfile = Join-Path ([Environment]::GetFolderPath('MyDocuments')) "PowerShell\Microsoft.PowerShell_profile.ps1"
    $links = [ordered]@{
        "$HOME\AppData\Local\nvim"          = "nvim\.config\nvim"
        "$HOME\.gitconfig"                  = "git\.gitconfig"
        "$HOME\.gitignore"                  = "git\.gitignore"
        "$HOME\.config\delta"               = "delta\.config\delta"
        "$HOME\.config\mise"                = "mise\.config\mise"
        "$HOME\.config\starship.toml"       = "starship\.config\starship.toml"
        "$HOME\.config\wezterm"             = "wezterm\.config\wezterm"
        "$HOME\AppData\Roaming\lazygit"     = "lazygit\.config\lazygit"
        "$HOME\AppData\Roaming\jesseduffield\lazydocker" = "lazydocker\.config\lazydocker"
        "$HOME\AppData\Local\k9s"           = "k9s\.config\k9s"
        "$HOME\AppData\Roaming\bat"         = "bat\.config\bat"
        "$HOME\AppData\Roaming\eza"         = "eza\.config\eza"
        "$HOME\AppData\Roaming\fd"          = "fd\.config\fd"
        "$HOME\AppData\Roaming\yazi\config" = "yazi\.config\yazi"
        "$HOME\AppData\Roaming\carapace"    = "carapace\.config\carapace"
        "$HOME\.config\just"                = "just\.config\just"
        "$HOME\.config\yamllint"            = "yamllint\.config\yamllint"
        "$HOME\AppData\Roaming\GitHub CLI"  = "gh\.config\gh"
        "$HOME\.config\gh-dash"             = "gh-dash\.config\gh-dash"
        "$HOME\.omo\omo.jsonc"               = "opencode\.omo\omo.jsonc"
        "$HOME\.azure\config"                = "azure\.azure\config"
        "$HOME\.wslconfig"                   = "wsl\.wslconfig"
        "$HOME\.agents\skills"              = "agents\.agents\skills"
        # ~\.claude and ~\.omp also hold the agents' runtime data: link the file only
        "$HOME\.claude\settings.json"       = "claude\.claude\settings.json"
        "$HOME\.omp\agent\config.yml"       = "omp\.omp\agent\config.yml"
        $pwshProfile                        = "powershell\Documents\PowerShell\Microsoft.PowerShell_profile.ps1"
    }
    foreach ($dir in $entryLinkedDirs.Keys) {
        $source = $entryLinkedDirs[$dir]
        foreach ($entry in Get-ChildItem -LiteralPath (Join-Path $dotfiles $source) -Force) {
            $links[(Join-Path $dir $entry.Name)] = Join-Path $source $entry.Name
        }
    }
    # Packages that belong to a mise module are linked only while it's enabled
    $skip = if ($Packages) { @() } else { Get-DisabledModulePackages }
    $result = [ordered]@{}
    foreach ($target in $links.Keys) {
        $package = ($links[$target] -split '[\\/]')[0]
        if ($Packages -and $Packages -notcontains $package) { continue }
        if ($skip -contains $package) { continue }
        $result[$target] = $links[$target]
    }
    return $result
}

# Where older versions of this script linked k9s and lazydocker; neither tool
# reads these folders on Windows
$staleLinks = @("$HOME\AppData\Roaming\k9s", "$HOME\AppData\Roaming\lazydocker")

function Invoke-Link {
    Write-Host "`nCreating config symlinks..."
    foreach ($stale in $staleLinks) { Unlink-Config $stale }
    # Older setups linked these whole folders into the repo; make them real
    # folders again so the per-entry links don't end up inside the repo
    $skip = Get-DisabledModulePackages
    foreach ($dir in $entryLinkedDirs.Keys) {
        if ($skip -contains ($entryLinkedDirs[$dir] -split '[\\/]')[0]) { continue }
        $item = Get-Item -LiteralPath $dir -Force -ErrorAction SilentlyContinue
        if ($item -and ($item.Attributes -band [IO.FileAttributes]::ReparsePoint)) {
            $item.Delete()
            Write-Host "  Unlinked folder: $dir (now linking its entries instead)"
        }
        New-Item -ItemType Directory -Force -Path $dir | Out-Null
    }
    $links = Get-ConfigLinks
    foreach ($target in $links.Keys) {
        Link-Config $target $links[$target]
    }

    # Windows-specific git settings go in .gitconfig-local (included by .gitconfig)
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
}

function Invoke-Unlink {
    Write-Host "`nRemoving config symlinks..."
    $links = Get-ConfigLinks
    foreach ($target in $links.Keys) {
        Unlink-Config $target
    }
}

# Check every link in Get-ConfigLinks still points into this repo. Tools that
# save by writing a new file and renaming it replace the link with a copy, and
# `link` would then overwrite that copy, so report before anything is lost.
function Invoke-CheckLinks {
    $problems = @()
    $links = Get-ConfigLinks
    foreach ($target in $links.Keys) {
        $sourcePath = Join-Path $dotfiles $links[$target]
        if (-not (Test-Path $sourcePath)) { continue }
        $sourcePath = (Resolve-Path $sourcePath).Path
        $item = Get-Item -LiteralPath $target -Force -ErrorAction SilentlyContinue
        if (-not $item) {
            $problems += "Not linked (dotfiles.ps1 link): $target"
        } elseif (-not ($item.Attributes -band [IO.FileAttributes]::ReparsePoint)) {
            $problems += "Replaced by a copy (merge any changes into the repo, delete it, then dotfiles.ps1 link): $target"
        } else {
            $dest = if ($item.LinkTarget) { $item.LinkTarget } else { @($item.Target)[0] }
            if (-not [IO.Path]::IsPathRooted($dest)) {
                $dest = [IO.Path]::GetFullPath((Join-Path (Split-Path -Parent $target) $dest))
            }
            if ($dest.TrimEnd('\', '/') -ne $sourcePath.TrimEnd('\', '/')) {
                $problems += "Linked somewhere else: $target -> $dest"
            }
        }
    }
    if ($problems.Count -eq 0) {
        Write-Host "OK: all dotfiles are linked"
        return $true
    }
    $problems | ForEach-Object { Write-Host "  $_" -ForegroundColor Yellow }
    return $false
}

# -- mise modules -------------------------------------------------------------
# modules\<name>.toml are enabled per machine by linking them into conf.d\
# (git-ignored), which mise loads automatically. Same layout as dotfiles.sh.
# Module files are read from the repo: ~\.config\mise isn't linked yet on a
# fresh machine.
$miseConfigDir = if ($env:MISE_CONFIG_DIR) { $env:MISE_CONFIG_DIR } else { "$HOME\.config\mise" }
$miseModulesDir = Join-Path $dotfiles "mise\.config\mise\modules"
$miseConfDir = Join-Path $miseConfigDir "conf.d"

function Get-MiseModules {
    Get-ChildItem -Path $miseModulesDir -Filter *.toml | ForEach-Object {
        [pscustomobject]@{
            Name        = $_.BaseName
            Enabled     = Test-Path (Join-Path $miseConfDir $_.Name)
            Description = ((Get-Content $_.FullName -TotalCount 1) -replace '^#\s*', '')
            # Dotfiles packages the module brings ("# dotfiles packages: ..." line)
            Packages    = @(Get-Content $_.FullName | Select-String '^# dotfiles packages:\s*([^(]+)' |
                ForEach-Object { $_.Matches[0].Groups[1].Value.Trim() -split '\s+' })
        }
    }
}

# Module tools that are better installed with WinGet on Windows (mise can't
# reliably build these Python-based CLIs here). `update` upgrades them with
# `winget upgrade --all`.
$moduleWingetPackages = @{
    azure = @("Microsoft.AzureCLI")
}

# Module tools that mise installs with pipx on linux/macOS only: `uv tool` (uv
# comes from mise) installs them here. `update` runs `uv tool upgrade --all`.
$moduleUvTools = @{
    cpp   = @("gersemi")
    sql   = @("sqlfluff")
    godot = @("gdtoolkit")
}

function Invoke-Uv([string[]]$Arguments) {
    $uvPath = (mise which uv)
    if ($LASTEXITCODE -ne 0 -or -not $uvPath) {
        throw "uv is not installed; run 'mise install' first"
    }
    & $uvPath @Arguments
    if ($LASTEXITCODE -ne 0) {
        throw "uv $($Arguments -join ' ') failed with exit code $LASTEXITCODE"
    }
}

# Windows-only installs for the given modules; run after `mise install` (uv)
function Install-ModuleWindowsTools([string[]]$Names) {
    foreach ($name in $Names) {
        foreach ($id in $moduleWingetPackages[$name]) {
            Write-Host "Installing $id via winget ($name module)..."
            Install-Winget $id
        }
        foreach ($tool in $moduleUvTools[$name]) {
            Write-Host "Installing $tool via uv ($name module)..."
            Invoke-Uv @("tool", "install", "--quiet", $tool)
        }
    }
}

# Throw unless every name is a module
function Assert-MiseModules([string[]]$Names) {
    $known = @(Get-MiseModules | ForEach-Object { $_.Name })
    $unknown = @($Names | Where-Object { $known -notcontains $_ })
    if ($unknown.Count -gt 0) { throw "Unknown module(s): $($unknown -join ' ') (see: dotfiles.ps1 mise list)" }
}

# Packages of modules that aren't enabled (and that no enabled module also uses)
function Get-DisabledModulePackages {
    $modules = @(Get-MiseModules)
    $enabled = @($modules | Where-Object Enabled | ForEach-Object { $_.Packages })
    @($modules | Where-Object { -not $_.Enabled } | ForEach-Object { $_.Packages } | Where-Object { $enabled -notcontains $_ })
}

function Show-MiseModules {
    foreach ($m in Get-MiseModules) {
        $mark = if ($m.Enabled) { "*" } else { " " }
        Write-Host (" {0} {1,-12} {2}" -f $mark, $m.Name, $m.Description)
    }
    Write-Host "(* = enabled)"
}

function Enable-MiseModules([string[]]$Names) {
    if ($Names -contains "all") { $Names = (Get-MiseModules).Name }
    Assert-MiseModules $Names
    New-Item -ItemType Directory -Force -Path $miseConfDir | Out-Null
    foreach ($name in $Names) {
        $source = Join-Path $miseModulesDir "$name.toml"
        $link = Join-Path $miseConfDir "$name.toml"
        $existing = Get-Item -LiteralPath $link -Force -ErrorAction SilentlyContinue
        if ($existing) { $existing.Delete() }
        New-Item -ItemType SymbolicLink -Path $link -Target $source | Out-Null
        $packages = (Get-MiseModules | Where-Object Name -eq $name).Packages
        if ($packages) {
            foreach ($dir in $entryLinkedDirs.Keys) {
                if ($packages -contains ($entryLinkedDirs[$dir] -split '[\\/]')[0]) {
                    New-Item -ItemType Directory -Force -Path $dir | Out-Null
                }
            }
            $links = Get-ConfigLinks -Packages $packages
            foreach ($target in $links.Keys) { Link-Config $target $links[$target] }
        }
        Write-Host "Enabled $name"
    }
}

function Disable-MiseModules([string[]]$Names) {
    Assert-MiseModules $Names
    foreach ($name in $Names) {
        Remove-Item (Join-Path $miseConfDir "$name.toml") -Force -ErrorAction SilentlyContinue
        $packages = (Get-MiseModules | Where-Object Name -eq $name).Packages
        if ($packages) {
            $links = Get-ConfigLinks -Packages $packages
            foreach ($target in $links.Keys) { Unlink-Config $target }
        }
        Write-Host "Disabled $name"
    }
    Write-Host "Installed versions stay until 'mise prune'."
}

# Ask which modules to enable, the first time only (no modules enabled yet),
# and only when someone can answer
function Request-MiseModules {
    if ((Get-MiseModules | Where-Object Enabled)) { return }
    if (-not [Environment]::UserInteractive -or [Console]::IsInputRedirected) { return }
    Write-Host "`nmise modules (the base tools are always installed):"
    Show-MiseModules
    while ($true) {
        $answer = Read-Host "Modules to enable (space-separated, 'all', or Enter for none)"
        $names = @("$answer" -split '\s+' | Where-Object { $_ })
        if ($names.Count -eq 0) { return }
        try {
            if ($names -notcontains "all") { Assert-MiseModules $names }
        } catch {
            Write-Warning $_.Exception.Message
            continue
        }
        Enable-MiseModules $names
        return
    }
}

function Invoke-Mise([string[]]$MiseArgs) {
    $sub = if ($MiseArgs.Count -gt 0) { $MiseArgs[0] } else { "list" }
    $names = @($MiseArgs | Select-Object -Skip 1)
    switch ($sub) {
        "list"    { Show-MiseModules }
        "enable"  {
            if (-not $names) { throw "Usage: dotfiles.ps1 mise enable <module...|all>" }
            Enable-MiseModules $names
            mise install
            if ($names -contains "all") { $names = (Get-MiseModules).Name }
            Install-ModuleWindowsTools $names
        }
        "disable" {
            if (-not $names) { throw "Usage: dotfiles.ps1 mise disable <module...>" }
            Disable-MiseModules $names
        }
        default   { throw "Usage: dotfiles.ps1 mise <list|enable|disable> [module...]" }
    }
}

function Invoke-SystemUpdate {
    Write-Host "`nUpdating winget packages..."
    winget upgrade --all --accept-package-agreements --accept-source-agreements --disable-interactivity
    if (Get-Command scoop -ErrorAction SilentlyContinue) {
        Write-Host "Updating scoop packages..."
        scoop update *
    }
}

function Invoke-Update {
    # The global justfile's `update` recipe calls back into
    # `dotfiles.ps1 system-update` for winget/scoop
    if (-not (Get-Command just -ErrorAction SilentlyContinue)) {
        throw "just not found; run 'dotfiles.ps1 install' first (mise installs it)"
    }
    just --global-justfile update
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
}

function Invoke-Install {
    # -- PowerShell 7 ---------------------------------------------------------
    if (-not (Get-Command pwsh -ErrorAction SilentlyContinue)) {
        Write-Host "Installing PowerShell 7 via winget..."
        Install-Winget "Microsoft.PowerShell"
    } else {
        Write-Host "PowerShell 7 already installed, skipping."
    }

    # -- Winget packages (preferred where a reliable package exists) ---------
    Write-Host "`nInstalling packages via winget..."
    $wingetPackages = @(
        "JurgenRathlev.innounp",              # InnoSetup archive extraction (some winget/scoop deps need it)
        "Git.Git",
        "BrechtSanders.WinLibs.POSIX.UCRT",   # gcc + make + gdb + binutils toolchain (Treesitter parsers)
        "Neovim.Neovim",                      # needed early for bootstrapping, also mise-managed later
        "Gyan.FFmpeg",                        # yazi preview dependency
        "7zip.7zip",                          # yazi preview dependency
        "oschwartz10612.Poppler",             # yazi preview dependency
        "ImageMagick.ImageMagick",            # yazi preview dependency
        "DEVCOM.JetBrainsMonoNerdFont",
        "jdx.mise",
        "ZedIndustries.Zed"
    )
    foreach ($pkg in $wingetPackages) {
        Install-Winget $pkg
    }
    Initialize-YaziFileOne

    # -- Scoop (only for packages without a reliable winget equivalent) ------
    # zig:         winget's zig.zig has broken download URLs as of 2026
    # resvg:       not packaged for winget at all (upstream declined)
    # ghostscript: winget's ArtifexSoftware.GhostScript is stale (9.56.1 vs current 10.x)
    if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
        Write-Host "Installing Scoop (only needed for zig/resvg/ghostscript)..."
        Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
    }
    scoop install zig resvg ghostscript

    # -- Symlinks -------------------------------------------------------------
    Invoke-Link

    # -- Mise tools ---------------------------------------------------------------
    # winget (above) puts mise on PATH for new sessions only
    if (-not (Get-Command mise -ErrorAction SilentlyContinue)) {
        $env:PATH = [Environment]::GetEnvironmentVariable("PATH", "Machine") + ";" + [Environment]::GetEnvironmentVariable("PATH", "User")
    }
    if (-not (Get-Command mise -ErrorAction SilentlyContinue)) {
        throw "mise not found after installing jdx.mise with winget; open a new terminal and re-run 'dotfiles.ps1 install'"
    }
    Initialize-MiseDataDir

    $ghAuthenticated = $false
    if (Get-Command gh -ErrorAction SilentlyContinue) {
        gh auth status *> $null
        $ghAuthenticated = $LASTEXITCODE -eq 0
    }
    if (-not $ghAuthenticated) {
        Write-Host ""
        Write-Host "GitHub CLI is not authenticated (or not installed yet) - github: backend tools may be rate-limited."
        Write-Host "  Run 'gh auth login', then re-run 'mise install'."
        Write-Host ""
    }

    Request-MiseModules

    Write-Host "Installing mise tools (this may take a while)..."
    mise install  # base tools plus the enabled modules

    # Windows alternatives for the pipx tools (mise's pipx entries are
    # linux/macos only): `uv tool` (uv comes from mise) puts them on PATH,
    # unlike `pip install --user`. Enabled modules add theirs ($moduleUvTools).
    Write-Host "Installing Python CLI tools via uv..."
    foreach ($tool in @("yamllint", "posting")) {
        Invoke-Uv @("tool", "install", "--quiet", $tool)
    }
    Install-ModuleWindowsTools (Get-MiseModules | Where-Object Enabled | ForEach-Object { $_.Name })
    Invoke-Uv @("tool", "update-shell")

    # Python provider for Neovim (Ruby isn't installed on Windows, so no gem)
    $pythonPath = (mise which python)
    & $pythonPath -m pip install --user pynvim

    # -- GitHub CLI extensions ------------------------------------------------
    if (Get-Command gh -ErrorAction SilentlyContinue) {
        Write-Host "Installing gh extensions..."
        gh extension install dlvhdr/gh-dash 2>&1 | Out-Null
    }

    # -- PSFzf module (fzf integration for PowerShell) -----------------------
    Write-Host "Installing PSFzf module..."
    Install-Module -Name PSFzf -Scope CurrentUser -Force -SkipPublisherCheck -ErrorAction SilentlyContinue

    Write-Host "`nDone! Restart your terminal for changes to take effect."
}

# -- Pre-flight checks --------------------------------------------------------

$needsSymlinks = $Command -eq "install" -or $Command -eq "link" -or ($Command -eq "mise" -and $Rest -and $Rest[0] -eq "enable")
if ($needsSymlinks -and -not ((Test-DeveloperMode) -or (Test-IsAdmin))) {
    Write-Host "File symlinks require Developer Mode or Admin privileges. Elevating..."
    $shell = if (Get-Command pwsh.exe -ErrorAction SilentlyContinue) { "pwsh.exe" } else { "powershell.exe" }
    # Quote each argument (Windows command-line rules: backslashes before a
    # quote are doubled, the quote escaped)
    $quoted = foreach ($arg in @($PSCommandPath, $Command) + $Rest) {
        '"' + (($arg -replace '(\\*)"', '$1$1\"') -replace '(\\+)$', '$1$1') + '"'
    }
    $argList = "-NoProfile -ExecutionPolicy Bypass -File " + ($quoted -join ' ')
    # Start-Process doesn't set $LASTEXITCODE; take the exit code from the process
    $process = Start-Process $shell -Verb RunAs -Wait -PassThru -ArgumentList $argList
    exit $process.ExitCode
}

# -- Dispatch -----------------------------------------------------------------

switch ($Command) {
    "install"       { Invoke-Install }
    "update"        { Invoke-Update }
    "system-update" { Invoke-SystemUpdate }
    "link"          { Invoke-Link }
    "unlink"        { Invoke-Unlink }
    "check-links"   { if (-not (Invoke-CheckLinks)) { exit 1 } }
    "mise"          { Invoke-Mise $Rest }
}
