return {
  -- NOTE: Plugins can be added with a link (or for a github repo: 'owner/repo' link).
  "tpope/vim-sleuth", -- Detect tabstop and shiftwidth automatically

  -- NOTE: Plugins can also be added by using a table,
  -- with the first argument being the link and the following
  -- keys can be used to configure plugin behavior/loading/etc.
  --
  -- Use `opts = {}` to force a plugin to be loaded.
  --
  --  This is equivalent to:
  --    require('Comment').setup({})

  -- Here is a more advanced example where we pass configuration
  -- options to `gitsigns.nvim`. This is equivalent to the following Lua:
  --    require('gitsigns').setup({ ... })
  --
  -- See `:help gitsigns` to understand what the configuration keys do
  { -- Adds git related signs to the gutter, as well as utilities for managing changes
    "lewis6991/gitsigns.nvim",
    opts = {
      signs = {
        add = { text = "+" },
        change = { text = "~" },
        delete = { text = "_" },
        topdelete = { text = "‾" },
        changedelete = { text = "~" },
      },
    },
  },
  {
    "sindrets/diffview.nvim",
    keys = {
      {
        "<leader>gdb",
        "<cmd>DiffviewOpen<cr>",
        desc = "[G]it: [D]iff [B]ranch",
      },
      {
        "<leader>gD",
        "<cmd>DiffviewClose<cr>",
        desc = "[G]it: [D]iff Close",
      },
      {
        "<leader>gdf",
        "<cmd>DiffviewFileHistory<cr>",
        desc = "[G]it: [D]iff [F]ile",
      },
      {
        "<leader>gdp",
        function()
          Snacks.input({ prompt = "Prompt: " }, function(input)
            if input then
              vim.cmd("DiffviewOpen " .. input)
            end
          end)
        end,
        desc = "[G]it: [D]iff [P]rompt (branch)",
      },
      {
        "<leader>gdP",
        function()
          Snacks.input({ prompt = "Prompt: " }, function(input)
            if input then
              vim.cmd("DiffviewFileHistory " .. input)
            end
          end)
        end,
        desc = "[G]it: [D]iff [P]rompt (file)",
      },
    },
  },
  { -- Useful plugin to show you pending keybinds.
    "folke/which-key.nvim",
    event = "VimEnter", -- Sets the loading event to 'VimEnter'
    enabled = true,
    config = function() -- This is the function that runs, AFTER loading
      require("which-key").setup {
        preset = "helix",
        plugins = {
          marks = true, -- shows a list of your marks on ' and `
          registers = true, -- shows your registers on " in NORMAL or <C-r> in INSERT mode
          -- the presets plugin, adds help for a bunch of default keybindings in Neovim
          -- No actual key bindings are created
          spelling = {
            enabled = true, -- enabling this will show WhichKey when pressing z= to select spelling suggestions
            suggestions = 20, -- how many suggestions should be shown in the list?
          },
          presets = {
            operators = true, -- adds help for operators like d, y, ...
            motions = true, -- adds help for motions
            text_objects = true, -- help for text objects triggered after entering an operator
            windows = true, -- default bindings on <c-w>
            nav = true, -- misc bindings to work with windows
            z = true, -- bindings for folds, spelling and others prefixed with z
            g = true, -- bindings for prefixed with g
          },
        },
        show_keys = true, -- show the currently pressed key and its label as a message in the command line
        -- triggers = {"<leader>"} -- or specify a list manually
        -- disable the WhichKey popup for certain buf types and file types.
        -- Disabled by default for Telescope
        disable = {
          buftypes = {},
          filetypes = {},
        },
        sort = { "local", "order", "alphanum", "mod", "group" },
      }

      -- Document existing key chains
      require("which-key").add {
        { "<leader>a", group = "[A]I", mode = { "v", "n" } },
        { "<leader>d", group = "[D]iagnostics" },
        { "<leader>f", group = "[F]ind" },
        { "<leader>g", group = "[G]it" },
        { "<leader>gd", group = "[G]it [D]iff" },
        { "<leader>G", group = "[G]odot" },
        { "<leader>l", group = "[L]SP" },
        { "<leader>r", group = "[R]EPL", mode = { "v", "n" } },
        { "<leader>t", group = "[T]erminal", mode = { "v", "n" } },
      }
    end,
  },
  {
    "folke/todo-comments.nvim",
    event = "VimEnter",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = { signs = false },
  },
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    keys = {
      -- Terminal
      {
        "<leader>tt",
        function()
          require("snacks").terminal.toggle()
        end,
        desc = "[T]erminal [T]oggle",
      },
      {
        "<leader>tt",
        function()
          require("snacks").terminal.toggle()
        end,
        desc = "[T]erminal [T]oggle",
      },
      {
        "<leader>tl",
        function()
          require("snacks").terminal.toggle(vim.fn.getline ".", { auto_close = false })
        end,
        desc = "[T]erminal Execute [L]ine",
      },
      {
        "<leader>ts",
        function()
          local _, ls, cs = unpack(vim.fn.getpos "v")
          local _, le, ce = unpack(vim.fn.getpos ".")
          local selected_text = vim.api.nvim_buf_get_text(0, ls - 1, cs - 1, le - 1, ce, {})

          require("snacks").terminal.toggle(selected_text)
        end,
        desc = "[T]erminal Execute [S]election",
        mode = "v",
      },
      -- Explorer
      {
        "\\",
        function()
          require("snacks").explorer()
        end,
        desc = "Explorer Toggle",
      },
      -- Gitbrowse
      {
        "<leader>go",
        function()
          require("snacks").gitbrowse()
        end,
        desc = "[G]it: [O]pen",
      },
      -- Pickers
      {
        "<leader>fb",
        function()
          require("snacks").picker.buffers()
        end,
        desc = "[F]ind: [B]uffer",
      },
      {
        "<leader>fT",
        function()
          require("snacks").picker.colorschemes()
        end,
        desc = "[F]ind: [T]heme",
      },
      {
        "<leader>fc",
        function()
          require("snacks").picker.command_history()
        end,
        desc = "[F]ind: [C]ommand History",
      },
      {
        "<leader>fC",
        function()
          require("snacks").picker.commands()
        end,
        desc = "[F]ind: [C]ommand",
      },
      {
        "<leader>fd",
        function()
          require("snacks").picker.diagnostics()
        end,
        desc = "[F]ind: [D]iagnostic (all)",
      },
      {
        "<leader>df",
        function()
          require("snacks").picker.diagnostics()
        end,
        desc = "[D]iagnostics: [F]ind (all)",
      },
      {
        "<leader>fD",
        function()
          require("snacks").picker.diagnostics_buffer()
        end,
        desc = "[F]ind: [D]iagnostic (buffer)",
      },
      {
        "<leader>dF",
        function()
          require("snacks").picker.diagnostics_buffer()
        end,
        desc = "[D]iagnostics: [F]ind (buffer)",
      },
      {
        "<leader>ff",
        function()
          require("snacks").picker.smart()
        end,
        desc = "[F]ind: [F]iles",
      },
      {
        "<leader><leader>",
        function()
          require("snacks").picker.smart()
        end,
        desc = "[F]ind: [F]iles",
      },
      {
        "<leader>fF",
        function()
          require("snacks").picker.git_files()
        end,
        desc = "[F]ind: [F]iles (git)",
      },
      {
        "<leader>fh",
        function()
          require("snacks").picker.help()
        end,
        desc = "[F]ind: [H]elp",
      },
      {
        "<leader>fj",
        function()
          require("snacks").picker.jumps()
        end,
        desc = "[F]ind: [J]umps",
      },
      {
        "<leader>fk",
        function()
          require("snacks").picker.keymaps()
        end,
        desc = "[F]ind: [K]eymaps",
      },
      {
        "<leader>fl",
        function()
          require("snacks").picker.loclist()
        end,
        desc = "[F]ind: [L]oclist",
      },
      {
        "<leader>fL",
        function()
          require("snacks").picker.lines()
        end,
        desc = "[F]ind: [L]ines",
      },
      {
        "<leader>fM",
        function()
          require("snacks").picker.man()
        end,
        desc = "[F]ind: [M]an",
      },
      {
        "<leader>fn",
        function()
          require("snacks").picker.notifications()
        end,
        desc = "[F]ind: [N]otifications",
      },
      {
        "<leader>fp",
        function()
          require("snacks").picker.projects()
        end,
        desc = "[F]ind: [P]rojects",
      },
      {
        "<leader>fP",
        function()
          require("snacks").picker.pickers()
        end,
        desc = "[F]ind: [P]ickers",
      },
      {
        "<leader>fm",
        function()
          require("snacks").picker.marks()
        end,
        desc = "[F]ind: [M]arks",
      },
      {
        "<leader>fq",
        function()
          require("snacks").picker.qflist()
        end,
        desc = "[F]ind: [Q]uickfix",
      },
      {
        "<leader>fr",
        function()
          require("snacks").picker.recent()
        end,
        desc = "[F]ind: [R]ecent",
      },
      {
        "<leader>fR",
        function()
          require("snacks").picker.registers()
        end,
        desc = "[F]ind: [R]egisters",
      },
      {
        "<leader>fs",
        function()
          require("snacks").picker.search_history()
        end,
        desc = "[F]ind: [S]earch History",
      },
      {
        "<leader>ft",
        function()
          require("snacks").picker.treesitter()
        end,
        desc = "[F]ind: [T]reesitter",
      },
      {
        "<leader>fu",
        function()
          require("snacks").picker.undo()
        end,
        desc = "[F]ind: [U]ndo",
      },
      {
        "<leader>fz",
        function()
          require("snacks").picker.zoxide()
        end,
        desc = "[F]ind: [Z]oxide",
      },
      {
        "<leader>lr",
        function()
          require("snacks").picker.lsp_references()
        end,
        desc = "[L]sp: [R]eferences",
      },
      {
        "<leader>ls",
        function()
          require("snacks").picker.lsp_workspace_symbols()
        end,
        desc = "[L]sp: [S]ymbols",
      },
      {
        "<leader>lS",
        function()
          require("snacks").picker.lsp_symbols()
        end,
        desc = "[L]sp: [S]ymbols",
      },
      {
        "<leader>g/",
        function()
          require("snacks").picker.git_grep()
        end,
        desc = "[G]it: Grep",
      },
      {
        "<leader>/",
        function()
          require("snacks").picker.grep()
        end,
        desc = "Grep",
      },
      {
        "<leader>gl",
        function()
          require("snacks").picker.git_log()
        end,
        desc = "[G]it: [L]og (branch)",
      },
      {
        "<leader>gL",
        function()
          require("snacks").picker.git_log_file()
        end,
        desc = "[G]it: [L]og (file)",
      },
      {
        "<leader>g<C-l>",
        function()
          require("snacks").picker.git_log_line()
        end,
        desc = "[G]it: [L]og (line)",
      },
      {
        "<leader>gs",
        function()
          require("snacks").picker.git_status()
        end,
        desc = "[G]it: [S]tatus",
      },
      {
        "<leader>gS",
        function()
          require("snacks").picker.git_stash()
        end,
        desc = "[G]it: [S]tash",
      },
    },
    ---@type snacks.Config
    opts = {
      bigfile = { enabled = true },
      dashboard = {
        enabled = true,
        preset = {
          keys = {
            { icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.dashboard.pick('files')" },
            { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
            { icon = " ", key = "g", desc = "Find Text", action = ":lua Snacks.dashboard.pick('live_grep')" },
            { icon = " ", key = "r", desc = "Recent Files", action = ":lua Snacks.dashboard.pick('oldfiles')" },
            {
              icon = " ",
              key = "c",
              desc = "Config",
              action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})",
            },
            { icon = " ", key = "s", desc = "Restore Session", section = "session" },
            { icon = "󰒲 ", key = "L", desc = "Lazy", action = ":Lazy", enabled = package.loaded.lazy ~= nil },
            { icon = " ", key = "M", desc = "Mason", action = ":Mason", enabled = package.loaded.lazy ~= nil },
            { icon = " ", key = "q", desc = "Quit", action = ":qa" },
          },
        },
        sections = {
          { section = "header" },
          { section = "keys", gap = 1, padding = 1 },
          { pane = 2, icon = " ", title = "Recent Files", section = "recent_files", indent = 2, padding = 1 },
          { pane = 2, icon = " ", title = "Projects", section = "projects", indent = 2, padding = 1 },
          {
            pane = 2,
            icon = " ",
            title = "Git Status",
            section = "terminal",
            enabled = function()
              return Snacks.git.get_root() ~= nil
            end,
            cmd = "git status --short --branch --renames",
            height = 15,
            padding = 1,
            ttl = 5 * 60,
            indent = 3,
          },
          { section = "startup" },
          false,
        },
      },
      debug = { enabled = true },
      explorer = {
        enabled = true,
        replace_netrw = true,
      },
      git = { enabled = true },
      gitbrowse = { enabled = true },
      image = { enabled = true },
      indent = { enabled = false },
      input = { enabled = true },
      layout = { enabled = true },
      notifier = {
        enabled = true,
        timeout = 3000,
      },
      picker = {
        enabled = true,
        win = {
          input = {
            keys = {
              ["<c-l>"] = { "loclist", mode = { "i", "n" } },
            },
          },
          list = {
            keys = {
              ["<c-l>"] = { "loclist", mode = { "i", "n" } },
            },
          },
        },
      },
      quickfile = { enabled = true },
      scope = { enabled = true },
      scroll = { enabled = false },
      statuscolumn = { enabled = false },
      terminal = { enabled = true },
      toggle = { enabled = false },
      win = { enabled = false },
      words = { enabled = true },
      -- styles = {
      --   notification = {
      --     wo = { wrap = true }, -- Wrap notifications
      --   },
      -- },
    },
  },
  -- "ElPiloto/sidekick.nvim",
}
