return {
  "stevearc/quicker.nvim",
  event = "FileType qf",
  ---@module "quicker"
  ---@type quicker.SetupOptions
  opts = {
    keys = {
      {
        ">",
        function()
          require("quicker").expand { before = 4, after = 4, add_to_existing = true }
        end,
        desc = "Expand quickfix context",
      },
      {
        "<",
        function()
          require("quicker").collapse()
        end,
        desc = "Collapse quickfix context",
      },
    },
  },
}
