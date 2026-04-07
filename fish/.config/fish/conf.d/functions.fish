# Custom functions for fish shell

# Create directory and cd into it
function mkcd
    mkdir -p $argv[1]
    cd $argv[1]
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
                unrar x $argv[1]
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
                7z x $argv[1]
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
    git commit -m $argv
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

function ai
    set -l assistant $AI_ASSISTANT
    if test -z "$assistant"
        set assistant opencode
    end
    set -l cmd (string split " " -- $assistant)
    command $cmd $argv
end
