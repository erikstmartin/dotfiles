return {
  cmd = {
    "clangd",
    "--background-index",
    "--clang-tidy",
    "--completion-style=detailed",
    "--function-arg-placeholders",
    -- Don't auto-insert #includes on completion (wrong for kernel code and
    -- many C projects)
    "--header-insertion=never",
    -- Let clangd ask these compilers for their system include paths when they
    -- appear in compile_commands.json (gcc toolchains, incl. cross compilers)
    "--query-driver=/usr/bin/*gcc*,/usr/bin/*g++*,/usr/bin/*clang*,/usr/local/bin/*gcc*,/usr/local/bin/*g++*,/opt/homebrew/bin/*gcc*,/opt/homebrew/bin/*g++*,/opt/homebrew/opt/llvm/bin/clang*",
  },
  filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
  root_markers = { "compile_commands.json", "compile_flags.txt", ".clangd", "CMakeLists.txt", ".git" },
}
