-- Godot's built-in language server over TCP, only up while the editor runs:
-- start only when something is listening, else every .gd file warns "Could not
-- connect" (:e the file after starting Godot).
-- Port: Editor Settings > Network > Language Server.
local port = tonumber(vim.env.GDSCRIPT_PORT) or 6005

--- Quick TCP probe (vim.uv works the same on Linux, macOS and Windows)
local function godot_listening()
  local tcp = vim.uv.new_tcp()
  if not tcp then
    return false
  end
  local done, ok = false, false
  tcp:connect("127.0.0.1", port, function(err)
    ok, done = not err, true
    if not tcp:is_closing() then
      tcp:close()
    end
  end)
  vim.wait(200, function()
    return done
  end, 10)
  if not tcp:is_closing() then
    tcp:close()
  end
  return ok
end

return {
  cmd = vim.lsp.rpc.connect("127.0.0.1", port),
  filetypes = { "gdscript" },
  root_dir = function(bufnr, on_dir)
    local root = vim.fs.root(bufnr, "project.godot")
    if root and godot_listening() then
      on_dir(root)
    end
  end,
}
