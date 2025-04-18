# zmodload zsh/zprof

# Ensure /usr/local/bin is in PATH (after our own tools)
export PATH="$PATH:/usr/local/bin"

# Add ~/.local/bin to PATH for user-installed binaries
export PATH="$HOME/.local/bin:$PATH"

# Handle Ghostty terminal - fallback if terminfo not available
if [[ "$TERM" == "xterm-ghostty" ]]; then
    if ! infocmp "$TERM" &>/dev/null 2>&1; then
        export TERM=xterm-256color
    fi
fi

# Vi mode is handled by zsh-vi-mode (loaded via zinit below)

# History
HISTSIZE=5000
HISTFILE=$HOME/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUPE=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_dups
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_find_no_dups
setopt hist_verify

# Filter commands from history (mirrors fish/sponge patterns + extras)
zshaddhistory() {
  local line="${1%%$'\n'}"
  # Blank lines and single-char commands
  [[ ${#line} -le 1 ]] && return 1
  # cd / zoxide navigation (context-dependent, not useful to replay)
  [[ "$line" =~ '^(cd|z)( .*)?$' ]] && return 1
  # Short noisy commands (including l alias for eza)
  [[ "$line" =~ '^(ls|l|ll|la|lt|tree|eza|pwd|clear|exit|history)( .*)?$' ]] && return 1
  # Force commands (mirrors sponge pattern + shorthand -f)
  [[ "$line" =~ '^git (push|pull)( .*)?(--force|-f)( .*)?$' ]] && return 1
  # curl/wget with sensitive data in args (mirrors sponge pattern)
  [[ "$line" =~ '^(curl|wget) .*(password|token|secret|key)' ]] && return 1
  # Env var assignments containing sensitive names
  [[ "$line" =~ '(^| )(PASSWORD|TOKEN|SECRET|KEY|PASS)[^ ]*=' ]] && return 1
  return 0
}

# Options
# setopt correct
setopt nocaseglob
setopt nobeep
setopt autocd
setopt prompt_subst # reevaluate prompt on each command

# Theme
if [[ -s $HOME/.ztheme ]]; then
  source $HOME/.ztheme
fi

# colours
autoload -U colors && colors

# fpath additions — must come before compinit
if test -d "${HOME}/.docker/completions"; then
  fpath=("${HOME}/.docker/completions" $fpath)
fi



# Completion — must be initialized before zinit loads fzf-tab
autoload -U compinit && compinit -C

# GitHub CLI completions — must be after compinit (uses compdef)
if command -v gh >/dev/null 2>&1; then
  eval "$(gh completion -s zsh)"
fi
ZINIT_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/zinit/zinit.git"
# Download zinit if it doesn't exist
if [ ! -d "${ZINIT_HOME}" ]; then
  echo "Installing zinit"
  mkdir -p "${ZINIT_HOME}"
  git clone --depth=1 https://github.com/zdharma-continuum/zinit.git "${ZINIT_HOME}"
fi

source "${ZINIT_HOME}/zinit.zsh"
# Zsh plugins
# zinit light Aloxaf/fzf-tab  # Removed: using native fzf completion instead
zinit light zsh-users/zsh-history-substring-search
zinit light zsh-users/zsh-autosuggestions
zinit light zdharma-continuum/fast-syntax-highlighting
# zsh-vi-mode — must load after history-substring-search
# All bindings that zvm would clobber must be re-applied in zvm_after_init
zinit light jeffreytse/zsh-vi-mode

zvm_after_init() {
  # Restore history-substring-search arrow bindings clobbered by zvm
  zmodload zsh/terminfo
  bindkey "$terminfo[kcuu1]" history-substring-search-up
  bindkey "$terminfo[kcud1]" history-substring-search-down
  bindkey '^[[A' history-substring-search-up
  bindkey '^[OA' history-substring-search-up
  bindkey '^[[B' history-substring-search-down
  bindkey '^[OB' history-substring-search-down
  bindkey -M vicmd '^[[A' history-substring-search-up
  bindkey -M vicmd '^[OA' history-substring-search-up
  bindkey -M vicmd '^[[B' history-substring-search-down
  bindkey -M vicmd '^[OB' history-substring-search-down
  bindkey -M viins '^[[A' history-substring-search-up
  bindkey -M viins '^[OA' history-substring-search-up
  bindkey -M viins '^[[B' history-substring-search-down
  bindkey -M viins '^[OB' history-substring-search-down
  # Ctrl-P / Ctrl-N history search (insert mode)
  bindkey -M viins '^p' history-search-backward
  bindkey -M viins '^n' history-search-forward
  # Open command line in $EDITOR (Ctrl-X Ctrl-E, mirrors fish's Alt-E)
  autoload -Uz edit-command-line
  zle -N edit-command-line
  bindkey -M viins '^x^e' edit-command-line
  bindkey -M vicmd '^x^e' edit-command-line
  # Restore fzf key bindings clobbered by zvm
  # Re-source fzf integration to ensure widgets are loaded
  if command -v fzf >/dev/null 2>&1; then
    source <(fzf --zsh)
    bindkey '\e[Z' fzf-completion        # Shift-Tab = fzf completion
    bindkey '^I' $fzf_default_completion  # Tab = native zsh completion
  fi
}
# Snippets
zinit snippet OMZP::git
zinit snippet OMZP::command-not-found
zinit snippet OMZP::colored-man-pages
zinit snippet OMZP::common-aliases

# Carapace multi-shell completions
if command -v carapace >/dev/null 2>&1; then
  export CARAPACE_BRIDGES='zsh,fish,bash,inshellisense'
  export CARAPACE_MATCH=1
  zstyle ':completion:*' format $'\e[2;37mCompleting %d\e[m'
  source <(carapace _carapace)
fi

# Completion styles
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' rehash true
zstyle ':completion:*' menu yes select



# Native fzf completion (replaces fzf-tab plugin)
# Configure FZF completion environment variables to match fish behavior
export FZF_COMPLETION_TRIGGER=''  # Disable ** trigger, use key binding instead
export FZF_COMPLETION_OPTS='--border=rounded --border-label="" --preview-window=border-rounded:right:60%:wrap --height=80%'
export FZF_COMPLETION_DIR_COMMANDS='cd pushd rmdir z zi __zoxide_z'

# Configure preview commands for path and directory completions
export FZF_COMPLETION_PATH_OPTS="--preview 'if [[ -d {} ]]; then eza --color=always --icons=always --group-directories-first --all {} 2>/dev/null || ls -la {}; elif [[ -f {} ]]; then bat --color=always --style=numbers --line-range=:100 {} 2>/dev/null || head -20 {}; else echo \"Not found: {}\"; fi'"
export FZF_COMPLETION_DIR_OPTS="--preview 'eza --color=always --icons=always --group-directories-first --all {} 2>/dev/null || ls -la {}'"

# Mise
if command -v mise >/dev/null 2>&1; then
  eval "$(mise activate zsh)"
fi

# Direnv only if it's installed
if command -v direnv >/dev/null 2>&1; then
  eval "$(direnv hook zsh)"
fi

# Fzf
if command -v fzf >/dev/null 2>&1; then
  source <(fzf --zsh)
  # Shift-Tab triggers fzf completion; Tab uses native zsh completion
  bindkey '\e[Z' fzf-completion        # Shift-Tab = fzf completion
  bindkey '^I' $fzf_default_completion  # Tab = native zsh completion
  export FZF_DEFAULT_OPTS=$FZF_DEFAULT_OPTS'
  --with-shell="bash -c"
  --color=bg+:#313244,bg:#11111b,spinner:#f5e0dc,hl:#f38ba8
  --color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc
  --color=marker:#b4befe,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8
  --color=selected-bg:#45475a
  --color=border:#6c7086,label:#cdd6f4
  --border="rounded" --border-label="" --preview-window="border-rounded:right:60%:wrap"
  --height=80%
  --prompt="> " --marker="-" --pointer="◆"
  --separator="-" --scrollbar="|" --layout="reverse"'
  if command -v fd >/dev/null 2>&1; then
    export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git"
  fi
  if command -v eza >/dev/null 2>&1 && command -v bat >/dev/null 2>&1; then
    show_file_or_dir_preview="if [[ -d {} ]]; then eza --tree --color=always {} | head -200; else bat -n --color=always --line-range :500 {}; fi"
    export FZF_CTRL_T_OPTS="--preview '$show_file_or_dir_preview' \
                            --height 60% \
                            --border sharp \
                            --layout reverse \
                            --prompt '∷ ' \
                            --pointer ▶ \
                            --marker ⇒"
  fi
  source ~/.local/share/fzf-git/fzf-git.sh 2>/dev/null || true
fi

_fzf_comprun() {
  local command=$1
  shift

  case "$command" in
    cd)           fzf --preview 'eza --tree --color=always --icons=always {} | head -200' --preview-window=right:50%:wrap "$@" ;;
    export|unset) fzf --preview 'eval echo ${}' --preview-window=right:50%:wrap "$@" ;;
    ssh)          fzf --preview 'dig +short {}' --preview-window=right:50%:wrap "$@" ;;
    *)            fzf --preview "$show_file_or_dir_preview" --preview-window=right:50%:wrap "$@" ;;
  esac
}

