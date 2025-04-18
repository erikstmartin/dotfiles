# Just Global Justfile
set -gx JUST_GLOBAL_JUSTFILE "$HOME/.config/just/justfile"

if test (uname) = Darwin
    set -gx CC /opt/homebrew/opt/llvm/bin/clang
    set -gx CXX /opt/homebrew/opt/llvm/bin/clang++
    set -gx CLANGXX /opt/homebrew/opt/llvm/bin/clang++
else if test (uname) = Linux
    set -gx CC clang
    set -gx CXX clang++
    set -gx CLANGXX clang++
end