return {
  cmd = { "lua-language-server" },
  filetypes = { "lua" },
  root_markers = { ".luarc.json", ".luarc.jsonc", ".stylua.toml", "stylua.toml", "selene.toml", ".git" },
  settings = {
    Lua = {
      completion = {
        callSnippet = "Replace",
      },
      -- You can toggle below to ignore Lua_LS's noisy `missing-fields` warnings
      -- diagnostics = { disable = { 'missing-fields' } },
      -- (`vim` and the API types come from lazydev, custom/plugins/lsp.lua)
    },
  },
}
