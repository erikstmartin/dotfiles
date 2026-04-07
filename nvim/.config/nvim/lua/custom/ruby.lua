-- Ruby project helpers shared by LSP (lsp/rubocop.lua, lsp/ruby_lsp.lua),
-- formatting (conform) and debugging (dap)
local M = {}

--- Project root: where the Gemfile is, else the git root
---@param source integer|string buffer or path
function M.root(source)
  return vim.fs.root(source, { "Gemfile", ".git" })
end

--- Does the project's bundle include `gem` (listed in Gemfile.lock)?
---@param root string?
---@param gem string
function M.bundles(root, gem)
  local lock = root and vim.fs.joinpath(root, "Gemfile.lock")
  if not lock or not vim.uv.fs_stat(lock) then
    return false
  end
  for line in io.lines(lock) do
    if line == "    " .. gem or line:find("^    " .. vim.pesc(gem) .. " %(") then
      return true
    end
  end
  return false
end

--- Prefix a command with `bundle exec` in projects with a Gemfile
---@param root string?
---@param cmd string[]
function M.exec(root, cmd)
  if root and vim.uv.fs_stat(vim.fs.joinpath(root, "Gemfile")) then
    return vim.list_extend({ "bundle", "exec" }, cmd)
  end
  return cmd
end

--- Does the project use RuboCop (bundled, or configured with .rubocop.yml)?
---@param source integer|string
function M.uses_rubocop(source)
  return M.bundles(M.root(source), "rubocop") or vim.fs.root(source, ".rubocop.yml") ~= nil
end

return M
