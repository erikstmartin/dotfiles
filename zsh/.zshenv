#
# Browser
#

if [[ "$OSTYPE" == darwin* ]]; then
  export BROWSER='open'
elif [[ -n $WSL_DISTRO_NAME ]]; then
  export BROWSER='wsl-browser'
fi

#
# Editors
#

export EDITOR='nvim'
export VISUAL='nvim'
export PAGER='less'

# eza theme (catppuccin); on macOS eza would otherwise look in
# ~/Library/Application Support/eza instead of ~/.config/eza
export EZA_CONFIG_DIR="$HOME/.config/eza"

#
# Language
#

if [[ -z "$LANG" ]]; then
  export LANG='en_US.UTF-8'
fi

#
# Paths
#

typeset -gU cdpath fpath mailpath path PATH
# Re-running `brew shellenv` (see .zprofile) would otherwise duplicate entries
typeset -gxTU INFOPATH infopath

export GOPATH=~/go

# Homebrew + personal bin dirs, here so every shell type (incl. scripts) gets
# them. Login shells re-run it from .zprofile because macOS's /etc/zprofile
# (path_helper) moves /usr/bin & co. back to the front.
# `brew shellenv` output is cached and only regenerated when brew changes.
_zshenv_path() {
  local brew cache=${XDG_CACHE_HOME:-$HOME/.cache}/zsh/brew-shellenv.zsh
  for brew in /opt/homebrew/bin/brew /usr/local/bin/brew /home/linuxbrew/.linuxbrew/bin/brew; do
    [[ -x $brew ]] || continue
    if [[ ! -s $cache || $brew -nt $cache ]]; then
      # Clean PATH: brew prints nothing when PATH already starts with
      # Homebrew's dirs. Temp file + mv: other shells never see a partial file.
      mkdir -p ${cache:h}
      if PATH=/usr/bin:/bin $brew shellenv zsh >| $cache.$$ && [[ -s $cache.$$ ]]; then
        command mv -f $cache.$$ $cache
      else
        command rm -f $cache.$$
      fi
    fi
    [[ -s $cache ]] && source $cache
    break
  done

  # Personal installs win over Homebrew and the system (mise's _.path puts
  # them ahead of its tools too, once it's activated in .zshrc).
  local dir
  local -a candidates=(
    $HOME/.local/bin
    $HOME/.cargo/bin
    $GOPATH/bin
    $HOME/bin
    ${HOMEBREW_PREFIX:+$HOMEBREW_PREFIX/opt/llvm/bin}
  )
  local -a personal_paths
  for dir in $candidates; do
    [[ -d $dir ]] && personal_paths+=($dir)
  done
  path=($personal_paths $path)
  [[ -d /snap/bin ]] && path+=(/snap/bin)

  # WSL: keep only explicitly required Windows-side tools on PATH. Automatic
  # Windows PATH import is disabled in /etc/wsl.conf because misses across
  # mounted Windows directories make shell startup substantially slower.
  if [[ -n $WSL_DISTRO_NAME || $(</proc/version) == *[Mm]icrosoft* ]] 2>/dev/null; then
    [[ -d /mnt/c/bin ]] && path+=(/mnt/c/bin)
  fi
  return 0
}
_zshenv_path

#
# Less
#

# Set the default Less options.
# Mouse-wheel scrolling has been disabled by -X (disable screen clearing).
# Remove -X and -F (exit if the content fits on one screen) to enable it.
export LESS='-F -g -i -M -R -S -w -X -z4'

# Set the Less input preprocessor.
# lesspipe.sh (Homebrew) or lesspipe (Debian/Ubuntu)
if (( $+commands[lesspipe.sh] )); then
  export LESSOPEN='| /usr/bin/env lesspipe.sh %s 2>&-'
elif [[ -x /usr/bin/lesspipe ]]; then
  export LESSOPEN='| /usr/bin/lesspipe %s'
fi

#
# Temporary Files
#

if [[ ! -d "$TMPDIR" ]]; then
  export TMPDIR="/tmp/$USER"
  mkdir -p -m 700 "$TMPDIR"
fi

TMPPREFIX="${TMPDIR%/}/zsh"
if [[ ! -d "$TMPPREFIX" ]]; then
  mkdir -p "$TMPPREFIX"
fi



#
# Environment Variables
#

export XDG_CONFIG_HOME=~/.config

if [[ "$OSTYPE" == darwin* ]]; then
  # Homebrew's llvm (keg-only), when installed; otherwise Apple's clang applies
  if [[ -x "$HOMEBREW_PREFIX/opt/llvm/bin/clang" ]]; then
    export CC="$HOMEBREW_PREFIX/opt/llvm/bin/clang"
    export CXX="$HOMEBREW_PREFIX/opt/llvm/bin/clang++"
    export CLANGXX="$HOMEBREW_PREFIX/opt/llvm/bin/clang++"
  fi
elif [[ "$OSTYPE" == linux* ]]; then
  export QT_QPA_PLATFORMTHEME="gtk3"
  export CC="clang"
  export CXX="clang++"
  export CLANGXX="clang++"
  # /usr/local isn't always in the default search paths on Linux. Appended
  # only to existing values: an empty entry would mean the current directory.
  export LD_LIBRARY_PATH="/usr/local/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
  export CPLUS_INCLUDE_PATH="/usr/local/include${CPLUS_INCLUDE_PATH:+:$CPLUS_INCLUDE_PATH}"
  export C_INCLUDE_PATH="/usr/local/include${C_INCLUDE_PATH:+:$C_INCLUDE_PATH}"
fi
export ZSH_AUTOSUGGEST_HISTORY_IGNORE="git commit *"
export AI_ASSISTANT="${AI_ASSISTANT:-opencode}"


# Machine-local environment overrides — not tracked in dotfiles.
# Format: KEY=value (one per line, no spaces around =). fish parses the same
# file (fish/conf.d/01_env.fish), so keep it to plain assignments.
if [[ -f ~/.env.local ]]; then
  set -a
  source ~/.env.local
  set +a
fi
