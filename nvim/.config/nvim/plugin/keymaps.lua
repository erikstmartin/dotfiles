-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`

-- Clear search highlighting on <Esc> in normal mode
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- Diagnostic keymaps (]d/[d/]D/[D are Neovim defaults; float on jump is set in
-- lua/custom/options.lua)
vim.keymap.set("n", "<leader>de", vim.diagnostic.open_float, { desc = "[D]iagnostic: [E]rror messages" })

vim.keymap.set("n", "<leader>dL", function()
  local new_config = not vim.diagnostic.config().virtual_lines
  vim.diagnostic.config { virtual_lines = new_config }
end, { desc = "[D]iagnostic: Toggle Virtual [L]ines" })

vim.keymap.set("n", "<leader>dT", function()
  local new_config = not vim.diagnostic.config().virtual_text
  vim.diagnostic.config { virtual_text = new_config }
end, { desc = "[D]iagnostic: Toggle Virtual [T]ext" })

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- TIP: Disable arrow keys in normal mode
-- vim.keymap.set('n', '<left>', '<cmd>echo "Use h to move!!"<CR>')
-- vim.keymap.set('n', '<right>', '<cmd>echo "Use l to move!!"<CR>')
-- vim.keymap.set('n', '<up>', '<cmd>echo "Use k to move!!"<CR>')
-- vim.keymap.set('n', '<down>', '<cmd>echo "Use j to move!!"<CR>')

-- Window (split) navigation
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Move focus to the left window" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Move focus to the lower window" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Move focus to the upper window" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Move focus to the right window" })

-- Resize windows
vim.keymap.set("n", "<M-h>", "<C-w>5<", { desc = "Decrease window width" })
vim.keymap.set("n", "<M-l>", "<C-w>5>", { desc = "Increase window width" })
vim.keymap.set("n", "<M-k>", "<C-w>+", { desc = "Increase window height" })
vim.keymap.set("n", "<M-j>", "<C-w>-", { desc = "Decrease window height" })

vim.keymap.set("n", "<leader>q", "<cmd>q<CR>", { desc = "Quit" })
vim.keymap.set("n", "<leader>Q", "<cmd>qall<CR>", { desc = "Quit All" })
vim.keymap.set("n", "<C-s>", "<cmd>w<CR>", { desc = "Save" })
