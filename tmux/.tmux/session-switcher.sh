#!/usr/bin/env bash

sock="${TMUX%%,*}"
cur_name="$(tmux -S "$sock" display-message -p '#S')"

fmt='#{session_id}|#{session_name}|#{session_attached}|#{session_windows}'

sessions=$(tmux -S "$sock" list-sessions -F "$fmt" |
  awk -F'|' -v cur="$cur_name" '
    {
      id=$1; sub(/^\$/,"",id)
      name=$2
      state=($3=="1" ? "attached" : "detached")
      windows=$4
      line=sprintf("%-20s | %s | %d windows", name, state, windows)
      if (name==cur) { print "* " line; next }
      print "  " line
    }
  ')

selected=$(echo "$sessions" | fzf \
  --reverse \
  --no-sort \
  --prompt='session> ' \
  --header='Switch session (Ctrl-/ to toggle preview)' \
  --preview='session=$(echo {} | sed "s/^[* ] //" | awk -F" | " "{print \$1}" | xargs); tmux capture-pane -ep -t "${session}:"' \
  --preview-window=right:60%:wrap:follow \
  --bind='ctrl-/:toggle-preview' \
  --ansi)

if [ -n "$selected" ]; then
  target=$(echo "$selected" | sed 's/^[* ] //' | awk -F' | ' '{print $1}' | xargs)
  tmux -S "$sock" switch-client -t "$target"
fi
