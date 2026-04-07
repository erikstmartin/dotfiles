return {
  {
    "echasnovski/mini.nvim",
    config = function()
      -- Add/delete/replace surroundings (brackets, quotes, etc.)
      --
      -- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
      -- - sd'   - [S]urround [D]elete [']quotes
      -- - sr)'  - [S]urround [R]eplace [)] [']
      require("mini.surround").setup()

      require("mini.pairs").setup()
      require("mini.sessions").setup()

      -- Icon provider (replaces nvim-web-devicons). Requires Nerd Font 3.0+.
      -- Mocking nvim-web-devicons lets bufferline/lualine/snacks
      -- keep working unmodified against the mini.icons API.
      require("mini.icons").setup()
      require("mini.icons").mock_nvim_web_devicons()

      -- ... and there is more!
      --  Check out: https://github.com/echasnovski/mini.nvim
    end,
  },
}
