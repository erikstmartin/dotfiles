return {
  -- {
  --   "habamax/vim-godot",
  --   enabled = true,
  --
  --   init = function()
  --     vim.g.godot_executable =
  --       "C:\\Program Files\\Godot\\Godot_v4.3-stable_mono_win64\\Godot_v4.3-stable_mono_win64.exe"
  --   end,
  -- },
  {
    "upperhands/godot-neovim",
    init = function()
      vim.keymap.set("n", "<leader>Gm", ":terminal ls", { desc = "[G]odot Run [M]ain Scene" })
    end,
    opts = {
      godot_executable = "'C:\\\\Program Files\\\\Godot\\\\Godot_v4.3-stable_mono_win64\\\\Godot_v4.3-stable_mono_win64.exe'",
      use_default_keymaps = true, -- set to false to disable keymaps below
      keymaps = {
        GdRunMainScene = "<leader>xm", -- run main scene
        GdRunLastScene = "<leader>xl", -- run the most recently executed scene
        GdRunSelectScene = "<leader>xs", -- show all scenes, and run selected
        GdShowDocumentation = "g<C-d>", -- open the documentation for the symbol under cursor in the editor
      },
    },
  },
}
