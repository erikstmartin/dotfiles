#!/usr/bin/env bash

sock="${TMUX%%,*}"
cur_window="$(tmux -S "$sock" display-message -p '#S:#I')"

fmt='#{session_name}:#{window_index}|#{window_name}|#{pane_current_command}|#{window_panes}'

windows=$(tmux -S "$sock" list-windows -a -F "$fmt" |
  awk -F'|' -v cur="$cur_window" '
    {
      target=$1
      name=$2
      cmd=$3
      panes=$4
      
      line=sprintf("%-25s | %-20s | %-15s | %d panes", target, name, cmd, panes)
      if (target==cur) { print "* " line; next }
      print "  " line
    }
  ')

selected=$(echo "$windows" | fzf \
  --reverse \
  --no-sort \
  --prompt='window> ' \
  --header='Switch window (Ctrl-/ to toggle preview)' \
  --preview='target=$(echo {} | sed "s/^[* ] //" | awk -F" | " "{print \$1}" | xargs); tmux capture-pane -ep -t "$target"' \
  --preview-window=right:60%:wrap:follow \
  --bind='ctrl-/:toggle-preview' \
  --ansi)

if [ -n "$selected" ]; then
  target=$(echo "$selected" | sed 's/^[* ] //' | awk -F' | ' '{print $1}' | xargs)
  session=$(echo "$target" | cut -d: -f1)
  tmux -S "$sock" switch-client -t "$session"
  tmux -S "$sock" select-window -t "$target"
fi
