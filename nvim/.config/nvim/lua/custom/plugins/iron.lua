return {
  {
    "Vigemus/iron.nvim",
    cmd = {
      "IronRepl",
      "IronReplHere",
      "IronRestart",
      "IronSend",
      "IronFocus",
      "IronHide",
      "IronWatch",
      "IronAttach",
    },
    keys = {
      {
        "<leader>rt",
        "<cmd>IronFocus<cr>",
        desc = "[R]EPL [T]oggle",
      },
      {
        "<leader>rh",
        "<cmd>IronReplHere<cr>",
        desc = "[R]EPL Here",
      },
      {
        "<leader>rl",
        function()
          require("iron.core").send_line()
        end,
        desc = "[R]EPL Send [L]ine",
      },
      {
        "<leader>rv",
        function()
          require("iron.core").visual_send()
        end,
        mode = { "v" },
        desc = "[R]EPL Send [V]isual",
      },
      {
        "<leader>rf",
        function()
          require("iron.core").send_file()
        end,
        desc = "[R]EPL Send [F]ile",
      },
      {
        "<leader>ru",
        function()
          require("iron.core").send_until_cursor()
        end,
        desc = "[R]EPL Send [U]ntil Cursor",
      },
      {
        "<leader>rp",
        function()
          require("iron.core").send_paragraph()
        end,
        desc = "[R]EPL Send [P]aragraph",
      },
      {
        "<leader>rb",
        function()
          require("iron.core").send_code_block()
        end,
        desc = "[R]EPL Send [B]lock",
      },
      {
        "<leader>rc",
        function()
          require("iron.core").send(nil, string.char(12))
        end,
        desc = "[R]EPL [C]lear",
      },
      {
        "<leader>rr",
        "<cmd>IronRestart<cr>",
        desc = "[R]EPL [R]estart",
      },
      {
        "<leader>rq",
        function()
          require("iron.core").close_repl()
        end,
        desc = "[R]EPL [Q]uit",
      },
    },
    main = "iron.core", -- <== This informs lazy.nvim to use the entrypoint of `iron.core` to load the configuration.
    config = function()
      require("iron.core").setup {
        config = {
          -- Whether a repl should be discarded or not
          scratch_repl = true,
          -- Your repl definitions come here
          repl_definition = {
            sh = {
              -- Can be a table or a function that
              -- returns a table (see below)
              -- command = { "zsh" },
              command = require("iron.fts.sh").zsh.command,
            },
            -- python = {
            --   command = { "python3" }, -- or { "ipython", "--no-autoindent" }
            --   format = require("iron.fts.common").bracketed_paste_python,
            --   block_dividers = { "# %%", "#%%" },
            -- },
          },
          -- set the file type of the newly created repl to ft
          -- bufnr is the buffer id of the REPL and ft is the filetype of the
          -- language being used for the REPL.
          repl_filetype = function(bufnr, ft)
            return ft
            -- or return a string name such as the following
            -- return "iron"
          end,
          -- How the repl window will be displayed
          -- See below for more information
          -- repl_open_cmd = require("iron.view").bottom(40),
          repl_open_cmd = require("iron.view").split.vertical.rightbelow "%30",

          -- repl_open_cmd can also be an array-style table so that multiple
          -- repl_open_commands can be given.
          -- When repl_open_cmd is given as a table, the first command given will
          -- be the command that `IronRepl` initially toggles.
          -- Moreover, when repl_open_cmd is a table, each key will automatically
          -- be available as a keymap (see `keymaps` below) with the names
          -- toggle_repl_with_cmd_1, ..., toggle_repl_with_cmd_k
          -- For example,
          --
          -- repl_open_cmd = {
          --   view.split.vertical.rightbelow("%40"), -- cmd_1: open a repl to the right
          --   view.split.rightbelow("%25")  -- cmd_2: open a repl below
          -- }
        },
        -- Iron doesn't set keymaps by default anymore.
        -- You can set them here or manually add keymaps to the functions in iron.core
        keymaps = {
          -- toggle_repl = "<leader>rr", -- toggles the repl open and closed.
          -- If repl_open_command is a table as above, then the following keymaps are
          -- available
          -- toggle_repl_with_cmd_1 = "<space>rv",
          -- toggle_repl_with_cmd_2 = "<space>rh",
          -- restart_repl = "<leader>rR", -- calls `IronRestart` to restart the repl
          -- send_motion = "<leader>sc",
          -- visual_send = "<leader>sc",
          -- send_file = "<leader>sf",
          -- send_line = "<leader>sl",
          -- send_paragraph = "<leader>sp",
          -- send_until_cursor = "<leader>su",
          -- send_mark = "<leader>sm",
          -- send_code_block = "<leader>sb",
          -- send_code_block_and_move = "<leader>sn",
          -- mark_motion = "<leader>mc",
          -- mark_visual = "<leader>mc",
          -- remove_mark = "<leader>md",
          -- cr = "<leader>s<cr>",
          -- interrupt = "<leader>s<leader>",
          -- exit = "<leader>sq",
          -- clear = "<leader>cl",
        },
        -- If the highlight is on, you can change how it looks
        -- For the available options, check nvim_set_hl
        highlight = {
          italic = true,
        },
        ignore_blank_lines = true, -- ignore blank lines when sending visual select lines
      }
    end,
  },
}
