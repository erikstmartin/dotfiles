return {
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {},
    keys = {
      { "<leader>fs", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "[F]ind: Flash jump ([s])" },
      { "<leader>fS", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "[F]ind: Flash Treesitter ([S])" },
      { "r", mode = "o", function() require("flash").remote() end, desc = "Flash: Remote" },
      -- Visual R intentionally replaces the built-in (replace whole lines)
      { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Flash: Treesitter Search" },
    },
  },
  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {
      settings = {
        save_on_toggle = true,
        -- Scope marks per git repo (falls back to cwd outside a repo)
        key = function()
          return vim.fs.root(0, ".git") or vim.uv.cwd()
        end,
      },
    },
    keys = {
      {
        "<leader>mm",
        function()
          local list = require("harpoon"):list()
          local item = list.config.create_list_item(list.config)
          if list:get_by_value(item.value) then
            list:remove(item)
          else
            list:add(item)
          end
        end,
        desc = "[M]arks: Toggle file tag",
      },
      {
        "<leader>mt",
        function()
          local harpoon = require("harpoon")
          harpoon.ui:toggle_quick_menu(harpoon:list())
        end,
        desc = "[M]arks: Toggle tags window",
      },
      { "<leader>mn", function() require("harpoon"):list():next { ui_nav_wrap = true } end, desc = "[M]arks: Next tag" },
      { "<leader>mp", function() require("harpoon"):list():prev { ui_nav_wrap = true } end, desc = "[M]arks: Prev tag" },
    },
  },
}
