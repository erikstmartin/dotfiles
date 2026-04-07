return {
  cmd = { "taplo", "lsp", "stdio" },
  filetypes = { "toml" },
  -- taplo reports any file outside its workspace as "this document has been
  -- excluded", so always give it a root: the project, else the file's directory.
  root_dir = function(bufnr, on_dir)
    on_dir(
      vim.fs.root(bufnr, { ".taplo.toml", "taplo.toml", ".git" }) or vim.fs.dirname(vim.api.nvim_buf_get_name(bufnr))
    )
  end,
}
