local wezterm = require("wezterm")
local act = wezterm.action

-- ---------------------------------------------------------------------------
-- Color scheme: Catppuccin Mocha "Pitch Black" (matches ghostty / tmux)
-- ---------------------------------------------------------------------------
local custom = wezterm.color.get_builtin_schemes()["Catppuccin Mocha"]
custom.background = "#11111b"
custom.foreground = "#cdd6f4"
custom.selection_fg = "#1e1e2e"
custom.selection_bg = "#f5e0dc"
custom.cursor_bg = "#f5e0dc"
custom.cursor_border = "#f5e0dc"
custom.cursor_fg = "#1e1e2e"


-- ---------------------------------------------------------------------------
-- Launcher menu (mirrors tmux prefix + Space)
-- ---------------------------------------------------------------------------
local launcher_entries = {
  { label = " Lazygit",     id = "lazygit" },
  { label = " Lazydocker",  id = "lazydocker" },
  { label = " K9s",         id = "k9s" },
  { label = " gh-dash",     id = "gh dash" },
  { label = " Obsidian",    id = "nvim \"$OBSIDIAN_VAULT\"" },
  { label = " AI Assistant", id = "ai" },
  { label = " Config",      id = "nvim ~/dotfiles" },
}

-- ---------------------------------------------------------------------------
-- Keybindings – mirroring tmux layout (leader = Alt+b)
--
-- Pane splits:
--   LEADER + -       → split pane below
--   LEADER + _       → split pane right
-- Pane navigation:
--   LEADER + h/j/k/l → move between panes
-- Pane resize:
--   LEADER + H/J/K/L → resize pane
-- Pane zoom:
--   LEADER + z / Enter → toggle zoom
-- Kill:
--   LEADER + x       → kill pane
--   LEADER + X       → kill tab
-- Tabs / windows:
--   LEADER + c       → new tab
--   LEADER + n/p     → next/prev tab
--   LEADER + Tab     → last tab
--   LEADER + 1-9     → jump to tab
--   LEADER + Ctrl+h/l → move tab left/right
--   LEADER + r       → rename tab
--   LEADER + Ctrl+r  → rename workspace
--   LEADER + Ctrl+c  → new workspace
--   LEADER + s/w     → tab navigator (fuzzy picker)
-- Swap panes:
--   LEADER + > / <   → rotate panes
-- Copy mode:
--   LEADER + [       → enter copy mode (vi keys: v=select, C-v=block, y=yank)
-- Paste:
--   LEADER + Ctrl+p  → paste from clipboard
-- Window size:
--   LEADER + m       → maximize (toggle, keeps dock)
--   LEADER + f       → fullscreen (toggle, hides dock)
-- Launcher:
--   LEADER + Space   → fuzzy app launcher
-- Sesh:
--   LEADER + t       → sesh session picker (pass-through to tmux, or direct)
-- ---------------------------------------------------------------------------

local keys = {
  -- ── Pane splits ────────────────────────────────────────────────────────
  {
    key = "-",
    mods = "LEADER",
    action = act.SplitVertical({ domain = "CurrentPaneDomain" }),
  },
  {
    key = "_",
    mods = "LEADER",
    action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }),
  },

  -- ── Pane navigation ────────────────────────────────────────────────────
  { key = "h", mods = "LEADER", action = act.ActivatePaneDirection("Left") },
  { key = "j", mods = "LEADER", action = act.ActivatePaneDirection("Down") },
  { key = "k", mods = "LEADER", action = act.ActivatePaneDirection("Up") },
  { key = "l", mods = "LEADER", action = act.ActivatePaneDirection("Right") },

  -- ── Pane resize ────────────────────────────────────────────────────────
  { key = "H", mods = "LEADER", action = act.AdjustPaneSize({ "Left", 5 }) },
  { key = "J", mods = "LEADER", action = act.AdjustPaneSize({ "Down", 5 }) },
  { key = "K", mods = "LEADER", action = act.AdjustPaneSize({ "Up", 5 }) },
  { key = "L", mods = "LEADER", action = act.AdjustPaneSize({ "Right", 5 }) },

  -- ── Pane zoom ──────────────────────────────────────────────────────────
  { key = "z",     mods = "LEADER", action = act.TogglePaneZoomState },
  { key = "Enter", mods = "LEADER", action = act.TogglePaneZoomState },

  -- ── Kill pane / window / all ───────────────────────────────────────────
  { key = "x", mods = "LEADER", action = act.CloseCurrentPane({ confirm = false }) },
  { key = "X", mods = "LEADER", action = act.CloseCurrentTab({ confirm = false }) },
  { key = "Q", mods = "LEADER", action = act.QuitApplication },
  { key = "Q", mods = "LEADER", action = act.QuitApplication },

  -- ── Window (tab) management ────────────────────────────────────────────
  { key = "c",   mods = "LEADER", action = act.SpawnTab("CurrentPaneDomain") },
  { key = "n",   mods = "LEADER", action = act.ActivateTabRelative(1) },
  { key = "p",   mods = "LEADER", action = act.ActivateTabRelative(-1) },
  { key = "Tab", mods = "LEADER", action = act.ActivateLastTab },
  { key = "1",   mods = "LEADER", action = act.ActivateTab(0) },
  { key = "2",   mods = "LEADER", action = act.ActivateTab(1) },
  { key = "3",   mods = "LEADER", action = act.ActivateTab(2) },
  { key = "4",   mods = "LEADER", action = act.ActivateTab(3) },
  { key = "5",   mods = "LEADER", action = act.ActivateTab(4) },
  { key = "6",   mods = "LEADER", action = act.ActivateTab(5) },
  { key = "7",   mods = "LEADER", action = act.ActivateTab(6) },
  { key = "8",   mods = "LEADER", action = act.ActivateTab(7) },
  { key = "9",   mods = "LEADER", action = act.ActivateTab(8) },

  -- ── Move tabs ──────────────────────────────────────────────────────────
  { key = "h", mods = "LEADER|CTRL", action = act.MoveTabRelative(-1) },
  { key = "l", mods = "LEADER|CTRL", action = act.MoveTabRelative(1) },
  {
    key = "r",
    mods = "LEADER",
    action = act.PromptInputLine({
      description = "Rename tab:",
      action = wezterm.action_callback(function(window, _, line)
        if not line or line == "" then return end
        local script = wezterm.home_dir .. "/.local/bin/rename-with-icon.sh"
        local ok, stdout, _ = wezterm.run_child_process({ script, "--print", line })
        local title = (ok and stdout ~= "") and stdout:gsub("%s+$", "") or line
        window:active_tab():set_title(title)
      end),
    }),
  },

  -- ── Rename workspace (tmux prefix + Ctrl-r) ─────────────────────────────
  {
    key = "r",
    mods = "LEADER|CTRL",
    action = act.PromptInputLine({
      description = "Rename workspace:",
      action = wezterm.action_callback(function(_, _, line)
        if not line or line == "" then return end
        wezterm.mux.rename_workspace(wezterm.mux.get_active_workspace(), line)
      end),
    }),
  },

  -- ── New workspace (tmux prefix + Ctrl-c) ─────────────────────────────────
  {
    key = "c",
    mods = "LEADER|CTRL",
    action = act.PromptInputLine({
      description = "New workspace name:",
      action = wezterm.action_callback(function(window, pane, line)
        if not line or line == "" then return end
        window:perform_action(act.SwitchToWorkspace({ name = line }), pane)
      end),
    }),
  },

  -- ── Session / tab navigator (tmux choose-tree -s / -w) ─────────────────
  { key = "s", mods = "LEADER", action = act.ShowLauncherArgs({ flags = "FUZZY|WORKSPACES" }) },
  { key = "w", mods = "LEADER", action = act.ShowTabNavigator },

  -- ── Swap panes (tmux prefix + > / <) ───────────────────────────────────
  { key = ">", mods = "LEADER", action = act.RotatePanes("Clockwise") },
  { key = "<", mods = "LEADER", action = act.RotatePanes("CounterClockwise") },

  -- ── Copy mode (tmux prefix + [) ────────────────────────────────────────
  { key = "[", mods = "LEADER", action = act.ActivateCopyMode },

  -- ── Paste (tmux prefix + Ctrl+p) ───────────────────────────────────────
  { key = "p", mods = "LEADER|CTRL", action = act.PasteFrom("Clipboard") },
  { key = "v", mods = "SUPER", action = act.PasteFrom("Clipboard") },

  -- ── Reload config ──────────────────────────────────────────────────────
  { key = "r", mods = "LEADER|ALT", action = act.ReloadConfiguration },

  -- ── Maximize window (fill screen, keep dock) ───────────────────────────
  {
    key = "m",
    mods = "LEADER",
    action = wezterm.action_callback(function(window)
      local overrides = window:get_config_overrides() or {}
      if overrides._maximized then
        overrides._maximized = nil
        window:set_config_overrides(overrides)
        window:restore()
      else
        overrides._maximized = true
        window:set_config_overrides(overrides)
        window:maximize()
      end
    end),
  },

  -- ── Fullscreen (hides dock/menubar entirely) ────────────────────────────
  { key = "f", mods = "LEADER", action = act.ToggleFullScreen },

  -- ── Sesh session picker ────────────────────────────────────────────────
  {
    key = "t",
    mods = "LEADER",
    action = wezterm.action_callback(function(window, pane)
      local shell = os.getenv("SHELL") or "/bin/zsh"
      window:perform_action(
        act.SpawnCommandInNewTab({
          args = { shell, "-ilc", "sesh picker -i" },
        }),
        pane
      )
    end),
  },

  {
    key = "o",
    mods = "LEADER",
    action = wezterm.action_callback(function(window, pane)
      local shell = os.getenv("SHELL") or "/bin/zsh"
      local cwd = pane:get_current_working_dir()
      local cwd_path = cwd and cwd.file_path or wezterm.home_dir
      window:perform_action(
        act.SpawnCommandInNewTab({
          args = { shell, "-ilc", "nvim \"$OBSIDIAN_VAULT\"" },
          cwd = cwd_path,
        }),
        pane
      )
    end),
  },

  {
    key = "a",
    mods = "LEADER",
    action = wezterm.action_callback(function(window, pane)
      local shell = os.getenv("SHELL") or "/bin/zsh"
      local cwd = pane:get_current_working_dir()
      local cwd_path = cwd and cwd.file_path or wezterm.home_dir
      window:perform_action(
        act.SpawnCommandInNewTab({
          args = { shell, "-ilc", "ai" },
          cwd = cwd_path,
        }),
        pane
      )
    end),
  },

  -- ── Launcher menu ─────────────────────────────────────────────────────
  {
    key = "Space",
    mods = "LEADER",
    action = act.InputSelector({
      title = " Launcher",
      fuzzy = true,
      choices = launcher_entries,
      action = wezterm.action_callback(function(window, pane, id, _)
        if not id then return end
        local shell = os.getenv("SHELL") or "/bin/zsh"
        local cwd = pane:get_current_working_dir()
        local cwd_path = cwd and cwd.file_path or wezterm.home_dir
        window:perform_action(
          act.SpawnCommandInNewTab({
            args = { shell, "-ilc", id },
            cwd = cwd_path,
          }),
          pane
        )
      end),
    }),
  },
}

