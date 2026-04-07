# The following lines were added by Docker Desktop to add commands to your PATH.
export PATH="$PATH:$HOME/.docker/bin"
# End of Docker Desktop section.

if [ "$(uname -s)" = Linux ]; then
  #export QT_FONT_DPI=120
  export QT_QPA_PLATFORMTHEME="gtk3"
  export GTK_THEME=Adwaita:dark
fi
export PATH="$HOME/.cargo/bin:$PATH"

# UTF-8 locale everywhere (some terminals mis-measure wide characters without it).
# LC_ALL only where that locale exists — setlocale warnings otherwise (Linux).
export LANG=en_US.UTF-8
if locale -a 2>/dev/null | grep -qiE '^en_US\.utf-?8$'; then
  export LC_ALL=en_US.UTF-8
fi

# Environment file some installers (e.g. uv) create; absent on most machines
[ -f "$HOME/.local/bin/env" ] && . "$HOME/.local/bin/env"