_fzf_compgen_path() {
  fd --hidden --exclude .git  . "$1" 
}

_fzf_compgen_dir() {
  fd --type d --hidden --exclude .git . "$1"
}

if command -v bat >/dev/null 2>&1; then
  export BAT_THEME="Catppuccin Mocha"
fi


# Machine-local env vars (not tracked in dotfiles)
if [ -f "$HOME/.env.local" ]; then
  source "$HOME/.env.local"
fi
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init --cmd z zsh)"
fi

if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi

if command -v yazi >/dev/null 2>&1; then
  alias y="yazi"
fi

if command -v just >/dev/null 2>&1; then
  export JUST_GLOBAL_JUSTFILE="$HOME/.config/just/justfile"
  
  # Smart wrapper: use local justfile if exists, otherwise global
  j() {
    if just --justfile justfile --summary &>/dev/null; then
      just "$@"
    else
      just --global-justfile "$@"
    fi
  }
  
  # Enhanced completion that handles both recipes and flags
  _j() {
    local context state line
    local -a recipes flags
    
    # Define common just flags
    flags=(
      '--list:List available recipes'
      '--dry-run:Show what would be done without executing'
      '--verbose:Use verbose output'
      '--quiet:Suppress all output except recipe output'
      '--set:Override a setting'
      '--shell:Invoke a shell instead of recipe'
      '--working-directory:Use a different working directory'
      '--justfile:Use a different justfile'
      '--global-justfile:Use the global justfile'
      '--color:Print colorful output'
      '--no-dotenv:Do not load .env file'
      '--dotenv-filename:Load environment from a .env file'
      '--dotenv-path:Search for .env file starting from a directory'
    )
    
    # Check if current word starts with - (flag completion)
    if [[ ${words[CURRENT]} == -* ]]; then
      _describe 'flags' flags
      return
    fi
    
    # Recipe completion - check if local justfile exists (same logic as j function)
    if just --justfile justfile --summary &>/dev/null 2>&1; then
      # Local justfile exists, use standard just completion
      recipes=(${(f)"$(just --list 2>/dev/null | tail -n +2 | grep -o '^[[:space:]]*[^[:space:]]*' | sed 's/^[[:space:]]*//')"})
    else
      # No local justfile, use global justfile
      recipes=(${(f)"$(just --global-justfile --list 2>/dev/null | tail -n +2 | grep -o '^[[:space:]]*[^[:space:]]*' | sed 's/^[[:space:]]*//')"})
    fi
    
    # Filter out empty lines and category headers
    recipes=(${recipes:#""})
    recipes=(${recipes:#\[*\]})
    
    _describe 'recipes' recipes
  }
  
  compdef _j j
fi



# 1Password SSH agent
# On macOS: configured via ~/.ssh/config (IdentityAgent for github.com).
# On WSL: use ssh.exe aliases so SSH requests are forwarded to the 1Password
# SSH agent running on the Windows host — no bridge/relay needed.
# See: https://developer.1password.com/docs/ssh/integrations/wsl
if grep -qi microsoft /proc/version 2>/dev/null; then
  alias ssh='ssh.exe'
  alias ssh-add='ssh-add.exe'
fi

# Aliases
if command -v eza >/dev/null 2>&1; then
  export EZA_COLORS="di=38;2;137;180;250"
  alias eza="eza --color=always --git --icons=always --group-directories-first"
  alias l="eza"
  alias ll="eza --long --header --time-style=relative"
  alias la="eza --long --all --header --time-style=relative"
  alias tree="eza --tree --icons=always"
  alias lt="eza --tree --level=2 --icons=always"
fi

alias vim=nvim
alias vi=nvim
alias n=nvim
alias g=git
alias cl=clear
alias k=kubectl

ai() {
  local assistant="${AI_ASSISTANT:-opencode}"
  local -a cmd
  cmd=(${=assistant})
  command "${cmd[@]}" "$@"
}


if command -v brew >/dev/null 2>&1; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

if [[ "$OSTYPE" == darwin* ]] && [[ -d "/opt/homebrew/opt/llvm/bin" ]]; then
  export PATH="/opt/homebrew/opt/llvm/bin:$PATH"
fi


# LM Studio CLI (lms)
[[ -d "$HOME/.lmstudio/bin" ]] && export PATH="$PATH:$HOME/.lmstudio/bin"

export CC=clang
export CXX=clang++
#zprof
