# PowerShell profile
# Mirrors fish shell configuration for Windows parity

# ── PSReadLine ────────────────────────────────────────────────────────────
if (-not (Get-Module PSReadLine)) {
    Import-Module PSReadLine
}

# Vi editing, like fish (conf.d/z_vi_mode.fish) and zsh (zsh-vi-mode).
# Must come before any Set-PSReadLineKeyHandler: switching EditMode resets
# the key bindings. The cursor shape shows the mode (bar = insert, block = normal).
Set-PSReadLineOption -EditMode Vi -ViModeIndicator Cursor

# History filter — same rules as fish's fish_should_add_to_history: skip
# commands with a leading space, and keep secret-looking ones out of the
# history file (still recallable in this session, as in fish).
Set-PSReadLineOption -AddToHistoryHandler {
    param([string]$line)
    if ($line -match '^\s') { return [Microsoft.PowerShell.AddToHistoryOption]::MemoryOnly }
    $secret = '(password|passwd|token|secret|api[_-]?key)'
    # Variable names: the keyword must end the name or a _-separated part of
    # it (GH_TOKEN, DB_PASSWORD_FILE), so TOKENIZERS_PARALLELISM is kept
    $secretVar = "\w*$secret(_\w*)?"
    if ($line -match "^(curl|wget|iwr|irm|Invoke-WebRequest|Invoke-RestMethod)\s.*$secret" -or
        $line -match "^(\`$env:|export\s+|set\s+(-\w+\s+)*)$secretVar[\s=]" -or
        $line -match "(^|\s)$secretVar=") {
        return [Microsoft.PowerShell.AddToHistoryOption]::MemoryOnly
    }
    # PSReadLine's own rule (e.g. ConvertTo-SecureString -AsPlainText)
    return [Microsoft.PowerShell.PSConsoleReadLine]::GetDefaultAddToHistoryOption($line)
}

# ── Cached init scripts (regenerate with: Remove-Item ~/.cache/pwsh-init/) ─
$_cacheDir = "$HOME\.cache\pwsh-init"
$_cacheMaxAge = [TimeSpan]::FromDays(7)
if (-not (Test-Path $_cacheDir)) { New-Item -ItemType Directory -Force -Path $_cacheDir | Out-Null }

function _load_cached {
    param([string]$Name, [scriptblock]$Generator, [string]$DependencyPath)
    $cacheFile = Join-Path $script:_cacheDir "$Name.ps1"
    $dependencyFile = Join-Path $script:_cacheDir "$Name.source"
    $dependencyState = if ($DependencyPath) {
        $dependency = Get-Item -LiteralPath $DependencyPath -ErrorAction SilentlyContinue
        if ($dependency) { "$($dependency.FullName)|$($dependency.Length)|$($dependency.LastWriteTimeUtc.Ticks)" }
    }
    $stale = $true
    if (Test-Path $cacheFile) {
        $stale = ((Get-Date) - (Get-Item $cacheFile).LastWriteTime) -gt $script:_cacheMaxAge
        if (-not $stale -and $dependencyState) {
            $cachedDependency = if (Test-Path -LiteralPath $dependencyFile) {
                (Get-Content -Raw -LiteralPath $dependencyFile).Trim()
            }
            $stale = $cachedDependency -ne $dependencyState
        }
        # Init scripts bake in the version-pinned path of the mise binary that
        # generated them; a mise upgrade can delete it before the TTL expires.
        if (-not $stale) {
            foreach ($m in [regex]::Matches((Get-Content -Raw $cacheFile), '[A-Za-z]:\\[^''"\r\n]*?mise\\installs\\[^''"\r\n]*?\.exe')) {
                if (-not (Test-Path -LiteralPath $m.Value)) { $stale = $true; break }
            }
        }
    }
    if ($stale) {
        # Never cache failed/empty output: it would stick for the whole TTL
        $global:LASTEXITCODE = 0
        $out = try { & $Generator 2>$null | Out-String } catch { '' }
        if ($LASTEXITCODE -eq 0 -and "$out".Trim()) {
            Set-Content -Path $cacheFile -Value $out
            if ($dependencyState) { Set-Content -LiteralPath $dependencyFile -Value $dependencyState }
        } elseif (-not (Test-Path $cacheFile)) {
            return
        }
    }
    . $cacheFile
}

