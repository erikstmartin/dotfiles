return {
  "olimorris/codecompanion.nvim",
  enabled = true,
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
    {
      "MeanderingProgrammer/render-markdown.nvim",
      ft = { "markdown", "codecompanion" },
    },
  },
  keys = {
    { "<leader>ac", "<cmd>CodeCompanionChat<CR>", desc = "[A]I: [C]hat" },
    { "<leader>ap", "<cmd>CodeCompanion<CR>", desc = "[A]I: [P]rompt" },
    { "<leader>aa", "<cmd>CodeCompanionActions<CR>", desc = "[A]I: [A]ction" },
    -- Prompts
    {
      "<leader>ae",
      function()
        require("codecompanion").prompt("copilot_explain")
      end,
      desc = "[A]I: [E]xplain",
      mode = { "n", "v" },
    },
    {
      "<leader>ar",
      function()
        require("codecompanion").prompt("copilot_review")
      end,
      desc = "[A]I: [R]eview",
      mode = { "n", "v" },
    },
    {
      "<leader>af",
      function()
        require("codecompanion").prompt("copilot_fix_explain")
      end,
      desc = "[A]I: [F]ix Explain",
      mode = { "n", "v" },
    },
    {
      "<leader>aF",
      function()
        require("codecompanion").prompt("copilot_fix")
      end,
      desc = "[A]I: [F]ix",
      mode = { "n", "v" },
    },
    {
      "<leader>ao",
      function()
        require("codecompanion").prompt("copilot_optimize_explain")
      end,
      desc = "[A]I: [O]ptimize Explain",
      mode = { "n", "v" },
    },
    {
      "<leader>aO",
      function()
        require("codecompanion").prompt("copilot_optimize")
      end,
      desc = "[A]I: [O]ptimize",
      mode = { "n", "v" },
    },
    {
      "<leader>ad",
      function()
        require("codecompanion").prompt("copilot_docs")
      end,
      desc = "[A]I: [D]ocs",
      mode = { "n", "v" },
    },
    {
      "<leader>at",
      function()
        require("codecompanion").prompt("copilot_tests")
      end,
      desc = "[A]I: [T]ests",
      mode = { "n", "v" },
    },
    {
      "<leader>aC",
      function()
        require("codecompanion").prompt("copilot_commit")
      end,
      desc = "[A]I: [C]ommmit",
      mode = "n",
    },
  },

  opts = {
    strategies = {
      chat = { adapter = "copilot" },
      inline = {
        adapter = "copilot",
        keymaps = {
          accept_change = {
            modes = { n = "<C-y>" },
            description = "Accept the suggested change",
          },
          reject_change = {
            modes = { n = "<C-n>" },
            description = "Reject the suggested change",
          },
        },
      },
      log_level = "TRACE",
      language = "English",
      send_code = true,
    },
    display = {
      action_palette = {
        width = 95,
        height = 10,
        prompt = "Prompt ",
        opts = {
          show_default_actions = false,
          show_preset_prompts = false,
        },
      },
    },
    prompt_library = {
      ["Copilot Explain"] = {
        strategy = "chat",
        description = "Explain selected code with clear, practical explanations",
        opts = {
          alias = "copilot_explain",
          modes = { "v", "n" },
          auto_submit = true,
          user_prompt = false,
          stop_context_insertion = true,
        },
        prompts = require("custom.codecompanion.prompts.explain"),
      },
      ["Copilot Review"] = {
        strategy = "chat",
        description = "Review code for quality, maintainability, and best practices",
        opts = {
          alias = "copilot_review",
          modes = { "v", "n" },
          auto_submit = true,
          user_prompt = false,
          stop_context_insertion = true,
        },
        prompts = require("custom.codecompanion.prompts.review"),
      },
      ["Copilot Fix (inline)"] = {
        strategy = "inline",
        description = "Fix code issues inline without explanations",
        opts = {
          alias = "copilot_fix",
          modes = { "v", "n" },
          auto_submit = true,
          user_prompt = false,
          stop_context_insertion = true,
        },
        prompts = require("custom.codecompanion.prompts.fix"),
      },
      ["Copilot Fix (explain)"] = {
        strategy = "chat",
        description = "Fix code issues with explanations",
        opts = {
          alias = "copilot_fix_explain",
          modes = { "v", "n" },
          auto_submit = true,
          user_prompt = false,
          stop_context_insertion = true,
        },
        prompts = require("custom.codecompanion.prompts.fix_explain"),
      },
      ["Copilot Optimize (inline)"] = {
        strategy = "inline",
        description = "Optimize code for performance and readability inline",
        opts = {
          alias = "copilot_optimize",
          modes = { "v", "n" },
          auto_submit = true,
          user_prompt = false,
          stop_context_insertion = true,
        },
        prompts = require("custom.codecompanion.prompts.optimize"),
      },
      ["Copilot Optimize (explain)"] = {
        strategy = "chat",
        description = "Optimize code with explanations",
        opts = {
          alias = "copilot_optimize_explain",
          modes = { "v", "n" },
          auto_submit = true,
          user_prompt = false,
          stop_context_insertion = true,
        },
        prompts = require("custom.codecompanion.prompts.optimize_explain"),
      },
      ["Copilot Docs (inline)"] = {
        strategy = "inline",
        description = "Generate documentation for selected code",
        opts = {
          alias = "copilot_docs",
          modes = { "v", "n" },
          auto_submit = true,
          user_prompt = false,
          stop_context_insertion = true,
        },
        prompts = require("custom.codecompanion.prompts.docs"),
      },
      ["Copilot Tests"] = {
        strategy = "chat",
        description = "Generate unit tests for selected code",
        opts = {
          alias = "copilot_tests",
          modes = { "v", "n" },
          auto_submit = true,
          user_prompt = false,
          stop_context_insertion = true,
        },
        prompts = require("custom.codecompanion.prompts.tests"),
      },
      ["Copilot Commit"] = {
        strategy = "chat",
        description = "Generate commit message from staged changes",
        opts = {
          alias = "copilot_commit",
          auto_submit = true,
          stop_context_insertion = true,
          user_prompt = false,
        },
        prompts = require("custom.codecompanion.prompts.commit"),
      },
    },
  },
}