-- ---------------------------------------------------------------------------
-- Copy mode vi key table (mirrors tmux vi copy mode)
-- ---------------------------------------------------------------------------
local copy_mode_keys = {
  { key = "v", mods = "NONE",  action = act.CopyMode({ SetSelectionMode = "Cell" }) },
  { key = "V", mods = "NONE",  action = act.CopyMode({ SetSelectionMode = "Line" }) },
  { key = "v", mods = "CTRL",  action = act.CopyMode({ SetSelectionMode = "Block" }) },
  {
    key = "y",
    mods = "NONE",
    action = act.Multiple({
      act.CopyTo("Clipboard"),
      act.CopyMode("Close"),
    }),
  },
  { key = "q",      mods = "NONE", action = act.CopyMode("Close") },
  { key = "Escape", mods = "NONE", action = act.CopyMode("Close") },
  { key = "h",      mods = "NONE", action = act.CopyMode("MoveLeft") },
  { key = "j",      mods = "NONE", action = act.CopyMode("MoveDown") },
  { key = "k",      mods = "NONE", action = act.CopyMode("MoveUp") },
  { key = "l",      mods = "NONE", action = act.CopyMode("MoveRight") },
  { key = "w",      mods = "NONE", action = act.CopyMode("MoveForwardWord") },
  { key = "b",      mods = "NONE", action = act.CopyMode("MoveBackwardWord") },
  { key = "e",      mods = "NONE", action = act.CopyMode("MoveForwardWordEnd") },
  { key = "0",      mods = "NONE", action = act.CopyMode("MoveToStartOfLine") },
  { key = "$",      mods = "NONE", action = act.CopyMode("MoveToEndOfLineContent") },
  { key = "^",      mods = "NONE", action = act.CopyMode("MoveToStartOfLineContent") },
  { key = "g",      mods = "NONE", action = act.CopyMode("MoveToScrollbackTop") },
  { key = "G",      mods = "NONE", action = act.CopyMode("MoveToScrollbackBottom") },
  { key = "u",      mods = "CTRL", action = act.CopyMode("PageUp") },
  { key = "d",      mods = "CTRL", action = act.CopyMode("PageDown") },
}

