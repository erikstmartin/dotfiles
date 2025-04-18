local function fmt_mode(mode)
  local map = {
    ["COMMAND"] = "CMD",
    ["TERMINAL"] = "TERM",
    ["V-BLOCK"] = "V-BLK",
    ["V-REPLACE"] = "V-RPL",
    ["O-PENDING"] = "OP",
  }
  return map[mode] or mode
end

local function lsp_clients()
  local clients = vim.lsp.get_clients({ bufnr = 0 })
  if #clients == 0 then
    return "󰒍 none"
  end
  local names = {}
  for _, client in ipairs(clients) do
    names[#names + 1] = client.name
  end
  return "󰒍 " .. table.concat(names, ",")
end

local function resolve_theme()
  local ok, lualine_theme = pcall(require, "catppuccin.utils.lualine")
  if not ok then
    return "auto"
  end
  local ok_theme, theme = pcall(lualine_theme)
  if ok_theme and theme then
    return theme
  end
  return "auto"
end

local function setup_lualine()
  local theme = resolve_theme()
  require("lualine").setup {
    options = {
      theme = theme,
      globalstatus = true,
      component_separators = { left = "│", right = "│" },
      section_separators = { left = "", right = "" },
      disabled_filetypes = { statusline = { "dashboard", "alpha", "starter" } },
    },
    sections = {
      lualine_a = {
        {
          "mode",
          icon = "",
          fmt = fmt_mode,
        },
      },
      lualine_b = {
        {
          "filename",
          path = 1,
          file_status = true,
          newfile_status = true,
          symbols = {
            modified = " ●",
            readonly = " ",
            unnamed = " [No Name]",
            newfile = " ",
          },
          color = { fg = "#cdd6f4" },
        },
      },
      lualine_c = {
        {
          "branch",
          icon = "",
          color = { fg = "#89b4fa", gui = "bold" },
        },
        {
          "diff",
          symbols = {
            added = " ",
            modified = " ",
            removed = " ",
          },
          diff_color = {
            added    = { fg = "#a6e3a1" },
            modified = { fg = "#f9e2af" },
            removed  = { fg = "#f38ba8" },
          },
        },
      },
      lualine_x = {
        {
          "diagnostics",
          sources = { "nvim_lsp" },
          symbols = {
            error = " ",
            warn  = " ",
            info  = " ",
            hint  = "󰌵 ",
          },
        },
      },
      lualine_y = {
        {
          lsp_clients,
          color = { fg = "#a6adc8" },
        },
        {
          "filetype",
          icon_only = false,
          color = { fg = "#94e2d5" },
        },
      },
      lualine_z = {
        {
          "progress",
          icon = "",
        },
        {
          "location",
          icon = "",
        },
      },
    },
    inactive_sections = {
      lualine_a = {},
      lualine_b = {},
      lualine_c = { "filename" },
      lualine_x = { "location" },
      lualine_y = {},
      lualine_z = {},
    },
    extensions = { "lazy", "trouble", "quickfix" },
  }
end

return {
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons", "catppuccin/nvim" },
    config = function()
      setup_lualine()
    end,
  },
}
