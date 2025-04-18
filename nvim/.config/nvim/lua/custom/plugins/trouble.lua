return {
  "folke/trouble.nvim",
  cmd = { "Trouble" },
  keys = {
    { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Trouble: Diagnostics (all)" },
    { "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Trouble: Diagnostics (buffer)" },
    { "<leader>xl", "<cmd>Trouble lsp toggle focus=false win.position=right<cr>", desc = "Trouble: LSP (definitions/references)" },
    { "<leader>xq", "<cmd>Trouble qflist toggle<cr>", desc = "Trouble: Quickfix" },
    { "<leader>xL", "<cmd>Trouble loclist toggle<cr>", desc = "Trouble: Loclist" },
    { "<leader>xt", "<cmd>Trouble todo toggle<cr>", desc = "Trouble: Todo" },
    { "<leader>xs", "<cmd>Trouble symbols toggle focus=false<cr>", desc = "Trouble: Symbols" },
  },
  opts = {},
}
