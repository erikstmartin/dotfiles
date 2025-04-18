return {
  {
    "mistweaverco/kulala.nvim",
    lazy = true,
    ft = { "http", "rest" },
    opts = {
      global_keymaps = false,
      lsp = { enable = true, formatter = true },
    },
    config = function(_, opts)
      require("kulala").setup(opts)
      local function buf_map(key, fn, desc)
        vim.keymap.set("n", key, fn, { desc = desc, buffer = true })
      end

      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "http", "rest" },
        callback = function()
          require("which-key").add {
            { "<leader>h", group = "[H]TTP", buffer = true },
          }
          buf_map("<leader>hh", function() require("kulala").run() end, "[H]TTP request")
          buf_map("<leader>hl", function() require("kulala").replay() end, "[H]TTP [l]ast request")
          buf_map("<leader>ha", function() require("kulala").run_all() end, "[H]TTP [a]ll requests")
          buf_map("<leader>hs", function() require("kulala").scratchpad() end, "[H]TTP [s]cratchpad")
          buf_map("<leader>hA", vim.lsp.buf.code_action, "[H]TTP code [A]ctions")
        end,
      })
    end,
  },
}
