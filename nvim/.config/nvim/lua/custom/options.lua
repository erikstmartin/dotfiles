local opt = vim.opt

-- No remote plugins use these; Python stays for pynvim
vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0

-- Make line numbers default
opt.number = true
-- You can also add relative line numbers, to help with jumping.
--opt.relativenumber = false

-- Enable mouse mode, can be useful for resizing splits for example!
opt.mouse = "a"

-- Don't show the mode, since it's already in the status line
opt.showmode = false

-- No command-line row; the cmdline appears while typing : / ? and messages
-- show in ui2's ephemeral "msg" window (bottom-right, fades after 4s)
opt.cmdheight = 0
-- Pending keys (counts, operators like `2d`, registers) have no cmdline row to
-- appear in; show them in the statusline instead (lualine's %S component)
opt.showcmdloc = "statusline"

-- Experimental (0.12) redesigned message/cmdline UI, which is what makes
-- cmdheight=0 usable: no "Press ENTER" prompts; see full messages with g<.
require("vim._core.ui2").enable {
  msg = { targets = "msg" },
}

opt.clipboard = "unnamedplus"

if vim.env.SSH_TTY then
  local osc52 = require("vim.ui.clipboard.osc52")
  vim.g.clipboard = {
    name = "OSC 52",
    copy = {
      ["+"] = osc52.copy("+"),
      ["*"] = osc52.copy("*"),
    },
    paste = {
      ["+"] = osc52.paste("+"),
      ["*"] = osc52.paste("*"),
    },
  }
end

-- Enable break indent
opt.breakindent = true

-- Save undo history
opt.undofile = true

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
opt.ignorecase = true
opt.smartcase = true

-- Tabs display 4 columns wide (e.g. Go). Per-project .editorconfig (the kernel
-- uses 8) and vim-sleuth's detection still override this per buffer.
opt.tabstop = 4

-- Treesitter folding: everything starts unfolded (foldlevel 99); zc/zo/za
-- fold and unfold blocks. Files without a parser simply have no folds.
-- foldcolumn enables snacks.statuscolumn's fold markers (right of the number).
opt.foldmethod = "expr"
opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
opt.foldlevel = 99
opt.foldlevelstart = 99
opt.foldcolumn = "1"
opt.foldtext = "" -- folded line keeps its syntax highlighting

-- Keep signcolumn on by default
opt.signcolumn = "yes"

-- Decrease update time
opt.updatetime = 250

-- Decrease mapped sequence wait time
-- Displays which-key popup sooner
opt.timeoutlen = 300

-- Configure how new splits should be opened
opt.splitright = true
opt.splitbelow = true

-- Sets how neovim will display certain whitespace characters in the editor.
--  See `:help 'list'`
--  and `:help 'listchars'`
opt.list = true
-- opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
opt.listchars = { tab = "  ", trail = "·", nbsp = "␣" }

-- Preview substitutions live, as you type!
opt.inccommand = "split"

-- Show which line your cursor is on
opt.cursorline = true

-- Rounded borders on all floating windows (hover, signature help, blink.cmp
-- menus, diagnostics) unless a plugin sets its own
opt.winborder = "rounded"

-- Hide the ~ markers on lines past the end of the buffer. Fold markers
-- (snacks.statuscolumn and Neogit): Material Design chevrons; the Octicons
-- defaults are drawn wider than one cell and leave redraw artifacts
opt.fillchars:append { eob = " ", foldclose = "󰅂", foldopen = "󰅀" }

-- Minimal number of screen lines to keep above and below the cursor.
opt.scrolloff = 10

opt.shada = { "'100", "<0", "s10", "h" }

-- Don't have `o` add a comment. Filetype plugins reset 'formatoptions', so
-- this has to run per buffer after them.
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("formatoptions-no-o", { clear = true }),
  callback = function()
    vim.opt_local.formatoptions:remove "o"
  end,
})

-- Configure diagnostics
vim.diagnostic.config {
  -- virtual_text = true
  -- virtual_lines = true,
  severity_sort = true,
  -- Also used by the lualine diagnostics component
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "󰅙",
      [vim.diagnostic.severity.WARN] = "󰀦",
      [vim.diagnostic.severity.INFO] = "󰋼",
      [vim.diagnostic.severity.HINT] = "󰌵",
    },
  },
  -- source = "if_many": label messages with the tool that reported them
  -- (e.g. rustc vs clippy vs rust-analyzer) when a buffer has several
  float = { border = "rounded", source = "if_many" },
  -- Show the message when jumping with the built-in ]d/[d/]D/[D
  jump = {
    on_jump = function(_, bufnr)
      vim.diagnostic.open_float { bufnr = bufnr, scope = "cursor", focus = false }
    end,
  },
}
