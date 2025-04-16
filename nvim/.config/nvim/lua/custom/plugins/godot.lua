return {
  {
    "upperhands/godot-neovim",
    ft = { "gdscript", "gd", "gdscript3" },
    keys = {
      {
        "<leader>Gm",
        "<cmd>GdRunMainScene<cr>",
        desc = "[G]odot [M]ain Scene",
        ft = { "gdscript", "gd", "gdscript3" },
      },
      {
        "<leader>Gl",
        "<cmd>GdRunLastScene<cr>",
        desc = "[G]odot [L]ast Scene",
        ft = { "gdscript", "gd", "gdscript3" },
      },
      {
        "<leader>Gs",
        "<cmd>GdRunSelectScene<cr>",
        desc = "[G]odot [S]elect Scene",
        ft = { "gdscript", "gd", "gdscript3" },
      },
      {
        "<leader>Gd",
        "<cmd>GdShowDocumentation<cr>",
        desc = "[G]odot [D]ocumentation",
        ft = { "gdscript", "gd", "gdscript3" },
      },
    },
    opts = {
      godot_executable = "'C:\\\\Program Files\\\\Godot\\\\Godot_v4.3-stable_mono_win64\\\\Godot_v4.3-stable_mono_win64.exe'",
      use_default_keymaps = false, -- set to false to disable keymaps below
      keymaps = {
        GdRunMainScene = "<leader>Gm", -- run main scene
        GdRunLastScene = "<leader>Gl", -- run the most recently executed scene
        GdRunSelectScene = "<leader>Gs", -- show all scenes, and run selected
        GdShowDocumentation = "<leader>Gd", -- open the documentation for the symbol under cursor in the editor
      },
    },
  },
}
