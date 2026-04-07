return {
  "saghen/blink.cmp",
  -- Also loaded as a dependency of lsp-setup, so its capabilities are
  -- registered (vim.lsp.config("*")) before any server starts.
  event = { "InsertEnter", "CmdlineEnter" },
  -- optional: provides snippets for the snippet source
  dependencies = {
    "rafamadriz/friendly-snippets",
    "mgalliou/blink-cmp-tmux",
  },

  -- use a release tag to download pre-built binaries
  version = "1.*",
  -- If pre-built binaries aren't available for your platform, build from source:
  -- build = "cargo build --release",
  -- If you use nix, you can build from source using latest nightly rust with:
  -- build = 'nix run .#build-plugin',

  ---@module 'blink.cmp'
  ---@type blink.cmp.Config
  opts = {
    -- 'default' (recommended) for mappings similar to built-in completions (C-y to accept)
    -- 'super-tab' for mappings similar to vscode (tab to accept)
    -- 'enter' for enter to accept
    -- 'none' for no mappings
    --
    -- All presets have the following mappings:
    -- C-space: Open menu or open docs if already open
    -- C-n/C-p or Up/Down: Select next/previous item
    -- C-e: Hide menu
    -- C-k: Toggle signature help (if signature.enabled = true)
    --
    -- See :h blink-cmp-config-keymap for defining your own keymap
    keymap = {
      preset = "default",
      -- Words from the other tmux panes, on demand (replaces Vim's thesaurus
      -- completion): the source shells out to tmux and blocks while it does
      ["<C-x><C-t>"] = {
        function(cmp)
          return cmp.show { providers = { "tmux" } }
        end,
      },
    },

    appearance = {
      -- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
      -- Adjusts spacing to ensure icons are aligned
      nerd_font_variant = "mono",
      -- Blink does not expose its default kind icons so you must copy them all (or set your custom ones)
      kind_icons = {
        Text = "󰉿",
        Method = "󰊕",
        Function = "󰊕",
        Constructor = "󰒓",

        Field = "󰜢",
        Variable = "󰆦",
        Property = "󰖷",

        Class = "󱡠",
        Interface = "󱡠",
        Struct = "󱡠",
        Module = "󰅩",

        Unit = "󰪚",
        Value = "󰦨",
        Enum = "󰦨",
        EnumMember = "󰦨",

        Keyword = "󰻾",
        Constant = "󰏿",

        Snippet = "󱄽",
        Color = "󰏘",
        File = "󰈔",
        Reference = "󰬲",
        Folder = "󰉋",
        Event = "󱐋",
        Operator = "󰪚",
        TypeParameter = "󰬛",
      },
    },

    -- Borderless completion windows (they'd otherwise follow vim.o.winborder,
    -- which is "rounded" for hover/diagnostic floats)
    signature = { window = { border = "none" } },
    completion = {
      menu = { border = "none" },
      documentation = { auto_show = false, window = { border = "none" } },
    },

    -- Default list of enabled providers defined so that you can extend it
    -- elsewhere in your config, without redefining it, due to `opts_extend`
    sources = {
      default = { "lsp", "snippets", "buffer" }, -- no path; tmux via <C-x><C-t>
      providers = {
        cmdline = {
          -- ignores cmdline completions when executing shell commands
          enabled = function()
            return vim.fn.getcmdtype() ~= ":" or not vim.fn.getcmdline():match "^[%%0-9,'<>%-]*!"
          end,
        },
        tmux = {
          module = "blink-cmp-tmux",
          name = "tmux",
          opts = {
            panes = "window", -- "window" | "session" | "all"
            capture_history = false,
            -- only suggest completions from `tmux` if the `trigger_chars` are
            -- used
            triggered_only = false,
            trigger_chars = { "." },
          },
        },
      },
    },

    -- (Default) Rust fuzzy matcher for typo resistance and significantly better performance
    -- You may use a lua implementation instead by using `implementation = "lua"` or fallback to the lua implementation,
    -- when the Rust fuzzy matcher is not available, by using `implementation = "prefer_rust"`
    --
    -- See the fuzzy documentation for more information
    fuzzy = { implementation = "prefer_rust_with_warning" },
  },
  opts_extend = { "sources.default" },
}
