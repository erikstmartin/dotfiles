-- Mauve only for keywords; other roles use blue/green/yellow/peach/teal or text.
local function syntax_highlights(colors)
  local keyword = { fg = colors.mauve }
  local special = { fg = colors.teal }
  local operator = { fg = colors.overlay2 }
  local property = { fg = colors.text }
  local parameter = { fg = colors.text, style = { "italic" } }
  return {
    Keyword = keyword,
    Statement = keyword,
    Conditional = keyword,
    Repeat = keyword,
    Exception = keyword,
    Include = keyword,
    PreProc = keyword,
    ["@type.builtin"] = { fg = colors.yellow },

    -- Operators: muted like punctuation, so keywords and calls stand out
    Operator = operator,
    ["@operator"] = operator,

    -- Properties/fields: plain text, distinct from functions' blue
    ["@property"] = property,
    ["@variable.member"] = property,

    ["@variable.parameter"] = parameter,
    ["@parameter"] = parameter, -- older capture name
    ["@variable.builtin"] = { fg = colors.lavender, style = { "italic" } },
    Identifier = { fg = colors.text },

    Special = special,
    ["@string.escape"] = special,
    ["@string.regexp"] = special,
    ["@string.regex"] = special, -- older capture name
    ["@string.special.symbol"] = special,
    ["@string.special.symbol.ruby"] = special,
    ["@symbol"] = special,
    ["@symbol.ruby"] = special,
    Macro = { fg = colors.blue },
    ["@function.macro"] = { fg = colors.blue },

    -- Markdown emphasis: keep the bold/italic, drop the colour
    ["@markup.strong"] = { fg = colors.text, style = { "bold" } },
    ["@markup.italic"] = { fg = colors.text, style = { "italic" } },

    -- Completion menu kinds follow the same roles
    BlinkCmpKindVariable = { fg = colors.text },
    BlinkCmpKindTypeParameter = { fg = colors.text },
    BlinkCmpKindSnippet = special,

    -- Neogit: blue section headers instead of a column of mauve
    NeogitSectionHeader = { fg = colors.blue, style = { "bold" } },
    NeogitStagedchanges = { fg = colors.blue, style = { "bold" } },
    NeogitUnstagedchanges = { fg = colors.blue, style = { "bold" } },
    NeogitUntrackedfiles = { fg = colors.blue, style = { "bold" } },
    NeogitRecentcommits = { fg = colors.blue, style = { "bold" } },
    NeogitStashes = { fg = colors.blue, style = { "bold" } },
    NeogitUnmergedchanges = { fg = colors.blue, style = { "bold" } },
    NeogitUnpulledchanges = { fg = colors.blue, style = { "bold" } },
    NeogitChangeCopied = special,
  }
end

return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    lazy = false,
    config = function()
      require("catppuccin").setup({
        flavour = "mocha",
        color_overrides = {
          mocha = {
            base   = "#11111b",
            mantle = "#0d0d17",
            crust  = "#0a0a12",
          },
        },
        custom_highlights = function(colors)
          return vim.tbl_extend("force", { WhichKeyDesc = { fg = colors.text } }, syntax_highlights(colors))
        end,
        -- Auto-detection calls vim.pack.get, which creates an empty
        -- site/pack/core that lazy.nvim's health check then warns about
        auto_integrations = false,
        integrations = {
          blink_cmp = true,
          bufferline = true,
          dap = true,
          dap_ui = true,
          diffview = true,
          fidget = true,
          flash = true,
          gitsigns = true,
          harpoon = true,
          lsp_trouble = true,
          lualine = {},
          mini = { enabled = true },
          neogit = true,
          neotest = true,
          render_markdown = true,
          snacks = true,
          treesitter = true,
          treesitter_context = true,
          which_key = true,
        },
      })
      vim.cmd.colorscheme("catppuccin")
    end,
  },
}
