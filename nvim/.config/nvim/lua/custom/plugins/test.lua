return {
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      { "fredrikaverpil/neotest-golang", version = "^2" },
      "mrcjkb/rustaceanvim",
      "Nsidorenco/neotest-vstest",
      "nvim-neotest/neotest-python",
      "olimorris/neotest-rspec",
      "zidhuss/neotest-minitest",
    },
    config = function()
      require("neotest").setup {
        adapters = {
          require "neotest-golang",
          require "rustaceanvim.neotest",
          require "neotest-vstest", -- C#/F# (debugging uses netcoredbg, see dap.lua)
          require "neotest-python", -- pytest; finds the project's .venv
          -- Ruby: `bundle exec` only when the project has a Gemfile
          require "neotest-rspec" {
            rspec_cmd = function()
              local ruby = require "custom.ruby"
              return ruby.exec(ruby.root(vim.fn.getcwd()), { "rspec" })
            end,
          },
          require "neotest-minitest" {
            test_cmd = function()
              local ruby = require "custom.ruby"
              return ruby.exec(ruby.root(vim.fn.getcwd()), { "ruby", "-Itest" })
            end,
          },
        },
      }
    end,
    keys = {
      {
        "<leader>tn",
        function()
          require("neotest").run.run()
        end,
        desc = "[T]est: Run [N]earest",
      },
      {
        "<leader>tf",
        function()
          require("neotest").run.run(vim.fn.expand "%")
        end,
        desc = "[T]est: Run [F]ile",
      },
      {
        "<leader>ta",
        function()
          require("neotest").run.run(vim.fn.getcwd())
        end,
        desc = "[T]est: Run [A]ll",
      },
      {
        "<leader>tl",
        function()
          require("neotest").run.run_last()
        end,
        desc = "[T]est: Run [L]ast again",
      },
      {
        "<leader>td",
        function()
          require("neotest").run.run { strategy = "dap" }
        end,
        desc = "[T]est: [D]ebug nearest",
      },
      {
        "<leader>tx",
        function()
          require("neotest").run.stop()
        end,
        desc = "[T]est: Stop ([x])",
      },
      {
        "<leader>tw",
        function()
          require("neotest").watch.toggle(vim.fn.expand "%")
        end,
        desc = "[T]est: [W]atch file",
      },
      {
        "<leader>ts",
        function()
          require("neotest").summary.toggle()
        end,
        desc = "[T]est: [S]ummary",
      },
      {
        "<leader>to",
        function()
          require("neotest").output.open { enter = true, auto_close = true }
        end,
        desc = "[T]est: [O]utput",
      },
      {
        "<leader>tO",
        function()
          require("neotest").output_panel.toggle()
        end,
        desc = "[T]est: [O]utput panel",
      },
      -- ]t/[t intentionally replace the built-in :tnext/:tprevious (tags)
      {
        "]t",
        function()
          require("neotest").jump.next { status = "failed" }
        end,
        desc = "Next failed test",
      },
      {
        "[t",
        function()
          require("neotest").jump.prev { status = "failed" }
        end,
        desc = "Previous failed test",
      },
    },
  },
}
