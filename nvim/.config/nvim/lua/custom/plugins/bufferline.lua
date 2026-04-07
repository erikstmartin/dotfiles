return {
  {
    "akinsho/bufferline.nvim",
    version = "*",
    dependencies = { "catppuccin/nvim" },
    -- Load on the first real file/tab rather than VeryLazy: loading enables the
    -- tabline (always_show_bufferline), which would show over the dashboard
    event = { "BufReadPost", "BufNewFile", "TabNew" },
    keys = {
      -- mode = "tabs": these act on tab pages, not buffers
      { "<leader>bo", "<cmd>BufferLineCloseOthers<cr>", desc = "[B]uffer: [O]nly (close other tabs)" },
      { "<leader>br", "<cmd>BufferLineCloseRight<cr>", desc = "[B]uffer: Close tabs to the [R]ight" },
      { "<leader>bl", "<cmd>BufferLineCloseLeft<cr>", desc = "[B]uffer: Close tabs to the [L]eft" },
      -- [b/]b intentionally replace the built-in :bprevious/:bnext (tabs here)
      { "[b", "<cmd>BufferLineCyclePrev<cr>", desc = "Previous tab" },
      { "]b", "<cmd>BufferLineCycleNext<cr>", desc = "Next tab" },
    },
    config = function()
      local function close_tab(handle)
        vim.cmd.tabclose(vim.api.nvim_tabpage_get_number(handle))
      end

      local function setup()
        require("bufferline").setup {
          options = {
            mode = "tabs",
            numbers = "none",
            -- In tabs mode bufferline passes the tabpage *handle*, not the tab
            -- number, so "tabn %d"/"tabclose %d" hit the wrong tab (or E475)
            -- once a tab has been closed
            close_command = close_tab,
            right_mouse_command = close_tab,
            left_mouse_command = vim.api.nvim_set_current_tabpage,
            indicator = { icon = "▎", style = "icon" },
            buffer_close_icon = "󰅖",
            modified_icon = "●",
            max_name_length = 30,
            max_prefix_length = 15,
            truncate_names = true,
            tab_size = 21,
            diagnostics = false,
            show_buffer_icons = true,
            show_buffer_close_icons = true,
            show_close_icon = true,
            show_tab_indicators = false,
            persist_buffer_sort = true,
            separator_style = "thin",
            enforce_regular_tabs = false,
            always_show_bufferline = true,
            sort_by = "tabs",
            offsets = {
              {
                filetype = "snacks_layout_box",
                text = "Explorer",
                text_align = "left",
                separator = true,
              },
            },
          },
          highlights = require("catppuccin.special.bufferline").get_theme(),
        }
      end

      setup()
      -- Re-apply theme highlights when the catppuccin flavour changes
      vim.api.nvim_create_autocmd("ColorScheme", { pattern = "catppuccin*", callback = setup })
    end,
  },
}
