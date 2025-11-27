#!/usr/bin/env bash

sleep 0.1

modified=$(tmux show-option -gqv status-right | sed 's|#(whoami) #\[fg=#89b4fa,bg=#313244\]\(.\{1,5\}\)#\[fg=#1e1e2e,bg=#89b4fa\]󰒋|#(whoami) #{?SSH_CONNECTION,#[fg=#f38ba8],#[fg=#a6e3a1]}#[bg=#313244]\1#{?SSH_CONNECTION,#[fg=#1e1e2e]#[bg=#f38ba8],#[fg=#1e1e2e]#[bg=#a6e3a1]}#{?SSH_CONNECTION,󰖟,󰒋}|')

tmux set-option -gq status-right "$modified"
