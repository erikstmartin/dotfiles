return {
  "Wansmer/treesj",
  keys = {
    { "gS", function() require("treesj").split() end, desc = "Treesj: Split block" },
    -- gJ/gM intentionally replace the built-in join-without-spaces / go to
    -- middle of line (gS has no built-in)
    { "gJ", function() require("treesj").join() end, desc = "Treesj: Join block" },
    { "gM", function() require("treesj").toggle() end, desc = "Treesj: Toggle split/join" },
  },
  dependencies = { "nvim-treesitter/nvim-treesitter" },
  opts = {
    use_default_keymaps = false,
    max_join_length = 150,
  },
}