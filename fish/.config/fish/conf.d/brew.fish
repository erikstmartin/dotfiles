# Homebrew shell environment
# Must run early so brew-installed tools are on PATH for everything else

if test (uname) = Darwin
    # Apple Silicon
    if test -x /opt/homebrew/bin/brew
        eval (/opt/homebrew/bin/brew shellenv)
        fish_add_path /opt/homebrew/opt/llvm/bin
    # Intel Mac
    else if test -x /usr/local/bin/brew
        eval (/usr/local/bin/brew shellenv)
        fish_add_path /usr/local/opt/llvm/bin
    end
else if test (uname) = Linux
    # Homebrew on Linux
    if test -x /home/linuxbrew/.linuxbrew/bin/brew
        eval (/home/linuxbrew/.linuxbrew/bin/brew shellenv)
    end
end