function Get-MiseProjectConfig {
    if ((Get-Location).Provider.Name -ne 'FileSystem') { return @() }
    if ((Get-Location).ProviderPath.StartsWith('\\')) { return @() }
    $names = @(
        'mise.toml', '.mise.toml', 'mise.local.toml', '.mise.local.toml',
        'mise.windows.toml', '.mise.windows.toml', '.tool-versions',
        '.node-version', '.python-version', '.ruby-version', '.go-version', '.java-version',
        '.terraform-version', '.nvmrc'
    )
    $found = [Collections.Generic.List[string]]::new()
    $directory = (Get-Location).ProviderPath
    while ($directory) {
        foreach ($name in $names) {
            $path = Join-Path $directory $name
            if (Test-Path -LiteralPath $path -PathType Leaf) { $found.Add($path) }
        }
        $parent = Split-Path -Parent $directory
        if (-not $parent -or $parent -eq $directory) { break }
        $directory = $parent
    }
    return $found.ToArray()
}

function Get-MiseEnvironmentFingerprint {
    param([string]$MisePath, [string]$BasePath)

    $state = [Collections.Generic.List[string]]::new()
    $miseItem = Get-Item -LiteralPath $MisePath
    $state.Add("mise|$($miseItem.FullName)|$($miseItem.Length)|$($miseItem.LastWriteTimeUtc.Ticks)")
    $state.Add("path|$BasePath")
    foreach ($name in @(
        'MISE_ENV', 'MISE_DATA_DIR', 'MISE_CONFIG_DIR', 'MISE_CONFIG_FILE',
        'MISE_DEFAULT_CONFIG_FILENAME', 'MISE_OVERRIDE_CONFIG_FILENAMES', 'MISE_TRUSTED_CONFIG_PATHS'
    )) {
        $state.Add("env|$name|$([Environment]::GetEnvironmentVariable($name))")
    }

    $configRoot = Join-Path $HOME '.config\mise'
    if (Test-Path -LiteralPath $configRoot -PathType Container) {
        Get-ChildItem -LiteralPath $configRoot -File -Recurse -Force |
            Sort-Object FullName |
            ForEach-Object { $state.Add("config|$($_.FullName)|$($_.Length)|$($_.LastWriteTimeUtc.Ticks)") }
    }

    $installsRoot = Join-Path $env:MISE_DATA_DIR 'installs'
    if (Test-Path -LiteralPath $installsRoot -PathType Container) {
        Get-ChildItem -LiteralPath $installsRoot -Directory -Depth 1 -Force |
            Sort-Object FullName |
            ForEach-Object { $state.Add("install|$($_.FullName)|$($_.LastWriteTimeUtc.Ticks)") }
    }

    $bytes = [Text.Encoding]::UTF8.GetBytes([string]::Join("`n", $state))
    return [Convert]::ToHexString([Security.Cryptography.SHA256]::HashData($bytes))
}

function Get-MiseProjectState {
    $state = foreach ($path in Get-MiseProjectConfig) {
        $item = Get-Item -LiteralPath $path
        "$($item.FullName)|$($item.Length)|$($item.LastWriteTimeUtc.Ticks)"
    }
    return [string]::Join("`n", [string[]]@($state))
}

function Get-MiseGlobalConfigState {
    $configRoot = Join-Path $HOME '.config\mise'
    if (-not (Test-Path -LiteralPath $configRoot -PathType Container)) { return '' }
    $state = Get-ChildItem -LiteralPath $configRoot -File -Recurse -Force |
        Sort-Object FullName |
        ForEach-Object { "$($_.FullName)|$($_.Length)|$($_.LastWriteTimeUtc.Ticks)" }
    return [string]::Join("`n", [string[]]@($state))
}

function Update-MiseEnvironment {
    $projectState = Get-MiseProjectState
    $now = [Environment]::TickCount64
    $globalChanged = $false
    if ($now - $Global:__mise_global_checked_at -ge 10000) {
        $globalState = Get-MiseGlobalConfigState
        $globalChanged = $globalState -ne $Global:__mise_global_config_state
        $Global:__mise_global_config_state = $globalState
        $Global:__mise_global_checked_at = $now
    }
    if ($projectState -ne $Global:__mise_project_state -or $globalChanged) {
        _mise_hook
        $Global:__mise_project_state = Get-MiseProjectState
    }
}

