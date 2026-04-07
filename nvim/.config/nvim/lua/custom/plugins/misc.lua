local pick = require("custom.util").pick

-- Run `cmd` in a fresh terminal every time (Snacks.terminal.toggle would hide
-- an existing one for the same command instead of re-running it)
local function run_in_terminal(cmd)
  local prev = Snacks.terminal.get(cmd, { create = false })
  if prev then
    prev:close()
  end
  Snacks.terminal.open(cmd, { auto_close = false })
end

return {

  { "tpope/vim-sleuth", event = { "BufReadPre", "BufNewFile" } }, -- Detect tabstop and shiftwidth automatically

  { -- Shows pending keybinds
    "folke/which-key.nvim",
    event = "VeryLazy",
    config = function()
      require("which-key").setup {
        preset = "helix",
        sort = { "local", "order", "alphanum", "mod", "group" },
      }

      -- Merge keymaps, buffer-local while the buffer is shown in a diff window
      local merge_maps = {
        { "<leader>gml", "<cmd>diffget LOCAL<CR>", "[G]it [M]erge: get [L]ocal" },
        { "<leader>gmr", "<cmd>diffget REMOTE<CR>", "[G]it [M]erge: get [R]emote" },
        { "<leader>gmb", "<cmd>diffget BASE<CR>", "[G]it [M]erge: get [B]ase" },
        { "<leader>gmL", "<cmd>diffput LOCAL<CR>", "[G]it [M]erge: put [L]ocal" },
        { "<leader>gmR", "<cmd>diffput REMOTE<CR>", "[G]it [M]erge: put [R]emote" },
        { "<leader>gmB", "<cmd>diffput BASE<CR>", "[G]it [M]erge: put [B]ase" },
      }
      local function update_diff_keymaps(buf)
        local in_diff = vim.iter(vim.fn.win_findbuf(buf)):any(function(win)
          return vim.wo[win].diff
        end)
        if (vim.b[buf].diff_keymaps or false) == in_diff then
          return
        end
        vim.b[buf].diff_keymaps = in_diff
        for _, m in ipairs(merge_maps) do
          if in_diff then
            vim.keymap.set("n", m[1], m[2], { buffer = buf, desc = m[3] })
          else
            pcall(vim.keymap.del, "n", m[1], { buffer = buf })
          end
        end
        -- which-key hides the group again once its keys are gone
        if in_diff then
          require("which-key").add { { "<leader>gm", group = "[G]it: [M]erge", buffer = buf } }
        end
      end

      local diff_keymaps_augroup = vim.api.nvim_create_augroup("diff-keymaps", { clear = true })
      vim.api.nvim_create_autocmd("BufWinEnter", {
        group = diff_keymaps_augroup,
        callback = function(event)
          update_diff_keymaps(event.buf)
        end,
      })
      vim.api.nvim_create_autocmd("OptionSet", {
        group = diff_keymaps_augroup,
        pattern = "diff",
        callback = function()
          update_diff_keymaps(vim.api.nvim_get_current_buf())
        end,
      })
      -- which-key loads on VeryLazy, after `nvim -d` / git mergetool already
      -- opened their diff windows, so catch those up now
      for _, win in ipairs(vim.api.nvim_list_wins()) do
        if vim.wo[win].diff then
          update_diff_keymaps(vim.api.nvim_win_get_buf(win))
        end
      end

      -- Document existing key chains
      require("which-key").add {
        { "<leader>a", group = "[A]I", mode = { "v", "n" } },
        { "<leader>ac", group = "[A]I [C]hat", mode = { "v", "n" } },
        { "<leader>ai", group = "[A]I [I]nline (edits buffer)", mode = { "v", "n" } },
        { "<leader>b", group = "[B]uffer" },
        { "<leader>d", group = "[D]iagnostics" },
        { "<leader>D", group = "[D]ebug", mode = { "n", "x" } },
        { "<leader>f", group = "[F]ind" },
        { "<leader>g", group = "[G]it" },
        { "<leader>gd", group = "[G]it [D]iff" },
        { "<leader>l", group = "[L]SP" },
        { "<leader>m", group = "[M]arks" },
        { "<leader>r", group = "[R]un in terminal", mode = { "v", "n" } },
        { "<leader>t", group = "[T]ests" },
        { "<leader>x", group = "Trouble" },
      }
    end,
  },
  {
    "folke/todo-comments.nvim",
    event = { "BufReadPost", "BufNewFile" },
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
        "<leader>rr",
        function()
          Snacks.terminal.toggle()
        end,
        desc = "[R]un: Toggle terminal ([r])",
      },
      {
        "<leader>rl",
        function()
          run_in_terminal(vim.fn.getline ".")
        end,
        desc = "[R]un: Current [L]ine in terminal",
      },
      {
        "<leader>rs",
        function()
          -- getregion handles backward, linewise and blockwise selections
          local lines = vim.fn.getregion(vim.fn.getpos "v", vim.fn.getpos ".", { type = vim.fn.mode() })
          vim.cmd("normal! " .. vim.keycode "<Esc>")
          -- A string runs through the shell; a list would be taken as argv
          run_in_terminal(table.concat(lines, "\n"))
        end,
        desc = "[R]un: [S]election in terminal",
        mode = "v",
      },
      -- Explorer
      {
        "\\",
        function()
          if vim.fn.getcmdwintype() ~= "" then return end
          Snacks.explorer()
        end,
        desc = "Explorer Toggle",
      },
      -- Gitbrowse
      { "<leader>go", function() Snacks.gitbrowse() end, desc = "[G]it: [O]pen" },
      -- Pickers
      { "<leader>fb", pick "buffers", desc = "[F]ind: [B]uffer" },
      { "<leader>fT", pick "colorschemes", desc = "[F]ind: [T]heme" },
      { "<leader>fc", pick "command_history", desc = "[F]ind: [C]ommand History" },
      { "<leader>fC", pick "commands", desc = "[F]ind: [C]ommand" },
      { "<leader>df", pick "diagnostics", desc = "[D]iagnostic: [F]ind (all)" },
      { "<leader>dF", pick "diagnostics_buffer", desc = "[D]iagnostic: [F]ind (buffer)" },
      { "<leader>ff", pick "files", desc = "[F]ind: [F]iles" },
      { "<leader><leader>", pick "files", desc = "[F]ind: [F]iles" },
      { "<leader>fF", pick "git_files", desc = "[F]ind: [F]iles (git)" },
      { "<leader>fh", pick "help", desc = "[F]ind: [H]elp" },
      { "<leader>fj", pick "jumps", desc = "[F]ind: [J]umps" },
      { "<leader>fk", pick "keymaps", desc = "[F]ind: [K]eymaps" },
      { "<leader>fl", pick "loclist", desc = "[F]ind: [L]oclist" },
      { "<leader>fL", pick "lines", desc = "[F]ind: [L]ines" },
      { "<leader>fM", pick "man", desc = "[F]ind: [M]an" },
      { "<leader>fn", pick "notifications", desc = "[F]ind: [N]otifications" },
      { "<leader>fp", pick "projects", desc = "[F]ind: [P]rojects" },
      { "<leader>fP", pick "pickers", desc = "[F]ind: [P]ickers" },
      { "<leader>fm", pick "marks", desc = "[F]ind: [M]arks" },
      { "<leader>fq", pick "qflist", desc = "[F]ind: [Q]uickfix" },
      { "<leader>fr", pick "recent", desc = "[F]ind: [R]ecent" },
      { "<leader>fR", pick "registers", desc = "[F]ind: [R]egisters" },
      { "<leader>fH", pick "search_history", desc = "[F]ind: Search [H]istory" },
      { "<leader>ft", pick "treesitter", desc = "[F]ind: [T]reesitter" },
      { "<leader>fu", pick "undo", desc = "[F]ind: [U]ndo" },
      { "<leader>fz", pick "zoxide", desc = "[F]ind: [Z]oxide" },
      { "<leader>g/", pick "git_grep", desc = "[G]it: Grep" },
      { "<leader>/", pick "grep", desc = "Grep" },
      { "<leader>gl", pick "git_log", desc = "[G]it: [L]og (branch)" },
      { "<leader>gL", pick "git_log_file", desc = "[G]it: [L]og (file)" },
      { "<leader>g<C-l>", pick "git_log_line", desc = "[G]it: [L]og (line)" },
      { "<leader>gs", pick "git_status", desc = "[G]it: [S]tatus" },
      { "<leader>gS", pick "git_stash", desc = "[G]it: [S]tash" },
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
            { icon = " ", key = "g", desc = "Grep", action = ":lua Snacks.dashboard.pick('live_grep')" },
            { icon = " ", key = "r", desc = "Recent Files", action = ":lua Snacks.dashboard.pick('oldfiles')" },
            {
              icon = " ",
              key = "c",
              desc = "Config",
              action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})",
            },
            { icon = "󰒲 ", key = "L", desc = "Lazy", action = ":Lazy", enabled = package.loaded.lazy ~= nil },
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
      indent = { enabled = true }, -- indent guides + current scope
      input = { enabled = true },
      layout = { enabled = true },
      notifier = {
        enabled = true,
        timeout = 3000,
        -- Hide LSP file-watcher noise: servers can register watches on
        -- directories that don't exist ("watch.watch: ENOENT ..." at INFO).
        filter = function(notif)
          return not (notif.msg or ""):match "^watch%.watch"
        end,
      },
      picker = {
        enabled = true,
        icons = {
          files = {
            dir = " ",
            dir_open = " ",
          },
          git = {
            staged = "●",
            added = "",
            deleted = "",
            ignored = " ",
            modified = "󰏫",
            renamed = "",
            unmerged = " ",
            untracked = "?",
          },
        },
        sources = {
          explorer = {
            git_status = true,
            git_status_open = true,
            git_untracked = true,
            hidden = true,
            ignored = true,
            exclude = { "*.uid", "godot.pipe" },
          },
        },
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
      -- Gutter: marks/signs (diagnostics) left of the number, folds/git right
      statuscolumn = { enabled = true, folds = { open = true } },
      terminal = { enabled = true },
      toggle = { enabled = false },
      win = { enabled = false },
      words = { enabled = true },
      styles = {
        dashboard = {
          wo = {
            number = false,
            relativenumber = false,
            cursorline = false,
            cursorcolumn = false,
            signcolumn = "no",
            list = false,
          },
        },
        notification = {
          wo = { wrap = true }, -- Wrap notifications
        },
      },
    },
  },
}
