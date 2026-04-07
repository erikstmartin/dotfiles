-- Reviewing agent changes: staging a hunk = accept, resetting it = reject.

--- Re-evaluate treesitter-context's on_attach for a buffer (a no-op until
--- the plugin has loaded; it evaluates every buffer when it does)
local function ts_context_reattach(bufnr)
  pcall(vim.api.nvim_exec_autocmds, "BufReadPost", { group = "treesitter_context_update", buffer = bufnr })
end

return {
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      signs = {
        add = { text = "+" },
        change = { text = "~" },
        delete = { text = "_" },
        topdelete = { text = "‾" },
        changedelete = { text = "~" },
      },
      on_attach = function(buf)
        local gs = require "gitsigns"
        local function map(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, { buffer = buf, desc = desc })
        end
        local function visual_range()
          return { vim.fn.line ".", vim.fn.line "v" }
        end
        -- reset_hunk only changes the buffer; write it so the rejection is real
        -- on disk (for the agent and git) unless you had other unsaved edits
        local function reject(range)
          local had_edits = vim.bo[buf].modified
          gs.reset_hunk(range, nil, function(err)
            if not err and not had_edits then
              vim.schedule(function()
                vim.api.nvim_buf_call(buf, function()
                  vim.cmd "silent write"
                end)
              end)
            end
          end)
        end

        map("n", "]h", function()
          gs.nav_hunk "next"
        end, "Next git hunk")
        map("n", "[h", function()
          gs.nav_hunk "prev"
        end, "Previous git hunk")

        -- stage_hunk toggles: on an already-staged hunk it unstages it
        map("n", "<leader>ga", gs.stage_hunk, "[G]it: [A]ccept (stage/unstage) hunk")
        map("x", "<leader>ga", function()
          gs.stage_hunk(visual_range())
        end, "[G]it: [A]ccept (stage) selected lines")
        map("n", "<leader>gr", function()
          reject()
        end, "[G]it: [R]eject (reset) hunk")
        map("x", "<leader>gr", function()
          reject(visual_range())
        end, "[G]it: [R]eject (reset) selected lines")
        map("n", "<leader>gA", gs.stage_buffer, "[G]it: [A]ccept (stage) file")
        map("n", "<leader>gR", gs.reset_buffer, "[G]it: [R]eject (reset) file")
        map("n", "<leader>gp", gs.preview_hunk_inline, "[G]it: [P]review hunk (deleted lines inline)")
        map("n", "<leader>gb", function()
          gs.blame_line { full = true }
        end, "[G]it: [B]lame line")
        map("n", "<leader>gw", function()
          gs.toggle_linehl(gs.toggle_word_diff())
        end, "[G]it: Toggle [W]ord diff + line highlights")
        map({ "o", "x" }, "ih", gs.select_hunk, "inside git hunk")
      end,
    },
  },
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory", "DiffviewToggleFiles", "DiffviewFocusFiles" },
    opts = {
      enhanced_diff_hl = true,
      hooks = {
        -- treesitter-context lines misalign scrollbind between diff panes. It
        -- decides on BufReadPost/FileType, which can run before this hook, so
        -- re-run its BufReadPost handler once the flag is set.
        diff_buf_read = function(bufnr)
          vim.b[bufnr].ts_context_disable = true
          ts_context_reattach(bufnr)
        end,
        -- The working-tree side is the real file buffer: give it its context
        -- back once the review is over
        view_closed = function()
          for _, buf in ipairs(vim.api.nvim_list_bufs()) do
            if vim.b[buf].ts_context_disable then
              vim.b[buf].ts_context_disable = nil
              ts_context_reattach(buf)
            end
          end
        end,
      },
      keymaps = {
        file_panel = {
          { "n", "<C-t>", function() require("diffview.actions").goto_file_tab() end, { desc = "Open file in new tab" } },
        },
        file_history_panel = {
          { "n", "<C-t>", function() require("diffview.actions").goto_file_tab() end, { desc = "Open file in new tab" } },
        },
      },
    },
    keys = {
      {
        "<leader>gdb",
        function()
          local lib = require("diffview.lib")
          local view = lib.get_current_view()
          if view then
            vim.cmd("DiffviewClose")
          else
            for _, v in ipairs(lib.views) do
              if v.tabpage and vim.api.nvim_tabpage_is_valid(v.tabpage) then
                local tabnr = vim.api.nvim_tabpage_get_number(v.tabpage)
                vim.cmd("tabn " .. tabnr)
                return
              end
            end
            vim.cmd("DiffviewOpen")
          end
        end,
        desc = "[G]it: [D]iff [B]ranch (toggle)",
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
  {
    "NeogitOrg/neogit",
    cmd = "Neogit",
    init = function()
      -- Neogit draws its fold chevrons as signs; snacks.statuscolumn shows
      -- them twice, so Neogit buffers use Neovim's plain sign column
      -- (FileType can fire before the buffer has a window, so also BufWinEnter)
      vim.api.nvim_create_autocmd({ "FileType", "BufWinEnter" }, {
        group = vim.api.nvim_create_augroup("neogit-gutter", { clear = true }),
        callback = function(args)
          if not vim.bo[args.buf].filetype:match "^Neogit" then
            return
          end
          for _, win in ipairs(vim.fn.win_findbuf(args.buf)) do
            vim.wo[win].statuscolumn = ""
            vim.wo[win].foldcolumn = "0"
          end
        end,
      })
    end,
    dependencies = { "nvim-lua/plenary.nvim", "sindrets/diffview.nvim" },
    keys = {
      {
        "<leader>gg",
        function()
          require("neogit").open()
        end,
        desc = "[G]it: Neo[g]it status",
      },
      {
        "<leader>gc",
        function()
          require("neogit").open { "commit" }
        end,
        desc = "[G]it: [C]ommit",
      },
    },
    opts = {
      graph_style = "unicode",
      -- Same closed/open chevrons as code folds (fillchars in
      -- custom/options.lua); Neogit's defaults are ASCII ">" / "v"
      signs = {
        hunk = { "", "" },
        item = { "󰅂", "󰅀" },
        section = { "󰅂", "󰅀" },
      },
      integrations = {
        diffview = true, -- `d` opens files/commits in diffview
        snacks = true, -- pickers (branches, commits, ...)
      },
    },
  },
}
