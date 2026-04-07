# Homebrew + personal bin dirs are set up in .zshenv (sourced by all shell
# invocation types). On macOS, /etc/zprofile's path_helper then moves the
# system dirs (/usr/bin, ...) ahead of them in login shells, so re-apply it
# here, as Homebrew recommends for `brew shellenv`.
(( $+functions[_zshenv_path] )) && _zshenv_path

# The following lines were added by Docker Desktop to add commands to your PATH.
export PATH="$PATH:$HOME/.docker/bin"
# End of Docker Desktop section.
