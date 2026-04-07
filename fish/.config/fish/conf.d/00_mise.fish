# mise — activate tool environments
# Sorts before aliases.fish etc. so mise tools are on $PATH when conf.d scripts
# run, and after 00_brew.fish so mise's paths take priority over Homebrew's.
# Absolute path fallback: conf.d runs before config.fish adds ~/.local/bin.

# Homebrew's mise ships vendor_conf.d/mise-activate.fish, which would activate
# mise a second time; this turns it off.
set -gx MISE_FISH_AUTO_ACTIVATE 0

if type -q mise
    mise activate fish | source
else if test -x $HOME/.local/bin/mise
    $HOME/.local/bin/mise activate fish | source
end
