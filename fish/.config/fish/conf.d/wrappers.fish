# Smart wrappers

# j — use local justfile if present, otherwise global justfile
if command -q just
    function j --wraps just --description "Smart just: local justfile or global"
        if just --justfile justfile --summary &>/dev/null 2>&1
            just $argv
        else
            just --global-justfile $argv
        end
    end
end

