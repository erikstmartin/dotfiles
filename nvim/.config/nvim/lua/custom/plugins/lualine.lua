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

-- Copilot has its own icon component, so it's left out of the LSP list
local function lsp_clients()
  local names = {}
  for _, client in ipairs(vim.lsp.get_clients { bufnr = 0 }) do
    if client.name ~= "copilot" then
      names[#names + 1] = client.name
    end
  end
  if #names == 0 then
    return "󰒍 none"
  end
  return "󰒍 " .. table.concat(names, ",")
end

local function copilot_attached()
  return #vim.lsp.get_clients { bufnr = 0, name = "copilot" } > 0
end

-- Hide lower-priority components on narrow screens (globalstatus spans the
-- whole width) so mode/file/branch/diff/diagnostics stay visible
local function wide()
  return vim.o.columns >= 100
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
      disabled_filetypes = { statusline = { "snacks_dashboard" } },
    },
    sections = {
      lualine_a = {
        {
          "mode",
          icon = "",
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
            readonly = " 󰌾",
            unnamed = " [No Name]",
            newfile = " 󰎔",
          },
          color = { fg = "#cdd6f4" },
        },
      },
      lualine_c = {
        {
          "branch",
          color = { fg = "#89b4fa", gui = "bold" },
        },
        {
          "diff",
          symbols = {
            added = " ",
            modified = " ",
            removed = " ",
          },
          diff_color = {
            added    = { fg = "#a6e3a1" },
            modified = { fg = "#f9e2af" },
            removed  = { fg = "#f38ba8" },
          },
        },
      },
      lualine_x = {
        -- Pending keys: counts/operators (needs showcmdloc=statusline)
        { "%S" },
        { "searchcount", maxcount = 999, timeout = 250 },
        -- Macro recording indicator (there's no cmdline row to show it with cmdheight=0)
        {
          function()
            return "󰑋 @" .. vim.fn.reg_recording()
          end,
          cond = function()
            return vim.fn.reg_recording() ~= ""
          end,
          color = { fg = "#f38ba8" },
        },
        {
          "diagnostics",
          sources = { "nvim_diagnostic" },
          -- Same icons as the sign column (lua/custom/options.lua)
          symbols = (function()
            local text = vim.diagnostic.config().signs.text
            local sev = vim.diagnostic.severity
            return {
              error = text[sev.ERROR] .. " ",
              warn = text[sev.WARN] .. " ",
              info = text[sev.INFO] .. " ",
              hint = text[sev.HINT] .. " ",
            }
          end)(),
        },
      },
      lualine_y = {
        {
          function()
            return ""
          end,
          cond = copilot_attached,
          color = { fg = "#a6adc8" },
        },
        {
          lsp_clients,
          cond = wide,
          color = { fg = "#a6adc8" },
        },
        {
          "filetype",
          icon_only = false,
          cond = wide,
          color = { fg = "#94e2d5" },
        },
      },
      lualine_z = {
        {
          "progress",
          cond = wide,
          icon = "",
        },
        "location",
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
    event = "VeryLazy",
    dependencies = { "catppuccin/nvim" },
    config = function()
      setup_lualine()
      -- Show/hide the recording indicator immediately (lualine otherwise
      -- refreshes on a 1s timer)
      vim.api.nvim_create_autocmd({ "RecordingEnter", "RecordingLeave" }, {
        group = vim.api.nvim_create_augroup("lualine-recording", { clear = true }),
        callback = function()
          vim.schedule(require("lualine").refresh)
        end,
      })
    end,
  },
}
