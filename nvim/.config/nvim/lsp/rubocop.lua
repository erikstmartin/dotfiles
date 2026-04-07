-- Global RuboCop as a linter, only for projects that configure it but don't
-- bundle it: when the bundle has rubocop, ruby-lsp already runs that version
-- (and its plugins), so starting this too would duplicate every diagnostic.
local ruby = require "custom.ruby"

return {
  cmd = { "rubocop", "--lsp" },
  filetypes = { "ruby" },
  root_dir = function(bufnr, on_dir)
    local root = vim.fs.root(bufnr, ".rubocop.yml")
    if root and not ruby.bundles(ruby.root(bufnr), "rubocop") then
      on_dir(root)
    end
  end,
}
