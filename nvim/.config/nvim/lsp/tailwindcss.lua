-- Only start in projects that use Tailwind: a tailwind.config.* (v3), or a
-- tailwindcss / @tailwindcss/* dependency in a package.json (v4 has no
-- config file). Not calling on_dir keeps the server from starting.
local config_files = { "tailwind.config.js", "tailwind.config.cjs", "tailwind.config.mjs", "tailwind.config.ts" }

local function uses_tailwind(package_json)
  local f = io.open(package_json)
  if not f then
    return false
  end
  local content = f:read "*a"
  f:close()
  return content:find('"tailwindcss"', 1, true) ~= nil or content:find('"@tailwindcss/', 1, true) ~= nil
end

return {
  cmd = { "tailwindcss-language-server", "--stdio" },
  filetypes = { "html", "css", "scss", "javascript", "javascriptreact", "typescript", "typescriptreact" },
  root_dir = function(bufnr, on_dir)
    local root = vim.fs.root(bufnr, config_files)
    if root then
      return on_dir(root)
    end
    local name = vim.api.nvim_buf_get_name(bufnr)
    if name == "" then
      return
    end
    -- Nearest first, so a monorepo package that depends on it wins over the root
    for _, pkg in ipairs(vim.fs.find("package.json", { path = vim.fs.dirname(name), upward = true, limit = math.huge })) do
      if uses_tailwind(pkg) then
        return on_dir(vim.fs.dirname(pkg))
      end
    end
  end,
}
