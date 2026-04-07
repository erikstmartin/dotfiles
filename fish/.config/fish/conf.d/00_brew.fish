# Homebrew shell environment
# Must run early (before 00_mise.fish) so brew-installed tools are on PATH for
# everything else, while mise's paths still end up ahead of Homebrew's.

# `brew shellenv` output is cached and only regenerated when brew changes.
# It's generated with a clean PATH: brew prints nothing when PATH already
# starts with Homebrew's dirs (nested shells), and an empty cache would stick.
# Temp file + mv: a concurrently starting shell never sources a partial file.
function __brew_shellenv --argument-names brew
    set -l cache ~/.cache/fish/brew-shellenv.fish
    if not test -s $cache; or test $brew -nt $cache
        mkdir -p (path dirname $cache)
        if env PATH=/usr/bin:/bin $brew shellenv fish >$cache.$fish_pid; and test -s $cache.$fish_pid
            command mv -f $cache.$fish_pid $cache
        else
            command rm -f $cache.$fish_pid
        end
    end
    test -s $cache; and source $cache
end

if test (uname) = Darwin
    # Apple Silicon
    if test -x /opt/homebrew/bin/brew
        __brew_shellenv /opt/homebrew/bin/brew
        fish_add_path -g -P /opt/homebrew/opt/llvm/bin
    # Intel Mac
    else if test -x /usr/local/bin/brew
        __brew_shellenv /usr/local/bin/brew
        fish_add_path -g -P /usr/local/opt/llvm/bin
    end
else if test (uname) = Linux
    # Homebrew on Linux
    if test -x /home/linuxbrew/.linuxbrew/bin/brew
        __brew_shellenv /home/linuxbrew/.linuxbrew/bin/brew
    end
end
functions -e __brew_shellenv

# Appended (lowest priority) CLI dirs. -P edits $PATH itself: entries in
# fish_user_paths (fish_add_path's default) always go to the front, even with
# -a, and would shadow mise's tools (Docker Desktop ships its own kubectl).
# fish_add_path skips missing dirs and ones already present (nested shells).
fish_add_path -P -a $HOME/.docker/bin # Docker Desktop