-- ---------------------------------------------------------------------------
-- Status bar (native — no plugin)
--
-- Layout (left):  [mode] > [workspace]
-- Layout (right): [ram ¦ cpu] > [battery ¦ datetime] > [cwd ¦  hostname]
--                 (ram/cpu/battery/datetime only shown in fullscreen)
--
-- Colors (Catppuccin Mocha, matching previous tabline.wez setup):
--   section a  fg=#181825  bg=#89b4fa  (blue,  bold)
--   section b  fg=#89b4fa  bg=#313244
--   section c  fg=#cdd6f4  bg=#11111b  (bar background)
--
-- Separators:  ple_right/left_half_circle_thick (section)
--              ple_right/left_half_circle_thin  (component)
--
-- Flash fix: cache last rendered strings; only call set_*_status when
-- the content actually changed.
-- ---------------------------------------------------------------------------

-- ── Colors ─────────────────────────────────────────────────────────────────
local C = {
  -- normal mode
  a_fg   = '#181825', a_bg   = '#89dceb',
  b_fg   = '#181825', b_bg   = '#89b4fa',
  c_fg   = '#cdd6f4', c_bg   = '#11111b',
  -- cwd section (lavender)
  cwd_fg = '#181825', cwd_bg = '#89b4fa',
  -- copy mode
  copy_a_fg = '#181825', copy_a_bg = '#f9e2af',
  copy_b_fg = '#f9e2af', copy_b_bg = '#313244',
  -- search mode
  srch_a_fg = '#181825', srch_a_bg = '#a6e3a1',
  srch_b_fg = '#a6e3a1', srch_b_bg = '#313244',
  -- datetime section (surface1)
  dt_fg  = '#cdd6f4', dt_bg  = '#45475a',
}

