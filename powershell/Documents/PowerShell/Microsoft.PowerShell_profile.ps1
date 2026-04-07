# PowerShell profile
# Mirrors fish shell configuration for Windows parity

# ── mise (must be first so shims are available to everything else) ──────────
if (Get-Command mise -ErrorAction SilentlyContinue) {
    (mise activate pwsh) | Out-String | Invoke-Expression
}

# ── Starship prompt ────────────────────────────────────────────────────────
if (Get-Command starship -ErrorAction SilentlyContinue) {
    (& starship init powershell) | Out-String | Invoke-Expression
}

# ── Zoxide (smart cd) ─────────────────────────────────────────────────────
if (Get-Command zoxide -ErrorAction SilentlyContinue) {
    Invoke-Expression (& { (zoxide init --cmd z powershell | Out-String) })
}

# ── Direnv ─────────────────────────────────────────────────────────────────
if (Get-Command direnv -ErrorAction SilentlyContinue) {
    Invoke-Expression (& { (direnv hook pwsh | Out-String) })
}

# ── Carapace completions ──────────────────────────────────────────────────
if (Get-Command carapace -ErrorAction SilentlyContinue) {
    $env:CARAPACE_BRIDGES = 'zsh,fish,bash,inshellisense'
    $env:CARAPACE_MATCH = '1'
    carapace _carapace powershell | Out-String | Invoke-Expression
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

    # PSFzf module integration (if installed)
    if (Get-Module -ListAvailable -Name PSFzf) {
        Import-Module PSFzf
        Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'
    }
}

# ── Environment ───────────────────────────────────────────────────────────
$env:JUST_GLOBAL_JUSTFILE = "$HOME\.config\just\justfile"

# ── Aliases ───────────────────────────────────────────────────────────────
# eza (modern ls replacement)
if (Get-Command eza -ErrorAction SilentlyContinue) {
    function l { eza --color=always --git --icons=always --group-directories-first @args }
    function ll { eza --color=always --git --icons=always --group-directories-first --long --header --time-style=relative @args }
    function la { eza --color=always --git --icons=always --group-directories-first --long --all --header --time-style=relative @args }
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

# Kubernetes
Set-Alias -Name k -Value kubectl

# Yazi
if (Get-Command yazi -ErrorAction SilentlyContinue) {
    Set-Alias -Name y -Value yazi
}

# Clear
Set-Alias -Name cl -Value Clear-Host

# ── Functions ─────────────────────────────────────────────────────────────
# Smart just: local justfile or global
function j {
    if (Test-Path justfile) {
        just @args
    } else {
        just --global-justfile @args
    }
}

# Create directory and cd into it
function mkcd {
    param([string]$Path)
    New-Item -ItemType Directory -Force -Path $Path | Out-Null
    Set-Location $Path
}

# AI assistant wrapper
function ai {
    $assistant = if ($env:AI_ASSISTANT) { $env:AI_ASSISTANT } else { "opencode" }
    & $assistant @args
}
