# zmodload zsh/zprof

# Handle Ghostty terminal - fallback if terminfo not available
if [[ "$TERM" == "xterm-ghostty" ]]; then
    if ! infocmp "$TERM" &>/dev/null 2>&1; then
        export TERM=xterm-256color
    fi
fi

# History
HISTSIZE=50000
HISTFILE=$HOME/.zsh_history
SAVEHIST=50000
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_dups
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_find_no_dups
setopt hist_verify

# Filter commands from history — same rules as fish's
# functions/fish_should_add_to_history.fish (leading space: hist_ignore_space)
zshaddhistory() {
  local line="${1%%$'\n'}"
  local lower="${(L)line}"
  # The keyword must end the name or a _-separated part of it (GH_TOKEN,
  # DB_PASSWORD_FILE), so TOKENIZERS_PARALLELISM is kept
  local secret='[[:alnum:]_]*(password|passwd|token|secret|api[_-]?key)(_[[:alnum:]_]*)?'
  # Blank lines and single-char commands
  [[ ${#line} -le 1 ]] && return 1
  # cd / zoxide navigation (context-dependent, not useful to replay)
  [[ "$line" =~ '^(cd|z)( .*)?$' ]] && return 1
  # Short noisy commands (including the eza aliases)
  [[ "$line" =~ '^(ls|l|ll|la|lt|tree|eza|pwd|clear|cl|exit|history)( .*)?$' ]] && return 1
  # Force push/pull
  [[ "$line" =~ '^git (push|pull)( .*)?(--force|-f)( .*)?$' ]] && return 1
  # Credentials passed to curl/wget
  [[ "$lower" =~ "^(curl|wget)[[:space:]].*(password|passwd|token|secret|api[_-]?key)" ]] && return 1
  # Secrets assigned to environment variables (export FOO_TOKEN=..., FOO_TOKEN=... cmd)
  [[ "$lower" =~ "^(export[[:space:]]+|set[[:space:]]+(-[[:alnum:]]+[[:space:]]+)*)${secret}([[:space:]]|=)" ]] && return 1
  [[ "$lower" =~ "(^|[[:space:]])${secret}=" ]] && return 1
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

# Caches a tool's init script (`starship init zsh`, ...) so it isn't spawned
# on every start; sets REPLY to the cache file. The cache is keyed on the
# resolved binary path (a mise/brew upgrade changes it) plus the env that init
# scripts bake in (XDG_CONFIG_HOME, CARAPACE_BRIDGES), and regenerated when
# the binary is newer. Failed/empty output is never cached.
# Clear with: rm -r ~/.cache/zsh/init (`jg update` does, after mise upgrades)
_cached_init() {
  local bin=${commands[$1]:A}
  [[ -n $bin ]] || return 1
  local dir=${XDG_CACHE_HOME:-$HOME/.cache}/zsh/init
  REPLY=$dir/${${:-$bin ${(j: :)@[2,-1]} $XDG_CONFIG_HOME $CARAPACE_BRIDGES}//[^A-Za-z0-9.-]/_}.zsh
  if [[ ! -s $REPLY || $bin -nt $REPLY ]]; then
    mkdir -p $dir
    if ! "$@" >| $REPLY.$$ 2>/dev/null || [[ ! -s $REPLY.$$ ]]; then
      command rm -f $REPLY.$$
      return 1
    fi
    command mv -f $REPLY.$$ $REPLY
  fi
}
_cached_source() {
  local REPLY
  _cached_init "$@" && source $REPLY
}

# fpath additions — must come before compinit
_zcomp_dir=${XDG_CACHE_HOME:-$HOME/.cache}/zsh/completions
fpath=($_zcomp_dir $fpath)
if test -d "${HOME}/.docker/completions"; then
  fpath=("${HOME}/.docker/completions" $fpath)
fi

# Completion — before zinit, so zinit's (stale) completions dir isn't scanned
autoload -U compinit && compinit -C

ZINIT_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/zinit/zinit.git"
# Download zinit if it doesn't exist
if [ ! -d "${ZINIT_HOME}" ]; then
  echo "Installing zinit"
  mkdir -p "${ZINIT_HOME}"
  git clone --depth=1 https://github.com/zdharma-continuum/zinit.git "${ZINIT_HOME}"
fi

source "${ZINIT_HOME}/zinit.zsh"

# Snippets — before mise, whose command_not_found_handler wraps OMZ's.
# (OMZ's git and common-aliases are deliberately not loaded: they clash with
# the fish-compatible shorthands below, e.g. gcm, and alias fd/rm/cp/mv.)
zinit snippet OMZP::command-not-found
zinit snippet OMZP::colored-man-pages

# Mise — activated early so its tools (carapace, fzf, fd, workmux, ...) are on
# PATH for everything below. (Personal installs in ~/.local/bin, ~/go/bin, ... still win: see the _.path
# setting in mise's config.toml)
if (( $+commands[mise] )); then
  eval "$(mise activate zsh)"
fi

# Direnv only if it's installed
if (( $+commands[direnv] )); then
  _cached_source direnv hook zsh
fi

# workmux completions: written to the fpath dir above so compinit autoloads
# them on first use. A new file needs a fresh compdump.
if (( $+commands[workmux] )) && [[ ! -s $_zcomp_dir/_workmux || ${commands[workmux]:A} -nt $_zcomp_dir/_workmux ]]; then
  mkdir -p $_zcomp_dir
  if workmux completions zsh >| $_zcomp_dir/_workmux.$$ 2>/dev/null && [[ -s $_zcomp_dir/_workmux.$$ ]]; then
    command mv -f $_zcomp_dir/_workmux.$$ $_zcomp_dir/_workmux
    command rm -f ${ZDOTDIR:-$HOME}/.zcompdump{,.zwc}
    autoload -Uz _workmux && compdef _workmux workmux
  else
    command rm -f $_zcomp_dir/_workmux.$$
  fi
fi

# Zsh plugins. These three load just after the first prompt (zinit turbo);
# zsh-vi-mode initialises at the first prompt, before them, so they wrap its
# widgets. Its zvm_after_init binds their widgets by name ahead of loading.
zinit wait lucid for \
  zsh-users/zsh-history-substring-search \
  atload'!_zsh_autosuggest_start' zsh-users/zsh-autosuggestions \
  zdharma-continuum/fast-syntax-highlighting
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
  # fzf key bindings/widgets — loaded here (the documented place) so zvm
  # doesn't clobber them. (No $commands in here: zvm runs this hook with a
  # local variable of that name, hence the pre-resolved $_fzf_init.)
  if [[ -n $_fzf_init ]]; then
    source $_fzf_init
    bindkey '\e[Z' fzf-completion        # Shift-Tab = fzf completion
    bindkey '^I' ${fzf_default_completion:-expand-or-complete}  # Tab = native zsh completion
    source ~/.local/share/fzf-git/fzf-git.sh 2>/dev/null || true
  fi
}

# Carapace multi-shell completions
if (( $+commands[carapace] )); then
  export CARAPACE_BRIDGES='zsh,fish,bash'
  export CARAPACE_MATCH=1
  zstyle ':completion:*' format $'\e[2;37mCompleting %d\e[m'
  _cached_source carapace _carapace zsh
fi

# Completion styles
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' rehash true
zstyle ':completion:*' menu yes select



# Native fzf completion
export FZF_COMPLETION_TRIGGER=''  # Disable ** trigger, use key binding instead
export FZF_COMPLETION_OPTS='--border=rounded --border-label="" --preview-window=border-rounded:right:60%:wrap --height=80%'
export FZF_COMPLETION_DIR_COMMANDS='cd pushd rmdir z zi __zoxide_z'

export FZF_COMPLETION_PATH_OPTS="--preview 'if [[ -d {} ]]; then eza --color=always --icons=always --group-directories-first --all {} 2>/dev/null || ls -la {}; elif [[ -f {} ]]; then bat --color=always --style=numbers --line-range=:100 {} 2>/dev/null || head -20 {}; else echo \"Not found: {}\"; fi'"
export FZF_COMPLETION_DIR_OPTS="--preview 'eza --color=always --icons=always --group-directories-first --all {} 2>/dev/null || ls -la {}'"

# Fzf — environment only; the key bindings/widgets are loaded in
# zvm_after_init above
if (( $+commands[fzf] )); then
  _cached_init fzf --zsh && _fzf_init=$REPLY
  # Same as fish's conf.d/fzf.fish, plus --with-shell: previews here use
  # [[ ]] and $SHELL may be fish. Assigned outright so nested shells don't
  # append it again.
  export FZF_DEFAULT_OPTS='--with-shell="bash -c"
  --color=bg+:#313244,bg:#11111b,spinner:#f5e0dc,hl:#f38ba8
  --color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc
  --color=marker:#b4befe,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8
  --color=selected-bg:#45475a
  --color=border:#6c7086,label:#cdd6f4
  --border=rounded --border-label="" --preview-window=border-rounded:right:60%:wrap
  --height=80%
  --prompt="> " --marker="-" --pointer="◆"
  --separator="-" --scrollbar="|" --layout=reverse'
  if (( $+commands[fd] )); then
    export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git"
    export FZF_ALT_C_COMMAND="fd --type d --hidden --strip-cwd-prefix --exclude .git"
    export FZF_CTRL_T_COMMAND=$FZF_DEFAULT_COMMAND
  fi
  # Previews: eza for dirs, bat for files, with plain fallbacks
  if (( $+commands[eza] )); then
    export FZF_ALT_C_OPTS="--preview 'eza --tree --level=2 --color=always --icons=always {} | head -200'"
    _fzf_dir_preview='eza --tree --level=2 --color=always {} | head -200'
  else
    _fzf_dir_preview='ls -la {}'
  fi
  if (( $+commands[bat] )); then
    _fzf_file_preview='bat -n --color=always --line-range :500 {}'
  else
    _fzf_file_preview='head -500 {}'
  fi
  show_file_or_dir_preview="if [[ -d {} ]]; then $_fzf_dir_preview; else $_fzf_file_preview; fi"
  unset _fzf_dir_preview _fzf_file_preview
  export FZF_CTRL_T_OPTS="--preview '$show_file_or_dir_preview' \
                          --height 60% \
                          --border sharp \
                          --layout reverse \
                          --prompt '∷ ' \
                          --pointer ▶ \
                          --marker ⇒"
fi

_fzf_comprun() {
  local command=$1
  shift

  case "$command" in
    cd)           fzf --preview 'eza --tree --level=2 --color=always --icons=always {} | head -200' --preview-window=right:50%:wrap "$@" ;;
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

if (( $+commands[zoxide] )); then
  _cached_source zoxide init --cmd z zsh
fi

if (( $+commands[starship] )); then
  _cached_source starship init zsh --print-full-init
fi

if command -v yazi >/dev/null 2>&1; then
  y() {
    local tmp cwd exit_code
    tmp="$(mktemp -t yazi-cwd.XXXXXX)" || return
    command yazi "$@" --cwd-file="$tmp"
    exit_code=$?
    IFS= read -r cwd < "$tmp"
    command rm -f -- "$tmp"
    if [[ -n "$cwd" && "$cwd" != "$PWD" && -d "$cwd" ]]; then
      builtin cd -- "$cwd"
    fi
    return $exit_code
  }
fi

if (( $+commands[just] )); then
  # Smart just: the nearest justfile (here or in a parent dir), else the
  # global one — same as fish's and PowerShell's j
  j() {
    if just --summary >/dev/null 2>&1; then
      just "$@"
    else
      just --global-justfile "$@"
    fi
  }
  alias jg="just --global-justfile"
  compdef j=just
fi

if command -v workmux >/dev/null 2>&1; then
  alias wm="workmux"
fi



# 1Password SSH agent
# On macOS: configured via ~/.ssh/config (IdentityAgent for github.com).
# On WSL machines with the Windows 1Password SSH agent, set
# WSL_1PASSWORD_SSH=1 in ~/.env.local to use Windows OpenSSH.
# See: https://developer.1password.com/docs/ssh/integrations/wsl
# GIT_SSH_COMMAND does the same for git (and lazygit, Neovim, ...).
if [[ $WSL_1PASSWORD_SSH == 1 ]] &&
   [[ -x /mnt/c/Windows/System32/OpenSSH/ssh.exe ]]; then
  alias ssh='/mnt/c/Windows/System32/OpenSSH/ssh.exe'
  alias ssh-add='/mnt/c/Windows/System32/OpenSSH/ssh-add.exe'
  export GIT_SSH_COMMAND=/mnt/c/Windows/System32/OpenSSH/ssh.exe
fi

# Aliases
if (( $+commands[eza] )); then
  alias eza="eza --color=auto --git --icons=auto --group-directories-first"
  alias l="eza"
  alias ll="eza --long --header --time-style=relative"
  alias la="eza --long --all --header --time-style=relative"
  alias tree="eza --tree --icons=always"
  alias lt="eza --tree --level=2 --icons=always"
fi

alias vim=nvim
alias vi=nvim
alias v=nvim
alias n=nvim
alias g=git
alias cl=clear
alias d=docker
alias k=kubectl

# Ask before removing or overwriting files (same in fish and PowerShell)
alias rm='rm -i' cp='cp -i' mv='mv -i'

ai() {
  local assistant="${AI_ASSISTANT:-opencode}"
  local -a cmd
  cmd=(${=assistant})
  command "${cmd[@]}" "$@"
}


# Create directory and cd into it
mkcd() {
  mkdir -p "$1" && cd "$1"
}

# 7-Zip's command name varies: 7zz (official 7-Zip: Homebrew sevenzip,
# Debian/Ubuntu 7zip), 7z/7za (p7zip). It also extracts RAR archives.
__extract_7zip() {
  local cmd
  for cmd in 7zz 7z 7za; do
    if (( $+commands[$cmd] )); then
      command $cmd x "$@"
      return
    fi
  done
  echo "extract: no 7-Zip found (install sevenzip / 7zip / p7zip)" >&2
  return 1
}

# Extract archives
extract() {
  if [[ -f "$1" ]]; then
    case "$1" in
      *.tar.bz2) tar xjf "$1" ;;
      *.tar.gz)  tar xzf "$1" ;;
      *.bz2)     bunzip2 "$1" ;;
      *.rar)     if (( $+commands[unrar] )); then unrar x "$1"; else __extract_7zip "$1"; fi ;;
      *.gz)      gunzip "$1" ;;
      *.tar)     tar xf "$1" ;;
      *.tbz2)    tar xjf "$1" ;;
      *.tgz)     tar xzf "$1" ;;
      *.zip)     unzip "$1" ;;
      *.Z)       uncompress "$1" ;;
      *.7z)      __extract_7zip "$1" ;;
      *)         echo "'$1' cannot be extracted via extract()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

# Git shorthand (same as fish's conf.d/functions.fish)
gst()  { git status; }
gco()  { git checkout "$@"; }
gcb()  { git checkout -b "$@"; }
gaa()  { git add --all; }
gcm()  { git commit -m "$*"; }
gp()   { git push; }
gl()   { git pull; }
glog() { git log --oneline --decorate --graph; }


#zprof
# Docker Desktop appends a block here that re-runs a full compinit on every
# start; delete it (~/.docker/completions is already on fpath above).
