#!/bin/bash
[[ -f ~/.Xresources ]] && xrdb -merge ~/.Xresources

# nvidia-settings
if command -v nvidia-settings > /dev/null 2>&1; then
    nvidia-settings --load-config-only &
fi

exec i3
