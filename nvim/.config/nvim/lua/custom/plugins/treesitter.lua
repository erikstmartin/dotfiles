return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    dependencies = {
      "nvim-treesitter/nvim-treesitter-textobjects",
    },
    config = function()
      require("nvim-treesitter.install").prefer_git = true

      vim.api.nvim_create_autocmd("FileType", {
        pattern = "*",
        callback = function()
          local ok = pcall(vim.treesitter.start)
          if not ok then
            vim.bo.indentexpr = ""
          end
        end,
      })

      require("nvim-treesitter-textobjects").setup({
        move = { set_jumps = true },
      })

      local move = require("nvim-treesitter-textobjects.move")
      local select = require("nvim-treesitter-textobjects.select")
      local swap = require("nvim-treesitter-textobjects.swap")
      local ts_repeat_move = require("nvim-treesitter-textobjects.repeatable_move")

      vim.keymap.set({ "x", "o" }, "af", function() select.select_textobject("@function.outer", "textobjects") end, { desc = "around function" })
      vim.keymap.set({ "x", "o" }, "if", function() select.select_textobject("@function.inner", "textobjects") end, { desc = "inside function" })
      vim.keymap.set({ "x", "o" }, "ac", function() select.select_textobject("@class.outer", "textobjects") end, { desc = "around class" })
      vim.keymap.set({ "x", "o" }, "ic", function() select.select_textobject("@class.inner", "textobjects") end, { desc = "inside class" })
      vim.keymap.set({ "x", "o" }, "aa", function() select.select_textobject("@parameter.outer", "textobjects") end, { desc = "around argument" })
      vim.keymap.set({ "x", "o" }, "ia", function() select.select_textobject("@parameter.inner", "textobjects") end, { desc = "inside argument" })
      vim.keymap.set({ "x", "o" }, "ai", function() select.select_textobject("@conditional.outer", "textobjects") end, { desc = "around conditional" })
      vim.keymap.set({ "x", "o" }, "ii", function() select.select_textobject("@conditional.inner", "textobjects") end, { desc = "inside conditional" })
      vim.keymap.set({ "x", "o" }, "al", function() select.select_textobject("@loop.outer", "textobjects") end, { desc = "around loop" })
      vim.keymap.set({ "x", "o" }, "il", function() select.select_textobject("@loop.inner", "textobjects") end, { desc = "inside loop" })
      vim.keymap.set({ "x", "o" }, "ab", function() select.select_textobject("@block.outer", "textobjects") end, { desc = "around block" })
      vim.keymap.set({ "x", "o" }, "ib", function() select.select_textobject("@block.inner", "textobjects") end, { desc = "inside block" })

      vim.keymap.set({ "n", "x", "o" }, "]f", function() move.goto_next_start("@function.outer", "textobjects") end, { desc = "Next function start" })
      vim.keymap.set({ "n", "x", "o" }, "]c", function() move.goto_next_start("@class.outer", "textobjects") end, { desc = "Next class start" })
      vim.keymap.set({ "n", "x", "o" }, "]a", function() move.goto_next_start("@parameter.outer", "textobjects") end, { desc = "Next argument start" })
      vim.keymap.set({ "n", "x", "o" }, "]F", function() move.goto_next_end("@function.outer", "textobjects") end, { desc = "Next function end" })
      vim.keymap.set({ "n", "x", "o" }, "]C", function() move.goto_next_end("@class.outer", "textobjects") end, { desc = "Next class end" })
      vim.keymap.set({ "n", "x", "o" }, "]A", function() move.goto_next_end("@parameter.outer", "textobjects") end, { desc = "Next argument end" })
      vim.keymap.set({ "n", "x", "o" }, "[f", function() move.goto_previous_start("@function.outer", "textobjects") end, { desc = "Previous function start" })
      vim.keymap.set({ "n", "x", "o" }, "[c", function() move.goto_previous_start("@class.outer", "textobjects") end, { desc = "Previous class start" })
      vim.keymap.set({ "n", "x", "o" }, "[a", function() move.goto_previous_start("@parameter.outer", "textobjects") end, { desc = "Previous argument start" })
      vim.keymap.set({ "n", "x", "o" }, "[F", function() move.goto_previous_end("@function.outer", "textobjects") end, { desc = "Previous function end" })
      vim.keymap.set({ "n", "x", "o" }, "[C", function() move.goto_previous_end("@class.outer", "textobjects") end, { desc = "Previous class end" })
      vim.keymap.set({ "n", "x", "o" }, "[A", function() move.goto_previous_end("@parameter.outer", "textobjects") end, { desc = "Previous argument end" })

      vim.keymap.set("n", "<leader>sa", function() swap.swap_next("@parameter.inner") end, { desc = "Swap with next argument" })
      vim.keymap.set("n", "<leader>sA", function() swap.swap_previous("@parameter.inner") end, { desc = "Swap with previous argument" })

      vim.keymap.set({ "n", "x", "o" }, ";", ts_repeat_move.repeat_last_move_next)
      vim.keymap.set({ "n", "x", "o" }, ",", ts_repeat_move.repeat_last_move_previous)
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter-context",
    event = "BufReadPost",
    opts = {
      enable = true,
      max_lines = 3,
      multiline_threshold = 1,
      exclude = {
        filetypes = { "snacks_dashboard", "lazy", "mason", "help" },
      },
    },
    keys = {
      {
        "[x",
        function()
          require("treesitter-context").go_to_context(vim.v.count1)
        end,
        desc = "Jump to context (upward)",
      },
    },
  },
}
