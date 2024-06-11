local trim_spaces = true

vim.keymap.set("n", "<leader>tt", function()
  require("toggleterm").toggle(vim.v.count)
end, { desc = "[T]erminal [T]oggle" })

vim.keymap.set("v", "<leader>tt", function()
  require("toggleterm").toggle(vim.v.count)
end, { desc = "[T]erminal [T]oggle" })

vim.keymap.set("n", "<leader>tl", function()
  require("toggleterm").send_lines_to_terminal("single_line", trim_spaces, { args = vim.v.count })
end, { desc = "Terminal Execute [L]ine" })

vim.keymap.set("v", "<leader>ts", function()
  require("toggleterm").send_lines_to_terminal("visual_selection", trim_spaces, { args = vim.v.count })
end, { desc = "Terminal Execute [V]isual Selection" })
