# zmodload zsh/zprof

# Use emacs keybindings
bindkey -e
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward

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
autoload -U colors && colors	      # colours
autoload -U compinit && compinit    # basic completion
autoload -U compinit colors zcalc   # theming

# Zinit
ZINIT_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/zinit/zinit.git"
# Download zinit if it doesn't exist
if [ ! -d "${ZINIT_HOME}" ]; then
  echo "Installing zinit"
  mkdir -p "${ZINIT_HOME}"
  git clone --depth=1 https://github.com/zdharma-continuum/zinit.git "${ZINIT_HOME}"
fi

source "${ZINIT_HOME}/zinit.zsh"

# Zsh plugins
zinit light zdharma/fast-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light zsh-users/zsh-history-substring-search
zinit light Aloxaf/fzf-tab

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

# Snippets
zinit snippet OMZP::git
zinit snippet OMZP::sudo
zinit snippet OMZP::aws
zinit snippet OMZP::azure
zinit snippet OMZP::microk8s
zinit snippet OMZP::podman
zinit snippet OMZP::helm
zinit snippet OMZP::command-not-found
zinit snippet OMZP::colored-man-pages
zinit snippet OMZP::common-aliases

# Completion
autoload -U compinit && compinit
autoload -U +X bashcompinit && bashcompinit

if command -v terraform >/dev/null 2>&1; then
  complete -o nospace -C "$(command -v terraform)" terraform
fi

# Completion styles
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
# zstyle ':completion:*' list-colors "${(s.:.)--color=auto}"
zstyle ':completion:*' rehash true
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

# Starship prompt
eval "$(starship init zsh)"

# Direnv only if it's installed
if command -v direnv >/dev/null 2>&1; then
  eval "$(direnv hook zsh)"
fi

# Fzf
if [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh; then
  export FZF_DEFAULT_OPTS=$FZF_DEFAULT_OPTS'
  --color=fg:#E0E2EA,fg+:#E0E2EA,bg:#121212,bg+:#262626
  --color=hl:#A6DBFF,hl+:#5fd7ff,info:#B3F6C0,marker:#B3F6C0
  --color=prompt:#d7005f,spinner:#B3F6C0,pointer:#B3F6C0,header:#8CF8F7
  --color=border:#262626,label:#aeaeae,query:#d9d9d9
  --border="rounded" --border-label="" --preview-window="border-rounded"
  --prompt="> " --marker="-" --pointer="◆"
  --separator="-" --scrollbar="|" --layout="reverse"'

  export FZF_DEFAULT_COMMAND="fdfind --hidden --strip-cwd-prefix --exclude .git"
  export FZF_ALT_C_COMMAND="fdfind --type d --hidden --strip-cwd-prefix --exclude .git"
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

  show_file_or_dir_preview="if [ -d {} ]; then eza --tree --color=always {} | head -200; else batcat -n --color=always --line-range :500 {}; fi"
  export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -200'"
  export FZF_CTRL_T_OPTS="--preview '$show_file_or_dir_preview' \
                          --height 60% \
                          --border sharp \
                          --layout reverse \
                          --prompt '∷ ' \
                          --pointer ▶ \
                          --marker ⇒"

  # https://github.com/junegunn/fzf-git.sh
  source ~/.local/share/fzf-git/fzf-git.sh
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
  fdfind --hidden --exclude .git  . "$1" 
}

_fzf_compgen_dir() {
  fdfind --type d --hidden --exclude .git . "$1"
}

if command -v batcat >/dev/null 2>&1; then
  export BAT_THEME="ansi"
  alias cat=batcat
fi

if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init --cmd cd zsh)"
fi

if command -v yazi >/dev/null 2>&1; then
  alias y="yazi"
fi

# Use the 1Password agent bridge for keys
if [ -f "${HOME}/.1password/agent-bridge.sh" ]; then
  source "${HOME}/.1password/agent-bridge.sh"
fi

# Aliases
if command -v eza >/dev/null 2>&1; then
  alias eza="eza --color=always --git --icons=always"
  alias l="eza --long --no-filesize --no-time --no-user --no-permissions"
  alias ls="eza"
  alias tree="eza --tree"
else
  alias ls='ls --color=auto'
fi

alias vim=nvim
alias vi=nvim

###-begin-npm-completion-###
#
# npm command completion script
#
# Installation: npm completion >> ~/.bashrc  (or ~/.zshrc)
# Or, maybe: npm completion > /usr/local/etc/bash_completion.d/npm
#

COMP_WORDBREAKS=${COMP_WORDBREAKS/=/}
COMP_WORDBREAKS=${COMP_WORDBREAKS/@/}
export COMP_WORDBREAKS

if type complete &>/dev/null; then
  _npm_completion () {
    local si="$IFS"
    IFS=$'\n' COMPREPLY=($(COMP_CWORD="$COMP_CWORD" \
                           COMP_LINE="$COMP_LINE" \
                           COMP_POINT="$COMP_POINT" \
                           npm completion -- "${COMP_WORDS[@]}" \
                           2>/dev/null)) || return $?
    IFS="$si"
  }
  complete -F _npm_completion npm
elif type compdef &>/dev/null; then
  _npm_completion() {
    si=$IFS
    compadd -- $(COMP_CWORD=$((CURRENT-1)) \
                 COMP_LINE=$BUFFER \
                 COMP_POINT=0 \
                 npm completion -- "${words[@]}" \
                 2>/dev/null)
    IFS=$si
  }
  compdef _npm_completion npm
elif type compctl &>/dev/null; then
  _npm_completion () {
    local cword line point words si
    read -Ac words
    read -cn cword
    let cword-=1
    read -l line
    read -ln point
    si="$IFS"
    IFS=$'\n' reply=($(COMP_CWORD="$cword" \
                       COMP_LINE="$line" \
                       COMP_POINT="$point" \
                       npm completion -- "${words[@]}" \
                       2>/dev/null)) || return $?
    IFS="$si"
  }
  compctl -K _npm_completion npm
fi
###-end-npm-completion-###


# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$("${HOME}/anaconda3/bin/conda" 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "${HOME}/anaconda3/etc/profile.d/conda.sh" ]; then
        . "${HOME}/anaconda3/etc/profile.d/conda.sh"
    else
        export PATH="${HOME}/anaconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<


# pnpm
export PNPM_HOME="${HOME}/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end


# rbenv
eval "$(rbenv init -)"

#zprof
