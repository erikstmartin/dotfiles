-- GitHub Copilot (inline completion is enabled in LspAttach, custom/plugins/lsp.lua).
-- Native build from GitHub's release repo, installed by mise.
return {
  cmd = { "copilot-language-server", "--stdio" },
  root_markers = { ".git" },
  filetypes = {
    "c",
    "cpp",
    "cs",
    "css",
    "go",
    "html",
    "javascript",
    "javascriptreact",
    "json",
    "lua",
    "proto",
    "python",
    "ruby",
    "rust",
    "sh",
    "terraform",
    "toml",
    "typescript",
    "typescriptreact",
    "yaml",
  },
  init_options = {
    editorInfo = { name = "Neovim", version = tostring(vim.version()) },
    editorPluginInfo = { name = "Neovim", version = tostring(vim.version()) },
  },
}
