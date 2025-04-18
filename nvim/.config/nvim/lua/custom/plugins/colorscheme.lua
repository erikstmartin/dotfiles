return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    lazy = false,
    config = function()
      require("catppuccin").setup({
        flavour = "mocha",
        color_overrides = {
          mocha = {
            base   = "#11111b",
            mantle = "#0d0d17",
            crust  = "#0a0a12",
          },
        },
        custom_highlights = function(colors)
          return {
            DiffviewDiffAdd        = { bg = "#1a3330" },
            DiffviewDiffAddDim     = { bg = "#142926" },
            DiffviewDiffChange     = { bg = "#1a2a40" },
            DiffviewDiffChangeDim  = { bg = "#142135" },
            DiffviewDiffDeleteDim  = { fg = colors.surface0, bg = colors.base },
            DiffText               = { bg = "#243f66" },
            WhichKeyDesc           = { fg = colors.text },
          }
        end,
        integrations = {
          bufferline = true,
          lualine    = {},
          treesitter = true,
          telescope  = { enabled = true },
          which_key  = true,
          indent_blankline = { enabled = true },
          snacks = true,
          mini = { enabled = true },
        },
      })
      vim.cmd.colorscheme("catppuccin")
    end,
  },
}
