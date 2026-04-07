return {
  cmd = { "pyright-langserver", "--stdio" },
  filetypes = { "python" },
  root_markers = {
    "pyproject.toml",
    "setup.py",
    "setup.cfg",
    "requirements.txt",
    "Pipfile",
    "pyrightconfig.json",
    ".git",
  },
  settings = {
    pyright = {
      -- ruff handles import sorting (lsp/ruff.lua)
      disableOrganizeImports = true,
    },
  },
  -- pyright only uses the `python` on PATH, so point it at the project's .venv.
  -- VIRTUAL_ENV only wins when it's inside root_dir: uv.nvim sets it once per
  -- session, so it would leak into later projects. on_init because the client
  -- copies `settings` before before_init runs.
  on_init = function(client)
    local root = client.root_dir
    local active = vim.env.VIRTUAL_ENV
    local project = root and vim.fs.joinpath(root, ".venv")
    local venv
    if active and root and vim.fs.relpath(root, active) then
      venv = active
    elseif project and vim.uv.fs_stat(project) then
      venv = project
    else
      venv = active
    end
    if not venv then
      return
    end
    local python = vim.fn.has "win32" == 1 and vim.fs.joinpath(venv, "Scripts", "python.exe")
      or vim.fs.joinpath(venv, "bin", "python")
    if vim.uv.fs_stat(python) then
      client.settings = vim.tbl_deep_extend("force", client.settings or {}, {
        python = { pythonPath = python },
      })
      client:notify("workspace/didChangeConfiguration", { settings = client.settings })
    end
  end,
}
