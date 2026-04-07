-- Ruff's built-in language server: lint diagnostics plus code actions
-- (fix all, organize imports). Hover is left to pyright (see LspAttach).
return {
  cmd = { "ruff", "server" },
  filetypes = { "python" },
  root_markers = { "pyproject.toml", "ruff.toml", ".ruff.toml", ".git" },
}