function Initialize-MiseEnvironment {
    param([string]$MisePath, [string]$BasePath)

    $projectConfig = @(Get-MiseProjectConfig)
    if ($projectConfig.Count -gt 0) {
        $output = & $MisePath hook-env --force -s pwsh | Out-String
        if ($LASTEXITCODE -ne 0 -or -not $output.Trim()) {
            throw "mise failed to initialize the project environment"
        }
        Invoke-Expression $output
        return
    }

    $cacheFile = Join-Path $script:_cacheDir 'mise-env.ps1'
    $fingerprintFile = Join-Path $script:_cacheDir 'mise-env.sha256'
    $fingerprint = Get-MiseEnvironmentFingerprint $MisePath $BasePath
    $cachedFingerprint = if (Test-Path -LiteralPath $fingerprintFile) {
        (Get-Content -Raw -LiteralPath $fingerprintFile).Trim()
    }

    if (-not (Test-Path -LiteralPath $cacheFile -PathType Leaf) -or $cachedFingerprint -ne $fingerprint) {
        $output = & $MisePath hook-env --force -s pwsh | Out-String
        if ($LASTEXITCODE -ne 0 -or -not $output.Trim()) {
            throw "mise failed to refresh the cached environment"
        }
        Set-Content -LiteralPath "$cacheFile.$PID" -Value $output
        [IO.File]::Move("$cacheFile.$PID", $cacheFile, $true)
        Set-Content -LiteralPath "$fingerprintFile.$PID" -Value $fingerprint
        [IO.File]::Move("$fingerprintFile.$PID", $fingerprintFile, $true)
    }

    . $cacheFile
}

# ── mise ──────────────────────────────────────────────────────────────────
# MISE_ENV=windows loads mise/config.windows.toml on top of the shared config.toml.
$env:MISE_DATA_DIR = "C:\mise"
$env:MISE_ENV = "windows"

$miseCommand = Get-Command mise -All -ErrorAction SilentlyContinue |
    Where-Object CommandType -eq 'Application' |
    Select-Object -First 1
