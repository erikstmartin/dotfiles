return {
  {
    "akinsho/bufferline.nvim",
    version = "*",
    dependencies = { "nvim-tree/nvim-web-devicons", "catppuccin/nvim" },
    event = "VeryLazy",
    keys = {
      { "<leader>bp", "<cmd>BufferLineTogglePin<cr>", desc = "[B]uffer: [P]in Toggle" },
      { "<leader>bP", "<cmd>BufferLineGroupClose ungrouped<cr>", desc = "[B]uffer: [P]urge Unpinned" },
      { "<leader>bo", "<cmd>BufferLineCloseOthers<cr>", desc = "[B]uffer: [O]nly (close others)" },
      { "<leader>br", "<cmd>BufferLineCloseRight<cr>", desc = "[B]uffer: Close [R]ight" },
      { "<leader>bl", "<cmd>BufferLineCloseLeft<cr>", desc = "[B]uffer: Close [L]eft" },
      { "[b", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev Tab" },
      { "]b", "<cmd>BufferLineCycleNext<cr>", desc = "Next Tab" },
    },
    config = function()
      local function setup_bufferline()
        require("bufferline").setup {
          options = {
            mode = "tabs",
            numbers = "none",
            close_command = "tabclose %d",
            right_mouse_command = "tabclose %d",
            left_mouse_command = "tabn %d",
            indicator = { icon = "▎", style = "icon" },
            buffer_close_icon = "󰅖",
            modified_icon = "●",
            close_icon = "",
            left_trunc_marker = "",
            right_trunc_marker = "",
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

      -- Re-apply after colorscheme loads so catppuccin integration is available
      vim.api.nvim_create_autocmd("ColorScheme", {
        pattern = "catppuccin*",
        callback = setup_bufferline,
      })

      -- Also run immediately in case colorscheme is already set
      local ok = pcall(setup_bufferline)
      if not ok then
        vim.schedule(setup_bufferline)
      end

      require("which-key").add {
        { "<leader>b", group = "[B]uffer" },
      }
    end,
  },
}
