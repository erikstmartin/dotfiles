# Custom functions for fish shell

# Create directory and cd into it
function mkcd
    mkdir -p $argv[1]
    cd $argv[1]
end

function y --description 'Yazi, changing to its directory on exit'
    set -l tmp (mktemp -t yazi-cwd.XXXXXX); or return
    command yazi $argv --cwd-file="$tmp"
    set -l yazi_status $status
    read -z cwd < "$tmp"
    command rm -f -- "$tmp"
    if test -n "$cwd"; and test "$cwd" != "$PWD"; and test -d "$cwd"
        builtin cd -- "$cwd"
    end
    return $yazi_status
end

# 7-Zip's command name varies: 7zz (official 7-Zip: Homebrew sevenzip,
# Debian/Ubuntu 7zip), 7z/7za (p7zip). It also extracts RAR archives.
function __extract_7zip
    for cmd in 7zz 7z 7za
        if command -q $cmd
            command $cmd x $argv
            return
        end
    end
    echo "extract: no 7-Zip found (install sevenzip / 7zip / p7zip)" >&2
    return 1
end

# Extract archives
function extract
    if test -f $argv[1]
        switch $argv[1]
            case '*.tar.bz2'
                tar xjf $argv[1]
            case '*.tar.gz'
                tar xzf $argv[1]
            case '*.bz2'
                bunzip2 $argv[1]
            case '*.rar'
                if command -q unrar
                    unrar x $argv[1]
                else
                    __extract_7zip $argv[1]
                end
            case '*.gz'
                gunzip $argv[1]
            case '*.tar'
                tar xf $argv[1]
            case '*.tbz2'
                tar xjf $argv[1]
            case '*.tgz'
                tar xzf $argv[1]
            case '*.zip'
                unzip $argv[1]
            case '*.Z'
                uncompress $argv[1]
            case '*.7z'
                __extract_7zip $argv[1]
            case '*'
                echo "'$argv[1]' cannot be extracted via extract()"
        end
    else
        echo "'$argv[1]' is not a valid file"
    end
end

# Git aliases as functions
function gst
    git status
end

function gco
    git checkout $argv
end

function gcb
    git checkout -b $argv
end

function gaa
    git add --all
end

function gcm
    git commit -m "$argv"
end

function gp
    git push
end

function gl
    git pull
end

function glog
    git log --oneline --decorate --graph
end

# Smart just: the nearest justfile (here or in a parent dir), else the
# global one — same as zsh's and PowerShell's j (completions/j.fish)
function j --description 'just, falling back to the global justfile'
    if just --summary >/dev/null 2>&1
        just $argv
    else
        just --global-justfile $argv
    end
end

function ai
    set -l assistant $AI_ASSISTANT
    if test -z "$assistant"
        set assistant opencode
    end
    set -l cmd (string split " " -- $assistant)
    command $cmd $argv
end
