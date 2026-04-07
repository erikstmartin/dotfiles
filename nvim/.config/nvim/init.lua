--[[ Setup initial configuration ]]
--

-- Fall back to mise shims when nvim isn't launched from a mise-activated shell
-- (e.g. a GUI). Appended so activated tool paths keep priority: shims add
-- ~30ms to every LSP/formatter/linter spawn.
local is_win = vim.fn.has "win32" == 1
local mise_data = vim.env.MISE_DATA_DIR
  or (is_win and vim.env.LOCALAPPDATA and vim.fs.joinpath(vim.env.LOCALAPPDATA, "mise"))
  or vim.fn.expand "~/.local/share/mise"
local mise_shims = vim.fs.normalize(vim.fs.joinpath(mise_data, "shims"))
-- (normalize() gives "/" separators, so compare against a "/" PATH on Windows)
if not (is_win and vim.env.PATH:gsub("\\", "/") or vim.env.PATH):find(mise_shims, 1, true) then
  vim.env.PATH = vim.env.PATH .. (is_win and ";" or ":") .. mise_shims
end

-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)

vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Set to true if you have a Nerd Font installed and selected in the terminal
vim.g.have_nerd_font = true

-- Options must be set before lazy.nvim loads plugins: snacks opens the
-- dashboard during setup, and `vim.opt` assignments made afterwards (e.g. from
-- plugin/) would also apply to the dashboard window, overriding its settings.
require "custom.options"

-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.hl.on_yank()`
vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight when yanking (copying) text",
  group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})

local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system {
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  }
end

-- Add lazy to the `runtimepath`, this allows us to `require` it.
---@diagnostic disable-next-line: undefined-field
vim.opt.rtp:prepend(lazypath)

-- Set up lazy, and load my `lua/custom/plugins/` folder
require("lazy").setup({ import = "custom/plugins" }, {
  change_detection = {
    notify = false,
  },
  rocks = { enabled = false }, -- no plugins need luarocks
  performance = {
    rtp = {
      -- netrw is replaced by the snacks explorer
      disabled_plugins = { "gzip", "netrwPlugin", "tarPlugin", "tohtml", "tutor", "zipPlugin" },
    },
  },
  ui = {
    -- If you are using a Nerd Font: set icons to an empty table which will use the
    -- default lazy.nvim defined Nerd Font icons, otherwise define a unicode icons table
    icons = vim.g.have_nerd_font and {} or {
      cmd = "⌘",
      config = "🛠",
      event = "📅",
      ft = "📂",
      init = "⚙",
      keys = "🗝",
      plugin = "🔌",
      runtime = "💻",
      require = "🌙",
      source = "📄",
      start = "🚀",
      task = "📌",
      lazy = "💤 ",
    },
  },
})
