return {
  cmd = { "bash-language-server", "start" },
  filetypes = { "sh", "bash" }, -- shellcheck (used by bashls) does not support zsh
  root_markers = { ".git" },
}