-- ── Separators ─────────────────────────────────────────────────────────────
local SEP_L  = wezterm.nerdfonts.ple_right_half_circle_thick  -- left section end cap
local SEP_R  = wezterm.nerdfonts.ple_left_half_circle_thick   -- right section end cap
local CSEP_R = wezterm.nerdfonts.ple_left_half_circle_thin    -- component separator (right side)

-- ── RAM / CPU throttle cache ────────────────────────────────────────────────
local sys_cache = { ram = '', cpu = '', ram_pressure = 0, cpu_pct = 0, last_t = 0 }

-- vm.memory_pressure: 0=normal, 1=warning, 2=critical
local function ram_pressure_color(pressure)
  if     pressure >= 2 then return '#f38ba8'  -- red: critical
  elseif pressure >= 1 then return '#f9e2af'  -- yellow: warning
  else                      return C.c_fg     -- normal
  end
end
local function threshold_color(pct)
  if     pct >= 90 then return '#f38ba8'  -- red
  elseif pct >= 75 then return '#f9e2af'  -- yellow
  else                  return C.c_fg     -- normal
  end
end
local function get_sys_stats()
  local now = os.time()
  if now - sys_cache.last_t < 3 then
    return sys_cache.ram, sys_cache.cpu, sys_cache.ram_pressure, sys_cache.cpu_pct
  end
  -- RAM used (macOS vm_stat)
  local ram = ''
  local ok, out = wezterm.run_child_process({ 'vm_stat' })
  if ok then
    local page_size  = tonumber(out:match('page size of (%d+) bytes'))
    local anon       = tonumber(out:match('Anonymous pages:%s+(%d+)'))
    local purgeable  = tonumber(out:match('Pages purgeable:%s+(%d+)'))
    local wired      = tonumber(out:match('Pages wired down:%s+(%d+)'))
    local compressed = tonumber(out:match('Pages occupied by compressor:%s+(%d+)'))
    if page_size and anon and purgeable and wired and compressed then
      local used_gb = (anon - purgeable + wired + compressed) * page_size / 1024 / 1024 / 1024
      ram = string.format('%.2f GB', used_gb)
    end
  end

  -- RAM pressure (kernel memory pressure level, accounts for compression/cache)
  local ram_pressure = 0
  local okp, outp = wezterm.run_child_process({ 'sysctl', '-n', 'vm.memory_pressure' })
  if okp then
    ram_pressure = tonumber(outp:match('%d+')) or 0
  end
  -- CPU (macOS ps sum / ncpu)
  local cpu = ''
  local cpu_pct = 0
  local ok2, out2 = wezterm.run_child_process({
    'bash', '-c', "ps -A -o %cpu | LC_NUMERIC=C awk '{s+=$1} END {print s}'",
  })
  if ok2 then
    local ok3, out3 = wezterm.run_child_process({ 'sysctl', '-n', 'hw.ncpu' })
    local ncpu = ok3 and tonumber(out3) or 1
    local total = tonumber(out2:match('%S+'))
    if total and ncpu then
      cpu_pct = total / ncpu
      cpu = string.format('%.2f%%', cpu_pct)
    end
  end
  sys_cache.ram    = ram
  sys_cache.cpu          = cpu
  sys_cache.ram_pressure = ram_pressure
  sys_cache.cpu_pct      = cpu_pct
  sys_cache.last_t       = now
  return ram, cpu, ram_pressure, cpu_pct
end

-- ── Battery ─────────────────────────────────────────────────────────────────
local bat_icons = {
  empty          = wezterm.nerdfonts.fa_battery_empty,
  quarter        = wezterm.nerdfonts.fa_battery_quarter,
  half           = wezterm.nerdfonts.fa_battery_half,
  three_quarters = wezterm.nerdfonts.fa_battery_three_quarters,
  full           = wezterm.nerdfonts.fa_battery_full,
}

