vim.opt_local.expandtab = false

vim.keymap.set("n", "<leader>td", function()
  require("dap-go").debug_test()
end, { buffer = 0 })
