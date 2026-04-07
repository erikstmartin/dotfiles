#!/usr/bin/env bash
# Prefix a tmux window / WezTerm tab name with a Nerd Font icon chosen by the
# first word of the name (the program). Single source of truth for the icon map.
#   rename-with-icon.sh NAME WINDOW_ID   rename tmux window
#   rename-with-icon.sh --print NAME     print "ICON NAME" (or NAME if no icon)
#   rename-with-icon.sh --icon NAME      print only the icon (empty if none)

print_only=0
icon_only=0
if [[ "$1" == "--print" ]]; then
  print_only=1
  shift
elif [[ "$1" == "--icon" ]]; then
  icon_only=1
  shift
fi

window_name="$1"
window_id="$2"

trim_left() {
  local input="$1"
  input="${input#"${input%%[![:space:]]*}"}"
  printf '%s' "$input"
}

strip_prefix_icon() {
  local input first rest
  input="$(trim_left "$1")"

  if [[ "$input" != *" "* ]]; then
    printf '%s' "$input"
    return
  fi

  first="${input%% *}"
  rest="${input#"$first"}"
  rest="$(trim_left "$rest")"

  if [[ "$first" =~ [^[:alnum:]_.:/-] ]]; then
    printf '%s' "$rest"
    return
  fi

  printf '%s' "$input"
}

icon_for_name() {
  local name="$1"

  case "$name" in
    zsh|bash|sh|fish) printf '%s' '' ;;
    nvim|neovim) printf '%s' '' ;;
    vim|vi) printf '%s' '' ;;
    lazygit|git) printf '%s' '' ;;
    lazydocker|docker) printf '%s' '' ;;
    k9s|k8s|kubectl) printf '%s' '☸' ;;
    gh-dash|gh|github) printf '%s' '' ;;
    posting|curl|curlie|http|httpie|xh|newman|k6) printf '%s' '󰖟' ;;
    opencode|claude|copilot|ai|llmfit|models) printf '%s' '󱚧' ;;
    ssh|mosh) printf '%s' '󰣀' ;;
    scratch|notes|obsidian) printf '%s' '󱞁' ;;
    *) printf '' ;;
  esac
}

bare_name="$(strip_prefix_icon "$window_name")"
first_word="${bare_name%% *}"
lower_name="$(printf '%s' "$first_word" | tr '[:upper:]' '[:lower:]')"
icon="$(icon_for_name "$lower_name")"

if [[ "$icon_only" == "1" ]]; then
  printf '%s' "$icon"
  exit 0
fi

if [[ -z "$bare_name" ]]; then
  exit 0
fi

if [[ -n "$icon" ]]; then
  desired_name="$icon $bare_name"
else
  desired_name="$bare_name"
fi

if [[ "$desired_name" == "$window_name" ]]; then
  if [[ "$print_only" == "1" ]]; then
    printf '%s\n' "$desired_name"
  fi
  exit 0
fi

if [[ "$print_only" == "1" ]] || [[ "${TMUX_ICON_DRY_RUN:-0}" == "1" ]]; then
  printf '%s\n' "$desired_name"
  exit 0
fi

tmux rename-window -t "$window_id" "$desired_name"