local function get_battery()
  local parts = {}
  local lowest_pct = 100
  for _, b in ipairs(wezterm.battery_info()) do
    local pct = b.state_of_charge * 100
    if pct < lowest_pct then lowest_pct = pct end
    local icon
    if     pct <= 10 then icon = bat_icons.empty
    elseif pct <= 25 then icon = bat_icons.quarter
    elseif pct <= 50 then icon = bat_icons.half
    elseif pct <= 75 then icon = bat_icons.three_quarters
    else                  icon = bat_icons.full
    end
    table.insert(parts, icon .. ' ' .. string.format('%.0f%%', pct))
  end
  local color, is_pill
  if     lowest_pct <= 10 then color = '#f38ba8'; is_pill = true
  elseif lowest_pct <= 20 then color = '#f38ba8'; is_pill = false
  elseif lowest_pct <= 50 then color = '#f9e2af'; is_pill = false
  else                        color = C.c_fg;    is_pill = false
  end
  return table.concat(parts, ' '), color, is_pill
end

-- ── Datetime ────────────────────────────────────────────────────────────────
local hour_icons = {
  ['00'] = wezterm.nerdfonts.md_clock_time_twelve_outline,
  ['01'] = wezterm.nerdfonts.md_clock_time_one_outline,
  ['02'] = wezterm.nerdfonts.md_clock_time_two_outline,
  ['03'] = wezterm.nerdfonts.md_clock_time_three_outline,
  ['04'] = wezterm.nerdfonts.md_clock_time_four_outline,
  ['05'] = wezterm.nerdfonts.md_clock_time_five_outline,
  ['06'] = wezterm.nerdfonts.md_clock_time_six_outline,
  ['07'] = wezterm.nerdfonts.md_clock_time_seven_outline,
  ['08'] = wezterm.nerdfonts.md_clock_time_eight_outline,
  ['09'] = wezterm.nerdfonts.md_clock_time_nine_outline,
  ['10'] = wezterm.nerdfonts.md_clock_time_ten_outline,
  ['11'] = wezterm.nerdfonts.md_clock_time_eleven_outline,
  ['12'] = wezterm.nerdfonts.md_clock_time_twelve,
  ['13'] = wezterm.nerdfonts.md_clock_time_one,
  ['14'] = wezterm.nerdfonts.md_clock_time_two,
  ['15'] = wezterm.nerdfonts.md_clock_time_three,
  ['16'] = wezterm.nerdfonts.md_clock_time_four,
  ['17'] = wezterm.nerdfonts.md_clock_time_five,
  ['18'] = wezterm.nerdfonts.md_clock_time_six,
  ['19'] = wezterm.nerdfonts.md_clock_time_seven,
  ['20'] = wezterm.nerdfonts.md_clock_time_eight,
  ['21'] = wezterm.nerdfonts.md_clock_time_nine,
  ['22'] = wezterm.nerdfonts.md_clock_time_ten,
  ['23'] = wezterm.nerdfonts.md_clock_time_eleven,
}

local function get_datetime()
  local t    = wezterm.time.now()
  local hour = t:format('%H')
  local icon = hour_icons[hour] or ''
  return icon .. ' ' .. t:format('%I:%M %p')
end

