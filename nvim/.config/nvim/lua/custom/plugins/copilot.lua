return {
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    build = ":Copilot auth",
    event = "InsertEnter",
    opts = {
      panel = {
        enabled = false,
        auto_refresh = true,
        keymap = {
          jump_prev = "[[",
          jump_next = "]]",
          accept = "<C-y>",
          -- accept = false, -- handled by blink.cmp
          refresh = "gr",
          open = "<C-CR>",
        },
        layout = {
          position = "bottom", -- | top | left | right
          ratio = 0.4,
        },
      },
      suggestion = {
        enabled = true,
        auto_trigger = true,
        debounce = 75,
        keymap = {
          accept = "<M-y>",
          -- accept_word = "<M-w>",
          -- accept_line = "<M-l>",
          next = "<M-]>",
          prev = "<M-[>",
          dismiss = "<C-]>",
        },
      },
      filetypes = {
        lua = true,
        golang = true,
        python = true,
        ruby = true,
        rust = true,
        javascript = true,
        typescript = true,
        yaml = false,
        markdown = false,
        help = false,
        gitcommit = false,
        gitrebase = false,
        ["."] = false,
      },
      copilot_node_command = "node", -- Node.js version must be > 18.x
      server_opts_overrides = {},
    },
  },
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    enabled = false,
    cmd = {
      "CopilotChat",
      "CopilotChatClose",
      "CopilotChatCommit",
      "CopilotChatToggle",
      "CopilotChatDocs",
      "CopilotChatExplain",
      "CopilotChatFix",
      "CopilotChatLoad",
      "CopilotChatModels",
      "CopilotChatOpen",
      "CopilotChatOptimize",
      "CopilotChatPrompts",
      "CopilotChatReset",
      "CopilotChatReview",
      "CopilotChatSave",
      "CopilotChatStop",
      "CopilotChatTests",
      "CopilotChatToggle",
    },
    branch = "main",
    dependencies = {
      { "zbirenbaum/copilot.lua" }, -- or github/copilot.vim
      { "nvim-lua/plenary.nvim" }, -- for curl, log wrapper
      { "BurntSushi/ripgrep" },
    },
    keys = {
      { "<leader>cc", "<cmd>CopilotChat<CR>", desc = "[C]opilot: [C]hat" },
      { "<leader>cm", "<cmd>CopilotChatModel<CR>", desc = "[C]opilot: [M]odels" },
      { "<leader>cr", "<cmd>CopilotChatReset<CR>", desc = "[C]opilot: [R]eset" },
      { "<leader>cs", "<cmd>CopilotChatStop<CR>", desc = "[C]opilot: [S]top" },
    },
    opts = {
      debug = false, -- Enable debugging
      -- See Configuration section for rest
    },
    -- See Commands section for default commands if you want to lazy load on them
  },
  config = function(_, opts)
    require("CopilotChat").setup(opts)
  end,
}
