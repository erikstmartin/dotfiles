return {
  {
    "epwalsh/obsidian.nvim",
    version = "*",
    lazy = true,
    ft = "markdown",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    opts = {
      workspaces = {
        {
          name = "personal",
            path = vim.env.OBSIDIAN_VAULT or (vim.fn.expand("~") .. "/notes"),
        },
      },
      completion = {
        nvim_cmp = false,
        blink = true,
        min_chars = 2,
      },
      new_notes_location = "current_dir",
      preferred_link_style = "wiki",
      follow_url_func = function(url)
        vim.fn.jobstart({ "open", url })
      end,
      ui = {
        enable = true,
        update_debounce = 200,
        checkboxes = {
          [" "] = { char = "󰄱", hl_group = "ObsidianTodo" },
          ["x"] = { char = "", hl_group = "ObsidianDone" },
          [">"] = { char = "", hl_group = "ObsidianRightArrow" },
          ["~"] = { char = "󰰱", hl_group = "ObsidianTilde" },
        },
        bullets = { char = "•", hl_group = "ObsidianBullet" },
        external_link_icon = { char = "", hl_group = "ObsidianExtLinkIcon" },
        reference_text = { hl_group = "ObsidianRefText" },
        highlight_text = { hl_group = "ObsidianHighlightText" },
        tags = { hl_group = "ObsidianTag" },
        block_ids = { hl_group = "ObsidianBlockID" },
        hl_groups = {
          ObsidianTodo = { bold = true, fg = "#f78c6c" },
          ObsidianDone = { bold = true, fg = "#89ddff" },
          ObsidianRightArrow = { bold = true, fg = "#f78c6c" },
          ObsidianTilde = { bold = true, fg = "#ff5370" },
          ObsidianBullet = { bold = true, fg = "#89ddff" },
          ObsidianRefText = { underline = true, fg = "#c792ea" },
          ObsidianExtLinkIcon = { fg = "#c792ea" },
          ObsidianTag = { italic = true, fg = "#89ddff" },
          ObsidianBlockID = { italic = true, fg = "#89ddff" },
          ObsidianHighlightText = { bg = "#75662e" },
        },
      },
    },
    keys = {
      { "<leader>nn", "<cmd>ObsidianNew<cr>", desc = "[N]otes: [N]ew note" },
      { "<leader>no", "<cmd>ObsidianOpen<cr>", desc = "[N]otes: [O]pen in app" },
      { "<leader>nb", "<cmd>ObsidianBacklinks<cr>", desc = "[N]otes: [B]acklinks" },
      { "<leader>nt", "<cmd>ObsidianTags<cr>", desc = "[N]otes: [T]ags" },
      { "<leader>nl", "<cmd>ObsidianLinks<cr>", desc = "[N]otes: [L]inks" },
      { "<leader>np", "<cmd>ObsidianPasteImg<cr>", desc = "[N]otes: [P]aste image" },
      { "<leader>nr", "<cmd>ObsidianRename<cr>", desc = "[N]otes: [R]ename note" },
      {
        "<leader>ne",
        function()
          local vault = vim.env.OBSIDIAN_VAULT or (vim.fn.expand("~") .. "/notes")
          Snacks.explorer({ cwd = vault })
        end,
        desc = "[N]otes: [E]xplorer",
      },
      {
        "<leader>nf",
        function()
          local vault = vim.env.OBSIDIAN_VAULT or (vim.fn.expand("~") .. "/notes")
          Snacks.picker.files({ cwd = vault })
        end,
        desc = "[N]otes: [F]ind files",
      },
      {
        "<leader>n/",
        function()
          local vault = vim.env.OBSIDIAN_VAULT or (vim.fn.expand("~") .. "/notes")
          Snacks.picker.grep({ cwd = vault })
        end,
        desc = "[N]otes: Grep",
      },
    },
  },
}
