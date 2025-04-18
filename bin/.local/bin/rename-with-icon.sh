#!/usr/bin/env bash

print_only=0
if [[ "$1" == "--print" ]]; then
  print_only=1
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
    opencode|crush|claude|copilot|ai|llmfit|models) printf '%s' '󱚧' ;;
    ssh|mosh) printf '%s' '󰣀' ;;
    scratch|notes|obsidian) printf '%s' '󱞁' ;;
    *) printf '' ;;
  esac
}

bare_name="$(strip_prefix_icon "$window_name")"
lower_name="$(printf '%s' "$bare_name" | tr '[:upper:]' '[:lower:]')"
icon="$(icon_for_name "$lower_name")"

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
