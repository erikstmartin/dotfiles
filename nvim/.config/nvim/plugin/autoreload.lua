-- Reload buffers when their file changes on disk (e.g. an agent editing in
-- another pane), using one vim.uv fs_event watcher per buffer instead of polling.

local uv = vim.uv
local watchers = {} ---@type table<integer, uv.uv_fs_event_t>

local function unwatch(buf)
  local w = watchers[buf]
  if w then
    watchers[buf] = nil
    w:stop()
    if not w:is_closing() then
      w:close()
    end
  end
end

local function watch(buf)
  unwatch(buf)
  if not vim.api.nvim_buf_is_valid(buf) or vim.bo[buf].buftype ~= "" then
    return
  end
  local path = vim.api.nvim_buf_get_name(buf)
  if path == "" or not uv.fs_stat(path) then
    return
  end
  local w = uv.new_fs_event()
  if not w then
    return
  end
  watchers[buf] = w
  w:start(
    path,
    {},
    vim.schedule_wrap(function(err, _, events)
      if not vim.api.nvim_buf_is_valid(buf) then
        return unwatch(buf)
      end
      -- Many tools save by writing a temp file and renaming it over the
      -- original, which ends this watch; re-arm it on the new file
      if err or events.rename then
        watch(buf)
      end
      if vim.api.nvim_buf_is_loaded(buf) then
        vim.cmd.checktime(buf)
      end
    end)
  )
end

local group = vim.api.nvim_create_augroup("autoreload", { clear = true })

vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost", "BufFilePost" }, {
  group = group,
  callback = function(args)
    watch(args.buf)
  end,
})

vim.api.nvim_create_autocmd({ "BufDelete", "BufWipeout", "BufUnload" }, {
  group = group,
  callback = function(args)
    unwatch(args.buf)
  end,
})

-- Safety net for anything a watcher missed (e.g. the file was briefly gone)
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "TermLeave" }, {
  group = group,
  callback = function()
    if vim.fn.getcmdwintype() == "" then
      vim.cmd "silent! checktime"
    end
  end,
})
