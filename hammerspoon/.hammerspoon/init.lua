require("hs.ipc") -- enables the `hs` command line tool

-- App launcher hotkeys: Cmd+Opt+<key> launches or focuses the app
-- (Cmd+Ctrl deliberately avoided: Godot uses it heavily)
local apps = {
	{ key = "1", bundleID = "md.obsidian" }, -- Obsidian
	{ key = "2", bundleID = "com.github.wez.wezterm" }, -- WezTerm
	{ key = "3", bundleID = "com.microsoft.edgemac" }, -- Microsoft Edge
	{ key = "4", bundleID = "com.tinyspeck.slackmacgap" }, -- Slack
	{ key = "5", name = "Godot" }, -- Godot (shares its bundle ID with Godot_mono, so match by name)
}

for _, app in ipairs(apps) do
	hs.hotkey.bind({ "cmd", "alt" }, app.key, function()
		local ok
		if app.bundleID then
			ok = hs.application.launchOrFocusByBundleID(app.bundleID)
		else
			ok = hs.application.launchOrFocus(app.name)
		end
		if not ok then
			hs.alert.show("Could not launch " .. (app.bundleID or app.name))
		end
	end)
end

-- Reload config: Cmd+Opt+R, or automatically when any .lua file changes
hs.hotkey.bind({ "cmd", "alt" }, "r", hs.reload)

-- Global so the watcher isn't garbage collected after init.lua finishes
ConfigWatcher = hs.pathwatcher.new(hs.configdir, function(files)
	for _, file in ipairs(files) do
		if file:sub(-4) == ".lua" then
			hs.reload()
			return
		end
	end
end)
ConfigWatcher:start()

hs.autoLaunch(true)
hs.alert.show("Hammerspoon config loaded")
