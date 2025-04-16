return {
  {
    "vhyrro/luarocks.nvim",
    lazy = true,
    ft = "http",
    priority = 1000,
    config = true,
    opts = {
      rocks = { "lua-curl", "nvim-nio", "mimetypes", "xml2lua" },
    },
  },
  {
    "rest-nvim/rest.nvim",
    lazy = true,
    ft = "http",
    dependencies = { "vhyrro/luarocks.nvim" },
    config = function()
      vim.keymap.set("n", "<leader>hh", "<cmd>Rest run<CR>", { desc = "[H]TTP request" })
      vim.keymap.set("n", "<leader>hl", "<cmd>Rest run last<CR>", { desc = "[H]TTP [l]ast request" })
    end,
  },
}
