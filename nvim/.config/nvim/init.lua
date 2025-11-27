--[[ Setup initial configuration ]]
--

local original_notify = vim.notify
vim.notify = function(msg, level, opts)
  local is_watch_error = type(msg) == "string" and (msg:match("watch%.watch") or msg:match("ENOENT"))
  if not is_watch_error then
    original_notify(msg, level, opts)
  end
end

local original_err_writeln = vim.api.nvim_err_writeln
vim.api.nvim_err_writeln = function(msg)
  local is_watch_error = type(msg) == "string" and (msg:match("watch%.watch") or msg:match("ENOENT"))
  if not is_watch_error then
    original_err_writeln(msg)
  end
end

local original_echo = vim.api.nvim_echo
vim.api.nvim_echo = function(chunks, history, opts)
  for _, chunk in ipairs(chunks) do
    local msg = chunk[1]
    if type(msg) == "string" and (msg:match("watch%.watch") or msg:match("ENOENT")) then
      return
    end
  end
  original_echo(chunks, history, opts)
end

-- Prepend mise shims to PATH
local mise_shim_path = vim.fn.expand "~/.local/share/mise/shims"
vim.env.PATH = mise_shim_path .. ":" .. vim.env.PATH

-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)

vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Set to true if you have a Nerd Font installed and selected in the terminal
vim.g.have_nerd_font = true

-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight when yanking (copying) text",
  group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
  callback = function()
    vim.highlight.on_yank()
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
