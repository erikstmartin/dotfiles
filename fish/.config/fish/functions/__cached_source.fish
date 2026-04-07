# Sources a tool's init script (`starship init fish`, ...) from a cache file
# instead of spawning the tool on every start. The cache is keyed on the resolved binary path (a
# mise/brew upgrade changes it) plus the env that init scripts bake in
# (XDG_CONFIG_HOME, CARAPACE_BRIDGES), and regenerated when the binary is
# newer. Failed/empty output is never cached.
# Usage: __cached_source starship init fish --print-full-init
# Clear with: command rm -r ~/.cache/fish/init (`jg update` does, after mise
# upgrades)
function __cached_source --description 'Source cached output of a tool init command'
    set -l bin (command -s $argv[1]); or return 1
    set bin (path resolve $bin)
    set -l dir ~/.cache/fish/init
    set -l cache $dir/(string replace -ra '[^A-Za-z0-9.-]+' _ -- "$bin $argv[2..] $XDG_CONFIG_HOME $CARAPACE_BRIDGES").fish
    if not test -s $cache; or test $bin -nt $cache
        mkdir -p $dir
        if not $argv >$cache.$fish_pid 2>/dev/null; or not test -s $cache.$fish_pid
            command rm -f $cache.$fish_pid
            return 1
        end
        command mv -f $cache.$fish_pid $cache
    end
    source $cache
end
