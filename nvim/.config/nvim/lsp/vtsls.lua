-- TypeScript/JavaScript LSP (wraps VSCode's TS extension)
return {
  cmd = { "vtsls", "--stdio" },
  filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
  root_markers = { "tsconfig.json", "jsconfig.json", "package.json", ".git" },
  settings = {
    typescript = {
      referencesCodeLens = { enabled = true, showOnAllFunctions = true },
      implementationsCodeLens = { enabled = true },
    },
    javascript = {
      referencesCodeLens = { enabled = true, showOnAllFunctions = true },
    },
  },
}
