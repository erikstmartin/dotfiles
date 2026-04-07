-- Bicep language server (azure mise module), run with `dotnet`. The install
-- path is looked up lazily from root_dir, which only runs for .bicep buffers.
local dll ---@type string|false|nil false: looked up, not installed

local function find_dll()
  if dll == nil then
    dll = false
    if vim.fn.executable "mise" == 1 and vim.fn.executable "dotnet" == 1 then
      local ok, result = pcall(function()
        return vim.system({ "mise", "where", "github:Azure/bicep" }, { text = true }):wait()
      end)
      local path = ok and result.code == 0 and vim.fs.joinpath(vim.trim(result.stdout), "Bicep.LangServer.dll")
      dll = path and vim.uv.fs_stat(path) and path or false
    end
    if not dll then
      vim.notify("bicep: language server not installed (mise azure module + dotnet)", vim.log.levels.INFO)
    end
  end
  return dll
end

return {
  cmd = function(dispatchers, config)
    return vim.lsp.rpc.start({ "dotnet", assert(find_dll()) }, dispatchers, { cwd = config.root_dir })
  end,
  filetypes = { "bicep", "bicep-params" },
  -- Not calling on_dir keeps the server from starting when it isn't installed
  root_dir = function(bufnr, on_dir)
    if find_dll() then
      on_dir(vim.fs.root(bufnr, { "bicepconfig.json", ".git" }))
    end
  end,
}
