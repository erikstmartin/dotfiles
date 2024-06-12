return { -- You can easily change to a different colorscheme.
  {
    -- Change the name of the colorscheme plugin below, and then
    -- change the command in the config to whatever the name of that colorscheme is.
    --
    -- If you want to see what colorschemes are already installed, you can use `:Telescope colorscheme`.
    "folke/tokyonight.nvim",
    enabled = false,
    priority = 1000, -- Make sure to load this before all the other start plugins.
    init = function()
      -- Load the colorscheme here.
      -- Like many other themes, this one has different styles, and you could load
      -- any other, such as 'tokyonight-storm', 'tokyonight-moon', or 'tokyonight-day'.
      vim.cmd.colorscheme "habamax"

      -- You can configure highlights by doing something like:
      vim.cmd.hi "Comment gui=none"
    end,
  },
  {
    "RRethy/base16-nvim",
    enabled = false,
    init = function()
      vim.cmd.colorscheme "base16-catppuccin"
    end,
  },
  {
    "catppuccin/nvim",
    enabled = true,
    priority = 1000,
    config = function()
      require("catppuccin").setup {
        integrations = {
          cmp = true,
          neotree = true,
          mason = true,
          treesitter = true,
          mini = {
            enabled = true,
            indentscope_color = "",
          },
        },

        color_overrides = {
          all = {
            base = "#14161b", -- background
            mantle = "#181825", -- status line background
            crust = "#11111b", -- ??
            text = "#e0e2ea", -- text
            -- text = "#cdd6f4"     -- text

            rosewater = "#f5e0dc", -- ??
            flamingo = "#f2cdcd", -- ??
            pink = "#f5c2e7", -- ??
            -- mauve = "#cba6f7",   -- ??
            mauve = "#FFCAFF", -- keywords (go, defer, func, etc)
            red = "#f38ba8", -- ??
            maroon = "#eba0ac", -- function args
            peach = "#fab387", -- builtin literals / make
            yellow = "#f9e2af", -- types
            green = "#b3f6c0", -- strings
            teal = "#94e2d5", -- ??
            sky = "#89dceb", -- TODOs
            sapphire = "#74c7ec", -- ??
            blue = "#8CF8F7", -- function call
            lavender = "#A6DBFF", -- properties
            -- lavender = "#8CF8F7", -- properties
            subtext1 = "#bac2de", -- ??
            subtext0 = "#a6adc8", -- ??
            overlay2 = "#9399b2", -- parenthesis
            overlay1 = "#7f849c", -- ??
            overlay0 = "#6c7086", -- comments
            surface2 = "#585b70", -- ??
            surface1 = "#45475a", -- line numbers
            surface0 = "#313244", -- current line background
          },
        },
      }
    end,
    init = function()
      vim.cmd.colorscheme "catppuccin"
    end,
  },
}