-- ── Hostname + CWD ──────────────────────────────────────────────────────────
local function get_host_and_cwd(window)
  local cwd_uri = window:active_pane():get_current_working_dir()
  local hostname = ''
  local cwd = ''
  if cwd_uri == nil then
    hostname = wezterm.hostname()
  elseif type(cwd_uri) == 'userdata' then
    hostname = cwd_uri.host or wezterm.hostname()
    cwd = cwd_uri.file_path or ''
  else
    -- legacy string URI: file:///hostname/path
    local uri = cwd_uri:sub(8)  -- strip 'file://'
    local slash = uri:find('/')
    if slash then
      hostname = uri:sub(1, slash - 1)
      cwd = uri:sub(slash)
    end
  end
  local dot = hostname:find('[.]')
  if dot then hostname = hostname:sub(1, dot - 1) end
  -- Shorten home dir to ~
  local home = wezterm.home_dir
  if cwd:sub(1, #home) == home then
    cwd = '~' .. cwd:sub(#home + 1)
  end
  -- Strip trailing slash
  cwd = cwd:gsub('/$', '')
  return hostname, cwd
end

-- ── Mode helpers ────────────────────────────────────────────────────────────
local function get_mode(window)
  local kt = window:active_key_table()
  if kt == nil or not kt:find('_mode$') then return 'normal_mode' end
  return kt
end

local function mode_colors(mode)
  if mode == 'copy_mode' then
    return C.copy_a_fg, C.copy_a_bg, C.copy_b_fg, C.copy_b_bg
  elseif mode == 'search_mode' then
    return C.srch_a_fg, C.srch_a_bg, C.srch_b_fg, C.srch_b_bg
  end
  return C.a_fg, C.a_bg, C.b_fg, C.b_bg
end

-- ── Render helpers ──────────────────────────────────────────────────────────
-- Builds a wezterm.format-compatible table for a styled segment + separator.

local function left_seg(text, fg, bg, sep_fg, sep_bg)
  return {
    { Foreground = { Color = fg } }, { Background = { Color = bg } },
    { Attribute = { Intensity = 'Bold' } },
    { Text = ' ' .. text .. ' ' },
    { Attribute = { Intensity = 'Normal' } },
    { Foreground = { Color = bg } }, { Background = { Color = sep_bg } },
    { Text = SEP_L },
  }
end

local function right_seg_start(sep_fg, sep_bg, content_fg, content_bg)
  -- separator that transitions INTO this segment from the left
  return {
    { Foreground = { Color = sep_fg } }, { Background = { Color = sep_bg } },
    { Text = SEP_R },
    { Foreground = { Color = content_fg } }, { Background = { Color = content_bg } },
  }
end

local function component_sep(fg, bg)
  return {
    { Foreground = { Color = fg } }, { Background = { Color = bg } },
    { Text = CSEP_R },
  }
end

-- ── Cache: only redraw when content changes ─────────────────────────────────
local last_left  = nil
local last_right = nil

-- ── update-status event ─────────────────────────────────────────────────────
wezterm.on('update-status', function(window)
  local is_fs   = window:get_dimensions().is_full_screen
  local mode    = get_mode(window)
  local a_fg, a_bg, b_fg, b_bg = mode_colors(mode)

  -- ── Left status ──────────────────────────────────────────────────────────
  -- [mode] > [workspace]
  local mode_label = mode:gsub('_mode', ''):upper()
  local workspace  = wezterm.mux.get_active_workspace():match('[^/\\]+$') or ''

  local left_elems = {}
  -- section a: mode
  for _, e in ipairs(left_seg(mode_label, a_fg, a_bg, a_bg, b_bg)) do
    table.insert(left_elems, e)
  end
  -- section b: workspace (tmux icon + name)
  table.insert(left_elems, { Foreground = { Color = b_fg } })
  table.insert(left_elems, { Background = { Color = b_bg } })
  table.insert(left_elems, { Text = ' ' .. wezterm.nerdfonts.cod_terminal_tmux .. ' ' .. workspace .. ' ' })
  -- section b → c separator
  table.insert(left_elems, { Foreground = { Color = b_bg } })
  table.insert(left_elems, { Background = { Color = C.c_bg } })
  table.insert(left_elems, { Text = SEP_L })

  local new_left = wezterm.format(left_elems)
  if new_left ~= last_left then
    window:set_left_status(new_left)
    last_left = new_left
  end

  -- ── Right status ─────────────────────────────────────────────────────────
  -- [ram ¦ cpu] > [battery ¦ datetime] > [cwd ¦  hostname]
  local hostname, cwd = get_host_and_cwd(window)
  local right_elems = {}

  if is_fs then
    local ram, cpu, ram_pressure, cpu_pct = get_sys_stats()
    local ram_color = ram_pressure_color(ram_pressure)
    local cpu_color = threshold_color(cpu_pct)
    -- section x (c-style): ram + cpu (combined, per-component color)
    for _, e in ipairs(component_sep(C.c_fg, C.c_bg)) do table.insert(right_elems, e) end
    table.insert(right_elems, { Foreground = { Color = ram_color } })
    table.insert(right_elems, { Background = { Color = C.c_bg } })
    table.insert(right_elems, { Text = ' ' .. wezterm.nerdfonts.cod_server .. ' ' .. ram })
    table.insert(right_elems, { Foreground = { Color = C.c_fg } })
    table.insert(right_elems, { Text = '  ' })
    table.insert(right_elems, { Foreground = { Color = cpu_color } })
    table.insert(right_elems, { Text = wezterm.nerdfonts.oct_cpu .. ' ' .. cpu .. ' ' })
    -- battery
    local bat_str, bat_color, bat_is_pill = get_battery()
    if bat_is_pill then
      local bat_bg = bat_color  -- red
      local bat_fg = '#181825'  -- dark text on red bg
      -- entry cap: thick ( in red
      table.insert(right_elems, { Foreground = { Color = bat_bg } })
      table.insert(right_elems, { Background = { Color = C.c_bg } })
      table.insert(right_elems, { Text = SEP_R })
      -- battery content
      table.insert(right_elems, { Foreground = { Color = bat_fg } })
      table.insert(right_elems, { Background = { Color = bat_bg } })
      table.insert(right_elems, { Text = ' ' .. bat_str .. ' ' })
      -- direct exit: battery→datetime (no bar-color gap)
      table.insert(right_elems, { Foreground = { Color = C.dt_bg } })
      table.insert(right_elems, { Background = { Color = bat_bg } })
      table.insert(right_elems, { Text = SEP_R })
      table.insert(right_elems, { Foreground = { Color = C.dt_fg } })
      table.insert(right_elems, { Background = { Color = C.dt_bg } })
      table.insert(right_elems, { Text = ' ' .. get_datetime() .. ' ' })
    else
      -- normal/yellow/red text inline
      for _, e in ipairs(component_sep(C.c_fg, C.c_bg)) do table.insert(right_elems, e) end
      table.insert(right_elems, { Foreground = { Color = bat_color } })
      table.insert(right_elems, { Background = { Color = C.c_bg } })
      table.insert(right_elems, { Text = ' ' .. bat_str .. ' ' })
      -- direct entry: bar→datetime
      table.insert(right_elems, { Foreground = { Color = C.dt_bg } })
      table.insert(right_elems, { Background = { Color = C.c_bg } })
      table.insert(right_elems, { Text = SEP_R })
      table.insert(right_elems, { Foreground = { Color = C.dt_fg } })
      table.insert(right_elems, { Background = { Color = C.dt_bg } })
      table.insert(right_elems, { Text = ' ' .. get_datetime() .. ' ' })
    end

    -- section z: cwd (lavender) + hostname (blue)
    for _, e in ipairs(right_seg_start(C.cwd_bg, C.dt_bg, C.cwd_fg, C.cwd_bg)) do table.insert(right_elems, e) end
  else
    -- not fullscreen: cwd (lavender) + hostname (blue)
    for _, e in ipairs(right_seg_start(C.cwd_bg, C.c_bg, C.cwd_fg, C.cwd_bg)) do table.insert(right_elems, e) end
  end

  -- cwd component (lavender section)
  if cwd ~= '' then
    table.insert(right_elems, { Text = ' ' .. wezterm.nerdfonts.oct_file_directory .. ' ' .. cwd .. ' ' })
    -- transition lavender -> blue for hostname
    for _, e in ipairs(right_seg_start(a_bg, C.cwd_bg, a_fg, a_bg)) do table.insert(right_elems, e) end
  else
    -- no cwd: start hostname section directly
    for _, e in ipairs(right_seg_start(a_bg, C.c_bg, a_fg, a_bg)) do table.insert(right_elems, e) end
  end
  -- hostname
  table.insert(right_elems, { Attribute = { Intensity = 'Bold' } })
  table.insert(right_elems, { Text = ' ' .. wezterm.nerdfonts.oct_server .. ' ' .. hostname .. ' ' })
  table.insert(right_elems, { Attribute = { Intensity = 'Normal' } })

  local new_right = wezterm.format(right_elems)
  if new_right ~= last_right then
    window:set_right_status(new_right)
    last_right = new_right
  end
end)

-- ---------------------------------------------------------------------------
-- Icon lookup (mirrors bin/rename-with-icon.sh)
-- ---------------------------------------------------------------------------
local icon_map = {
  zsh = utf8.char(0xe795), bash = utf8.char(0xe795), sh = utf8.char(0xe795), fish = utf8.char(0xe795),
  nvim = utf8.char(0xe6ae), neovim = utf8.char(0xe6ae),
  vim = utf8.char(0xe62b), vi = utf8.char(0xe62b),
  lazygit = utf8.char(0xe702), git = utf8.char(0xe702),
  lazydocker = utf8.char(0xf21f), docker = utf8.char(0xf21f),
  k9s = utf8.char(0x2638), k8s = utf8.char(0x2638), kubectl = utf8.char(0x2638),
  ['gh-dash'] = utf8.char(0xf09b), gh = utf8.char(0xf09b), github = utf8.char(0xf09b),
  posting = utf8.char(0xf059f), curl = utf8.char(0xf059f), curlie = utf8.char(0xf059f), http = utf8.char(0xf059f), httpie = utf8.char(0xf059f), xh = utf8.char(0xf059f), newman = utf8.char(0xf059f), k6 = utf8.char(0xf059f),
  opencode = utf8.char(0xf16a7), crush = utf8.char(0xf16a7), claude = utf8.char(0xf16a7), copilot = utf8.char(0xf16a7), ai = utf8.char(0xf16a7), llmfit = utf8.char(0xf16a7), models = utf8.char(0xf16a7),
  ssh = utf8.char(0xf08c0), mosh = utf8.char(0xf08c0),
  scratch = utf8.char(0xf1781), notes = utf8.char(0xf1781), obsidian = utf8.char(0xf1781),
}

local function strip_icon_prefix(s)
  s = s:match('^%s*(.-)%s*$')  -- trim
  local first, rest = s:match('^(%S+)%s+(.+)$')
  if not first then return s end
  -- If the first word contains non-alphanumeric chars (i.e. a glyph), strip it
  if first:match('[^%w_.:/%-]') then return rest end
  return s
end

local function add_icon(title)
  local bare = strip_icon_prefix(title)
  local key = bare:lower():match('^(%S+)')
  if not key then return title end
  local icon = icon_map[key]
  if icon then return icon .. ' ' .. bare end
  return title
end

-- ---------------------------------------------------------------------------
-- Tab title (format-tab-title event)
-- ---------------------------------------------------------------------------
wezterm.on('format-tab-title', function(tab, _, _, _, hover, _)
  local raw_title = tab.tab_title ~= '' and tab.tab_title or tab.active_pane.title
  local title = add_icon(raw_title)
  local idx   = tostring(tab.tab_index + 1)
  local lead  = tab.tab_index == 0 and '  ' or ''

  if tab.is_active then
    local out = {}
    if lead ~= '' then
      table.insert(out, { Foreground = { Color = '#cdd6f4' } })
      table.insert(out, { Background = { Color = '#11111b' } })
      table.insert(out, { Text = lead })
    end
    table.insert(out, { Foreground = { Color = '#181825' } })
    table.insert(out, { Background = { Color = '#89dceb' } })
    table.insert(out, { Text = ' ' .. idx .. ' ' })
    table.insert(out, { Foreground = { Color = '#cdd6f4' } })
    table.insert(out, { Background = { Color = '#11111b' } })
    table.insert(out, { Text = ' ' .. title .. ' ' })
    table.insert(out, { Foreground = { Color = '#45475a' } })
    table.insert(out, { Background = { Color = '#11111b' } })
    table.insert(out, { Text = '|' })
    return out
  elseif hover then
    return {
      { Foreground = { Color = '#cdd6f4' } }, { Background = { Color = '#11111b' } },
      { Text = lead .. ' ' .. idx .. ': ' .. title .. ' ' },
      { Foreground = { Color = '#45475a' } }, { Background = { Color = '#11111b' } },
      { Text = '|' },
    }
  else
    return {
      { Foreground = { Color = '#6c7086' } }, { Background = { Color = '#11111b' } },
      { Text = lead .. ' ' .. idx .. ': ' .. title .. ' ' },
      { Foreground = { Color = '#45475a' } }, { Background = { Color = '#11111b' } },
      { Text = '|' },
    }
  end
end)

-- ---------------------------------------------------------------------------
-- Config
-- ---------------------------------------------------------------------------
local config = {
  -- ── Color scheme ──────────────────────────────────────────────────────
  color_schemes = {
    ['Catppuccin Mocha Pitch Black'] = custom,
  },
  color_scheme = 'Catppuccin Mocha Pitch Black',
  -- ── Font ──────────────────────────────────────────────────────────────
  font = wezterm.font('JetBrainsMono Nerd Font Mono'),
  font_size = 14.0,
  max_fps = 60,
  default_cursor_style = 'SteadyBlock',
  cursor_blink_ease_in = 'Constant',
  cursor_blink_ease_out = 'Constant',
  -- ── Window decorations – no OS title bar ──────────────────────────────
  window_decorations = 'RESIZE',
  -- ── Window padding ─────────────────────────────────────────────────────
  window_padding = {
    left = 12,
    right = 12,
    top = 12,
    bottom = 12,
  },
  -- ── Initial window size ────────────────────────────────────────────────
  initial_cols = 120,
  initial_rows = 36,
  scrollback_lines = 5000,
  audible_bell = 'Disabled',
  -- ── Leader key (Alt+b) ────────────────────────────────────────────────
  leader = { key = 'b', mods = 'ALT', timeout_milliseconds = 1000 },
  keys = keys,
  key_tables = {
    copy_mode = copy_mode_keys,
  },
  -- ── Mouse ─────────────────────────────────────────────────────────────
  mouse_bindings = {
    {
      event = { Down = { streak = 1, button = 'Right' } },
      mods = 'NONE',
      action = act.PasteFrom('Clipboard'),
    },
  },
  -- ── Tab bar ───────────────────────────────────────────────────────────
  use_fancy_tab_bar = false,
  show_new_tab_button_in_tab_bar = false,
  tab_max_width = 32,
  colors = {
    tab_bar = {
      background = '#11111b',
    },
  },
  -- ── Status bar update interval ────────────────────────────────────────
  status_update_interval = 1000,
}

return config
