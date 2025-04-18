# Smart just wrapper - use local justfile if exists, otherwise global
function j --description "Smart just command wrapper"
    if just --justfile justfile --summary >/dev/null 2>&1
        just $argv
    else
        just --global-justfile $argv
    end
end