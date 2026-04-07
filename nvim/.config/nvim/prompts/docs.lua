-- Placeholder functions for docs.md (`${docs.<name>}`). Inline prompts don't
-- expand editor context like #{buffer}, so the file is inserted here instead.
local MAX_LINES = 2000

return {
  --- The whole buffer, for matching the file's existing documentation style
  buffer = function(args)
    local bufnr = args.context.bufnr
    local count = vim.api.nvim_buf_line_count(bufnr)
    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, math.min(count, MAX_LINES), false)
    local text = table.concat(lines, "\n")
    if count > MAX_LINES then
      text = text .. ("\n... (truncated: %d more lines)"):format(count - MAX_LINES)
    end
    return text
  end,
}
