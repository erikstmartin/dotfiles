return {
  {
    "hrsh7th/nvim-cmp",
    lazy = false,
    priority = 100,
    dependencies = {
      "onsails/lspkind.nvim",
      {
        "L3MON4D3/LuaSnip",
        build = (function()
          -- Build Step is needed for regex support in snippets.
          -- This step is not supported in many windows environments.
          -- Remove the below condition to re-enable on windows.
          if vim.fn.has "win32" == 1 or vim.fn.executable "make" == 0 then
            return
          end
          return "make install_jsregexp"
        end)(),
        dependencies = {
          -- `friendly-snippets` contains a variety of premade snippets.
          --    See the README about individual language/framework/plugin snippets:
          --    https://github.com/rafamadriz/friendly-snippets
          {
            "rafamadriz/friendly-snippets",
            config = function()
              require("luasnip.loaders.from_vscode").lazy_load()
            end,
          },
        },
      },
      "saadparwaiz1/cmp_luasnip",

      -- Adds other completion capabilities.
      --  nvim-cmp does not ship with all sources by default. They are split
      --  into multiple repos for maintenance purposes.
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-buffer",
      -- "hrsh7th/cmp-omni",
      -- "delphinus/cmp-ctags",
      "andersevenrud/cmp-tmux",
      -- TODO: Enale only for .vim files?
      -- "hrsh7th/cmp-cmdline",
      -- {
      --   "MattiasMTS/cmp-dbee",
      --   dependencies = {
      --     { "kndndrj/nvim-dbee" },
      --   },
      --   ft = "sql", -- optional but good to have
      --   opts = {}, -- needed
      -- },
      "petertriho/cmp-git",
    },
    config = function()
      require "custom.completion"
    end,
  },
}