if ($miseCommand) {
    $miseRoot = [IO.Path]::GetFullPath($env:MISE_DATA_DIR).TrimEnd('\')
    $miseBasePath = (($env:PATH -split ';' | Where-Object {
        $_ -and
        -not [IO.Path]::GetFullPath($_).StartsWith("$miseRoot\installs\", [StringComparison]::OrdinalIgnoreCase) -and
        -not [IO.Path]::GetFullPath($_).Equals("$miseRoot\shims", [StringComparison]::OrdinalIgnoreCase)
    } | Select-Object -Unique) -join ';')
    $env:PATH = $miseBasePath
    # Keep mise's command wrapper and install-on-demand support, but replace its
    # per-prompt/per-cd hooks with the context-aware checks below.
    _load_cached "mise-activate-direct-env-v3" {
        $skipHook = $false
        & $miseCommand.Source activate pwsh | ForEach-Object {
            if ($_ -match '^function __enable_mise_(chpwd|prompt)') { $skipHook = $true }
            if (-not $skipHook -and $_ -notmatch '^\$\{Env:Path\}=' -and $_ -ne '_mise_hook') {
                $_ -replace '^function mise \{', 'function Global:mise {'
            }
            if ($skipHook -and $_ -match '^Remove-Item .*Function:/__enable_mise_(chpwd|prompt)') {
                $skipHook = $false
            }
        }
    } $miseCommand.Source
    Initialize-MiseEnvironment $miseCommand.Source $miseBasePath
    $Global:__mise_project_state = Get-MiseProjectState
    $Global:__mise_global_config_state = Get-MiseGlobalConfigState
    $Global:__mise_global_checked_at = [Environment]::TickCount64
    if (-not $Global:__mise_location_hooked) {
        $Global:__mise_location_hooked = $true
        $miseLocationHook = [EventHandler[Management.Automation.LocationChangedEventArgs]] {
            param([object]$Source, [Management.Automation.LocationChangedEventArgs]$EventArgs)
            end { Update-MiseEnvironment }
        }
        $previousLocationHook = $ExecutionContext.SessionState.InvokeCommand.LocationChangedAction
        $ExecutionContext.SessionState.InvokeCommand.LocationChangedAction = if ($previousLocationHook) {
            [Delegate]::Combine($previousLocationHook, $miseLocationHook)
        } else {
            $miseLocationHook
        }
    }
}

# ── Starship prompt ────────────────────────────────────────────────────────
if ($Global:__mise_prompt_hooked -and $Global:__mise_previous_prompt) {
    $function:global:prompt = $Global:__mise_previous_prompt
    $Global:__mise_prompt_hooked = $false
}
$starshipCommand = Get-Command starship -ErrorAction SilentlyContinue
if ($starshipCommand) {
    _load_cached "starship" { & starship init powershell --print-full-init } $starshipCommand.Source
}

# ── Zoxide (smart cd) ─────────────────────────────────────────────────────
$zoxideCommand = Get-Command zoxide -ErrorAction SilentlyContinue
if ($zoxideCommand) {
    $Global:__zoxide_hooked = 0
    _load_cached "zoxide" { zoxide init --cmd z powershell } $zoxideCommand.Source
}

if ($miseCommand) {
    $Global:__mise_previous_prompt = $function:prompt
    $Global:__mise_prompt_hooked = $true
    function global:prompt {
        Update-MiseEnvironment
        & $Global:__mise_previous_prompt
    }
}

# ── Native completions (cached, in-process — no external spawn per tab) ───
$_nativeCompletionTools = @(
    @{ Name = 'docker';    Cmd = 'docker';    Gen = { docker completion powershell } }
    @{ Name = 'kubectl';   Cmd = 'kubectl';   Gen = { kubectl completion powershell } }
    @{ Name = 'gh';        Cmd = 'gh';        Gen = { gh completion -s powershell } }
    @{ Name = 'mise-completion'; Cmd = 'mise'; Gen = { mise completion powershell } }
    @{ Name = 'just-static'; Cmd = 'just'; Gen = {
        $previous = $env:JUST_COMPLETE
        try {
            $env:JUST_COMPLETE = 'powershell'
            just
        } finally {
            if ($null -eq $previous) { Remove-Item Env:\JUST_COMPLETE } else { $env:JUST_COMPLETE = $previous }
        }
    } }
)
foreach ($tool in $_nativeCompletionTools) {
    $command = Get-Command $tool.Cmd -ErrorAction SilentlyContinue
    if ($command) {
        _load_cached $tool.Name $tool.Gen $command.Source
    }
}

# Carapace fallback for remaining commands (spawns process per tab press)
if (Get-Command carapace -ErrorAction SilentlyContinue) {
    $env:CARAPACE_MATCH = '1'
    $_carapace_completer = {
        param($wordToComplete, $commandAst, $cursorPosition)
        $elems = @()
        foreach ($el in $commandAst.CommandElements) {
            if ($el.Extent.StartOffset -gt $cursorPosition) { break }
            $t = $el.Extent.Text
            if ($el.Extent.EndOffset -gt $cursorPosition) {
                $t = $t.Substring(0, $t.Length - ($el.Extent.EndOffset - $cursorPosition))
            }
            $t = $t.Trim("'")
            if ($t.Length -eq 0) { $t = '""' }
            $elems += $t.Replace('`,', ',')
        }
        $cmd = ($elems[0] -replace '\.exe$', '')
        $args_list = if ($wordToComplete) { $elems } else { $elems + @('') }
        $result = carapace $cmd powershell @args_list 2>$null
        if ($result) {
            $result | ConvertFrom-Json | ForEach-Object {
                [System.Management.Automation.CompletionResult]::new(
                    $_.CompletionText, $_.ListItemText, 'ParameterValue', $_.ToolTip)
            }
        }
    }
    # Only use carapace for tools without native completions
    $carapaceFallback = @(
        'cargo','cargo.exe','go','go.exe','npm','npm.exe',
        'az','az.exe','terraform','terraform.exe','helm','helm.exe'
    )
    Register-ArgumentCompleter -Native -CommandName $carapaceFallback -ScriptBlock $_carapace_completer
}

# ── fzf ───────────────────────────────────────────────────────────────────
if (Get-Command fzf -ErrorAction SilentlyContinue) {
    # Catppuccin Mocha colour theme
    $env:FZF_DEFAULT_OPTS = @"
--color=bg+:#313244,bg:#11111b,spinner:#f5e0dc,hl:#f38ba8
--color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc
--color=marker:#b4befe,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8
--color=selected-bg:#45475a
--color=border:#6c7086,label:#cdd6f4
--border=rounded --border-label='' --preview-window=border-rounded:right:60%:wrap
--height=80%
--prompt='> ' --marker='-' --pointer='@' --separator='-' --scrollbar='|' --layout=reverse
"@

    if (Get-Command fd -ErrorAction SilentlyContinue) {
        $env:FZF_DEFAULT_COMMAND = 'fd --hidden --strip-cwd-prefix --exclude .git'
        $env:FZF_ALT_C_COMMAND = 'fd --type d --hidden --strip-cwd-prefix --exclude .git'
        $env:FZF_CTRL_T_COMMAND = $env:FZF_DEFAULT_COMMAND
    }

    # PSFzf: lazy-load on first use, then run the requested action immediately.
    $__psfzf_lazy = {
        Import-Module PSFzf
        Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r' -PSReadlineChordSetLocation 'Alt+c'
    }
    Set-PSReadLineKeyHandler -Key 'Ctrl+t' -ScriptBlock {
        & $__psfzf_lazy
        & (Get-Module PSFzf) { Invoke-FzfPsReadlineHandlerProvider }
    }
    Set-PSReadLineKeyHandler -Key 'Ctrl+r' -ScriptBlock {
        & $__psfzf_lazy
        & (Get-Module PSFzf) { Invoke-FzfPsReadlineHandlerHistory }
    }
    Set-PSReadLineKeyHandler -Key 'Alt+c' -ScriptBlock {
        & $__psfzf_lazy
        & (Get-Module PSFzf) { Invoke-FzfPsReadlineHandlerSetLocation }
    }
}

# ── Environment ───────────────────────────────────────────────────────────
$env:JUST_GLOBAL_JUSTFILE = "$HOME\.config\just\justfile"
$env:EDITOR = 'nvim'
$env:VISUAL = 'nvim'
# eza theme (catppuccin), stowed to ~/.config/eza like on macOS/Linux; eza on
# Windows would otherwise look in %APPDATA%\eza
if (Test-Path "$HOME\.config\eza") {
    $env:EZA_CONFIG_DIR = "$HOME\.config\eza"
}
# (XDG_CONFIG_HOME is deliberately not set: Neovim and others honour it on
# Windows too and would stop finding their %LOCALAPPDATA% config.)

# ── Aliases ───────────────────────────────────────────────────────────────
# eza (modern ls replacement)
if (Get-Command eza -ErrorAction SilentlyContinue) {
    function l { eza --color=auto --git --icons=auto --group-directories-first @args }
    function ll { eza --color=auto --git --icons=auto --group-directories-first --long --header --time-style=relative @args }
    function la { eza --color=auto --git --icons=auto --group-directories-first --long --all --header --time-style=relative @args }
    function tree { eza --tree --icons=always @args }
    function lt { eza --tree --level=2 --icons=always @args }
}

# Editors
Set-Alias -Name vim -Value nvim
Set-Alias -Name vi -Value nvim
Set-Alias -Name v -Value nvim
Set-Alias -Name n -Value nvim

# Git
Set-Alias -Name g -Value git

# Docker
Set-Alias -Name d -Value docker

# Kubernetes
Set-Alias -Name k -Value kubectl

# Yazi
if (Get-Command yazi -ErrorAction SilentlyContinue) {
    function y {
        $tmp = (New-TemporaryFile).FullName
        $exitCode = 1
        try {
            yazi.exe @args "--cwd-file=$tmp"
            $exitCode = $LASTEXITCODE
            $cwd = Get-Content -LiteralPath $tmp -Encoding UTF8 -ErrorAction SilentlyContinue | Select-Object -First 1
            if ($cwd -and $cwd -ne $PWD.Path -and (Test-Path -LiteralPath $cwd -PathType Container)) {
                Set-Location -LiteralPath $cwd
            }
        } finally {
            Remove-Item -LiteralPath $tmp -Force -ErrorAction SilentlyContinue
        }
        $global:LASTEXITCODE = $exitCode
    }
}

# Clear
Set-Alias -Name cl -Value Clear-Host

# Ask before removing or overwriting files, like fish's and zsh's rm -i,
# cp -i, mv -i. The built-in rm/cp/mv aliases would shadow the functions.
foreach ($_a in 'rm', 'cp', 'mv') {
    if (Test-Path "Alias:$_a") { Remove-Item "Alias:$_a" -Force }
}
# rm: confirm every item
function rm { Remove-Item @args -Confirm }

# cp/mv: confirm only when the destination (or, for a directory destination,
# the item of the same name inside it) already exists
function _copy_or_move {
    param([string]$Cmdlet, [string[]]$Path, [string]$Destination, [switch]$Recurse)
    foreach ($item in (Resolve-Path -Path $Path -ErrorAction Stop)) {
        $target = $Destination
        if (Test-Path -LiteralPath $Destination -PathType Container) {
            $target = Join-Path $Destination (Split-Path -Leaf $item.ProviderPath)
        }
        $opts = @{ LiteralPath = $item.ProviderPath; Destination = $Destination }
        if ($Recurse) { $opts.Recurse = $true }
        if (Test-Path -LiteralPath $target) {
            if ((Read-Host "overwrite '$target'? [y/N]") -notmatch '^[yY]') { continue }
            $opts.Force = $true
        }
        & $Cmdlet @opts
    }
}
function cp {
    param([Parameter(Mandatory, Position = 0)][string[]]$Path,
          [Parameter(Mandatory, Position = 1)][string]$Destination,
          [switch]$Recurse)
    _copy_or_move Copy-Item $Path $Destination -Recurse:$Recurse
}
function mv {
    param([Parameter(Mandatory, Position = 0)][string[]]$Path,
          [Parameter(Mandatory, Position = 1)][string]$Destination)
    _copy_or_move Move-Item $Path $Destination
}

# ── Functions ─────────────────────────────────────────────────────────────
# Smart just: the nearest justfile (here or in a parent dir), else the
# global one — same as fish's and zsh's j
function j {
    just --summary *> $null
    if ($LASTEXITCODE -eq 0) {
        just @args
    } else {
        just --global-justfile @args
    }
}

# Just global shortcut
function jg { just --global-justfile @args }

# Create directory and cd into it
function mkcd {
    param([string]$Path)
    New-Item -ItemType Directory -Force -Path $Path | Out-Null
    Set-Location $Path
}

# Extract archives (same as fish's extract). Windows' bundled tar is bsdtar
# (libarchive), which also reads zip, 7z and rar.
function extract {
    param([string]$Path)
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        Write-Host "'$Path' is not a valid file"
        return
    }
    $sevenZip = Get-Command 7z, 7zz, 7za -ErrorAction SilentlyContinue | Select-Object -First 1
    switch -Wildcard ($Path) {
        { $_ -like '*.tar.bz2' -or $_ -like '*.tar.gz' -or $_ -like '*.tar' -or
          $_ -like '*.tbz2' -or $_ -like '*.tgz' } { tar -xf $Path; break }
        '*.zip' { Expand-Archive -LiteralPath $Path -DestinationPath . ; break }
        { $_ -like '*.7z' -or $_ -like '*.rar' -or $_ -like '*.gz' -or $_ -like '*.bz2' } {
            if ($sevenZip) { & $sevenZip x $Path } else { tar -xf $Path }
            break
        }
        default { Write-Host "'$Path' cannot be extracted via extract()" }
    }
}

# Git shorthand (same as fish's conf.d/functions.fish). Functions, since
# aliases can't take arguments; PowerShell's built-in gcm/gp/gl/gcb aliases
# (Get-Command, Get-ItemProperty, Get-Location, Get-Clipboard) would shadow
# them, so they're removed.
foreach ($_a in 'gcm', 'gp', 'gl', 'gcb') {
    if (Test-Path "Alias:$_a") { Remove-Item "Alias:$_a" -Force }
}
function gst { git status }
function gco { git checkout @args }
function gcb { git checkout -b @args }
function gaa { git add --all }
function gcm { git commit -m "$args" }
function gp { git push }
function gl { git pull }
function glog { git log --oneline --decorate --graph }

# AI assistant wrapper; AI_ASSISTANT may include arguments ("claude --foo")
function ai {
    $assistant = if ($env:AI_ASSISTANT) { $env:AI_ASSISTANT } else { "opencode" }
    $cmd, $cmdArgs = -split $assistant
    & $cmd @cmdArgs @args
}
