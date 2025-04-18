--- Walks up from cwd looking for project.godot to detect Godot projects.
local function is_godot_project()
  return vim.fn.findfile("project.godot", ".;") ~= ""
end

local godot_project = is_godot_project()

return {
  -- Godot integration: debugging, Neovim server pipe for Godot↔Neovim communication
  {
    "lommix/godot.nvim",
    -- In a Godot project, load eagerly so the server pipe starts immediately
    -- (allows Godot's external editor to --remote-send before any .gd file is opened).
    -- Outside a Godot project, stay lazy and only load on filetype or command.
    lazy = not godot_project,
    ft = { "gdscript", "gdshader", "gdresource" },
    cmd = { "GodotDebug", "GodotBreakAtCursor", "GodotStep", "GodotQuit", "GodotContinue" },
    dependencies = { "mfussenegger/nvim-dap" },
    opts = {
      bin = "godot",
      pipepath = vim.fn.stdpath("cache") .. "/godot.pipe",
    },
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
