require "custom.snippets"

-- See `:help cmp`
local cmp = require "cmp"
local lspkind = require "lspkind"
local luasnip = require "luasnip"
luasnip.config.setup {}

require("luasnip").filetype_extend("ruby", { "rails" })

cmp.setup {
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  completion = { completeopt = "menu,menuone,noinsert" },

  -- For an understanding of why these mappings were
  -- chosen, you will need to read `:help ins-completion`
  --
  -- No, but seriously. Please read `:help ins-completion`, it is really good!
  mapping = cmp.mapping.preset.insert {
    -- Select the [n]ext item
    ["<C-n>"] = cmp.mapping.select_next_item(),
    -- Select the [p]revious item
    ["<C-p>"] = cmp.mapping.select_prev_item(),

    -- Scroll the documentation window [b]ack / [f]orward
    ["<C-b>"] = cmp.mapping.scroll_docs(-4),
    ["<C-f>"] = cmp.mapping.scroll_docs(4),

    -- Accept ([y]es) the completion.
    --  This will auto-import if your LSP supports it.
    --  This will expand snippets if the LSP sent a snippet.
    ["<C-y>"] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Insert,
      select = true,
    },

    -- If you prefer more traditional completion keymaps,
    -- you can uncomment the following lines
    --['<CR>'] = cmp.mapping.confirm { select = true },
    --['<Tab>'] = cmp.mapping.select_next_item(),
    --['<S-Tab>'] = cmp.mapping.select_prev_item(),

    -- Manually trigger a completion from nvim-cmp.
    --  Generally you don't need this, because nvim-cmp will display
    --  completions whenever it has completion options available.
    ["<C-Space>"] = cmp.mapping.complete {},

    -- Think of <c-l> as moving to the right of your snippet expansion.
    --  So if you have a snippet that's like:
    --  function $name($args)
    --    $body
    --  end
    --
    -- <c-l> will move you to the right of each of the expansion locations.
    -- <c-h> is similar, except moving you backwards.
    ["<C-l>"] = cmp.mapping(function()
      if luasnip.expand_or_locally_jumpable() then
        luasnip.expand_or_jump()
      end
    end, { "i", "s" }),
    ["<C-h>"] = cmp.mapping(function()
      if luasnip.locally_jumpable(-1) then
        luasnip.jump(-1)
      end
    end, { "i", "s" }),

    -- For more advanced Luasnip keymaps (e.g. selecting choice nodes, expansion) see:
    --    https://github.com/L3MON4D3/LuaSnip?tab=readme-ov-file#keymaps
  },
  sources = {
    { name = "nvim_lsp", keyword_length = 3, group_index = 1 },
    { name = "nvim_lua", keyword_length = 3, group_index = 2 },
    { name = "luasnip", keyword_length = 2, group_index = 2 },
    { name = "copilot", group_index = 2 },
    -- { name = "omni" },
    -- { name = "ctags" },
    { name = "buffer", keyword_length = 4, group_index = 2 },
    { name = "path", keyword_length = 3, group_index = 2 },
    { name = "git", keyword_length = 4, group_index = 2 },
    { name = "tmux", keyword_length = 5, group_index = 2 },
    -- { name = "cmdline" },
  },

  formatting = {
    expandable_indicator = true,
    fields = { "abbr", "kind", "menu" },

    format = lspkind.cmp_format {
      with_text = true,
      menu = {
        nvim_lsp = "[LSP]",
        luasnap = "[snip]",
        buffer = "[buf]",
        nvim_lua = "[api]",
        path = "[path]",
        tmux = "[tmux]",
        -- cmdline = "[cmd]",
      },
    },
  },

  experimental = {
    ghost_text = true,
  },
}

lspkind.init {
  symbol_map = {
    Copilot = "",
  },
}

-- Setup up vim-dadbod
cmp.setup.filetype({ "sql" }, {
  sources = {
    -- { name = "cmp-dbee" },
    { name = "vim-dadbod-completion" },
  },
})
