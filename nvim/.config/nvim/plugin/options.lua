local opt = vim.opt

-- Make line numbers default (disabled to prevent dashboard issues)
vim.opt.number = false

-- Enable line numbers for non-dashboard buffers
local line_numbers_group = vim.api.nvim_create_augroup("smart_line_numbers", { clear = true })
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile", "BufWinEnter" }, {
  group = line_numbers_group,
  callback = function(ev)
    if vim.bo[ev.buf].filetype ~= "snacks_dashboard" then
      vim.wo.number = true
    end
  end,
})
-- You can also add relative line numbers, to help with jumping.
--vim.opt.relativenumber = false

-- Enable mouse mode, can be useful for resizing splits for example!
vim.opt.mouse = "a"

-- Enable true color support
vim.opt.termguicolors = true

-- Don't show the mode, since it's already in the status line
vim.opt.showmode = false

-- Remove command-line space to make status line flush with tmux
-- vim.opt.cmdheight = 0  -- Disabled: breaks popup window option inheritance

vim.opt.clipboard = "unnamedplus"

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
vim.opt.breakindent = true

-- Save undo history
vim.opt.undofile = true

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Keep signcolumn on by default
vim.opt.signcolumn = "yes"

-- Decrease update time
vim.opt.updatetime = 250

-- Decrease mapped sequence wait time
-- Displays which-key popup sooner
vim.opt.timeoutlen = 300

-- Configure how new splits should be opened
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Sets how neovim will display certain whitespace characters in the editor.
--  See `:help 'list'`
--  and `:help 'listchars'`
vim.opt.list = false -- Disabled to prevent dashboard issues
-- vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
vim.opt.listchars = { tab = "  ", trail = "·", nbsp = "␣" }

-- Preview substitutions live, as you type!
opt.inccommand = "split"

-- Show which line your cursor is on
vim.opt.cursorline = false -- Disabled to prevent dashboard issues

-- Minimal number of screen lines to keep above and below the cursor.
vim.opt.scrolloff = 10

opt.shada = { "'10", "<0", "s10", "h" }

-- Don't have `o` add a comment
opt.formatoptions:remove "o"

-- Configure diagnostics
vim.diagnostic.config {
  -- virtual_text = true
  -- virtual_lines = true,
  severity_sort = true,
}

-- Protect dashboard window options from being overridden by global settings.
-- Uses OptionSet to catch ANY source that changes these options on dashboard windows.
local dashboard_guard = vim.api.nvim_create_augroup("dashboard_option_guard", { clear = true })

vim.api.nvim_create_autocmd("OptionSet", {
  group = dashboard_guard,
  pattern = "number,relativenumber,list,cursorline,signcolumn",
  callback = function()
    -- vim.v.option_type tells us if it was set globally or locally
    -- When set globally, it propagates to all windows including dashboard
    if vim.v.option_type == "global" then
      -- Schedule to run after the current option-set completes
      vim.schedule(function()
        for _, win in ipairs(vim.api.nvim_list_wins()) do
          if vim.api.nvim_win_is_valid(win) then
            local buf = vim.api.nvim_win_get_buf(win)
            if vim.bo[buf].filetype == "snacks_dashboard" then
              vim.wo[win].number = false
              vim.wo[win].relativenumber = false
              vim.wo[win].list = false
              vim.wo[win].cursorline = false
              vim.wo[win].signcolumn = "no"
            end
          end
        end
      end)
    end
  end,
})

-- Also handle the initial dashboard open and any BufWinEnter
vim.api.nvim_create_autocmd("BufWinEnter", {
  group = dashboard_guard,
  callback = function(ev)
    if vim.bo[ev.buf].filetype == "snacks_dashboard" then
      local win = vim.fn.bufwinid(ev.buf)
      if win ~= -1 then
        vim.wo[win].number = false
        vim.wo[win].relativenumber = false
        vim.wo[win].list = false
        vim.wo[win].cursorline = false
        vim.wo[win].signcolumn = "no"
        vim.wo[win].fillchars = "eob: "
      end
    end
  end,
})

-- Add immediate handler for Snacks dashboard events
vim.api.nvim_create_autocmd("User", {
  group = dashboard_guard,
  pattern = "SnacksDashboardOpened",
  callback = function()
    -- Find all dashboard windows and enforce settings
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      if vim.api.nvim_win_is_valid(win) then
        local buf = vim.api.nvim_win_get_buf(win)
        if vim.bo[buf].filetype == "snacks_dashboard" then
          vim.wo[win].number = false
          vim.wo[win].relativenumber = false
          vim.wo[win].list = false
          vim.wo[win].cursorline = false
          vim.wo[win].signcolumn = "no"
          vim.wo[win].fillchars = "eob: "
        end
      end
    end
  end,
})




