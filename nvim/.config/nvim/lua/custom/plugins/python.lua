return {
  {
    "benomahony/uv.nvim",
    ft = "python",
    config = function()
      require("uv").setup {
        -- Auto-activate virtual environments when found
        auto_activate_venv = true,
        keymaps = false,
      }
    end,
  },
}
