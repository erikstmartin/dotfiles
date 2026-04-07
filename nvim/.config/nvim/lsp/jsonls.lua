return {
  cmd = { "vscode-json-language-server", "--stdio" },
  filetypes = { "json", "jsonc" },
  root_markers = { ".git" },
  settings = {
    json = {
      -- package.json, tsconfig.json, .eslintrc, GitHub workflows, etc.
      schemas = require("schemastore").json.schemas(),
      validate = { enable = true },
    },
  },
}
