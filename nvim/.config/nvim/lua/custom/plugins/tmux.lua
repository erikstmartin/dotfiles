return {
  "mrjones2014/smart-splits.nvim",
  config = function()
    require("smart-splits").setup {
      -- This is the default configuration
      enable = true,
      lazy = false,
      ignored_buftypes = {
        "nofile",
        "quickfix",
        "prompt",
      },
      -- Ignored filetypes (only while resizing)
      ignored_filetypes = { "NvimTree" },
    }

    vim.keymap.set("n", "<A-h>", require("smart-splits").resize_left)
    vim.keymap.set("n", "<A-j>", require("smart-splits").resize_down)
    vim.keymap.set("n", "<A-k>", require("smart-splits").resize_up)
    vim.keymap.set("n", "<A-l>", require("smart-splits").resize_right)

    -- moving between splits
    vim.keymap.set("n", "<C-h>", require("smart-splits").move_cursor_left)
    vim.keymap.set("n", "<C-j>", require("smart-splits").move_cursor_down)
    vim.keymap.set("n", "<C-k>", require("smart-splits").move_cursor_up)
    vim.keymap.set("n", "<C-l>", require("smart-splits").move_cursor_right)
    -- vim.keymap.set("n", "<C-\\>", require("smart-splits").move_cursor_previous)
    --
    -- swapping buffers between windows
    vim.keymap.set("n", "<C-m>h", require("smart-splits").swap_buf_left)
    vim.keymap.set("n", "<C-m>j", require("smart-splits").swap_buf_down)
    vim.keymap.set("n", "<C-m>k", require("smart-splits").swap_buf_up)
    vim.keymap.set("n", "<C-m>l", require("smart-splits").swap_buf_right)
  end,
}
