-- golangci-lint as an LSP: lints asynchronously on open/save (nvim-lint's
-- golangcilint runs `golangci-lint version` synchronously on load)
return {
  cmd = { "golangci-lint-langserver" },
  filetypes = { "go", "gomod" },
  root_markers = {
    ".golangci.yml",
    ".golangci.yaml",
    ".golangci.toml",
    ".golangci.json",
    "go.work",
    "go.mod",
    ".git",
  },
  init_options = {
    command = { "golangci-lint", "run", "--output.json.path=stdout", "--show-stats=false" },
  },
}
