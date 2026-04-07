--- Walks up from cwd looking for project.godot to detect Godot projects.
local function is_godot_project()
  return vim.fn.findfile("project.godot", ".;") ~= ""
end

local godot_project = is_godot_project()

--- Finds the Godot executable on Linux, macOS and Windows. Prefers the .NET
--- (mono) build when the project has a .csproj. Override with $GODOT_BIN.
local function godot_bin()
  if vim.env.GODOT_BIN and vim.fn.executable(vim.env.GODOT_BIN) == 1 then
    return vim.env.GODOT_BIN
  end

  local csharp = vim.fn.glob(vim.fn.getcwd() .. "/*.csproj") ~= ""
  local function prefer_mono(list)
    table.sort(list, function(a, b)
      local am, bm = a:lower():find "mono" ~= nil, b:lower():find "mono" ~= nil
      if am ~= bm then
        return am == csharp
      end
      return a < b
    end)
    return list
  end

  -- On PATH: Linux packages, mise, scoop/winget shims on Windows
  for _, name in ipairs(prefer_mono { "godot", "godot4", "godot-mono", "godot4-mono" }) do
    if vim.fn.executable(name) == 1 then
      return vim.fn.exepath(name)
    end
  end

  local home = vim.uv.os_homedir()
  local candidates = {}
  if vim.fn.has "mac" == 1 then
    for _, dir in ipairs { "/Applications", home .. "/Applications" } do
      vim.list_extend(candidates, vim.fn.glob(dir .. "/Godot*.app/Contents/MacOS/Godot", false, true))
    end
  elseif vim.fn.has "win32" == 1 then
    local patterns = {
      home .. "/scoop/apps/godot*/current/*.exe",
      (vim.env.LOCALAPPDATA or "") .. "/Microsoft/WinGet/Packages/GodotEngine.GodotEngine*/*.exe",
      (vim.env.LOCALAPPDATA or "") .. "/Microsoft/WinGet/Packages/GodotEngine.GodotEngine*/*/*.exe",
      (vim.env.ProgramFiles or "") .. "/Godot*/*.exe",
    }
    for _, pattern in ipairs(patterns) do
      for _, exe in ipairs(vim.fn.glob(pattern, false, true)) do
        if not exe:find "_console" then -- skip the console wrapper builds
          table.insert(candidates, exe)
        end
      end
    end
  else
    candidates = {
      home .. "/.local/share/flatpak/exports/bin/org.godotengine.Godot",
      "/var/lib/flatpak/exports/bin/org.godotengine.Godot",
    }
  end

  for _, path in ipairs(prefer_mono(candidates)) do
    if vim.fn.executable(path) == 1 then
      return path
    end
  end
  return "godot"
end

return {
  -- Godot integration: debugging, Neovim server pipe for Godot↔Neovim communication
  {
    "lommix/godot.nvim",
    -- Load eagerly in a Godot project so the server pipe exists before any .gd
    -- file is opened (Godot's external editor may --remote-send to it)
    lazy = not godot_project,
    ft = { "gdscript", "gdshader", "gdresource" },
    cmd = { "GodotDebug", "GodotBreakAtCursor", "GodotStep", "GodotQuit", "GodotContinue" },
    dependencies = { "mfussenegger/nvim-dap" },
    opts = function()
      return {
        bin = godot_bin(),
        -- Windows needs a named pipe; elsewhere a socket file in the cache dir.
        -- Use the same path in Godot's external editor settings (--server <path>).
        pipepath = vim.fn.has "win32" == 1 and [[\\.\pipe\godot.pipe]] or vim.fn.stdpath "cache" .. "/godot.pipe",
      }
    end,
  },

  -- GDScript extended LSP: in-editor Godot documentation, class browsing
  {
    "teatek/gdscript-extended-lsp.nvim",
    ft = { "gdscript" },
    opts = {
      picker = "snacks",
      view_type = "vsplit",
    },
  },
}
