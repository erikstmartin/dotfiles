local M = {}

local function find_cmd(candidates, fallback)
	for _, p in ipairs(candidates) do
		local f = io.open(p, "r")
		if f then
			f:close()
			return p
		end
	end
	return fallback
end

local function run_glow(glow_pty, glow, style, width, path)
	local output = Command("/usr/bin/python3")
		:arg({ glow_pty, glow, style, tostring(width), path })
		:output()
	if not output then
		return nil
	end
	local s = output.stdout or ""
	s = s:gsub("\r\n", "\n"):gsub("\r", "")
	return s
end

local function render_text(job, text)
	local lines = {}
	for line in (text .. "\n"):gmatch("(.-)\n") do
		lines[#lines + 1] = line .. "\n"
	end

	local start = job.skip + 1
	local stop = math.min(#lines, start + job.area.h - 1)
	local out = ""
	for i = start, stop do
		out = out .. lines[i]
	end

	if job.skip > 0 and #lines < job.skip + job.area.h then
		ya.emit("peek", { math.max(0, #lines - job.area.h), only_if = job.file.url, upper_bound = true })
	else
		out = out:gsub("\t", string.rep(" ", rt.preview.tab_size))
		ya.preview_widget(
			job,
			ui.Text.parse(out):area(job.area):wrap(rt.preview.wrap == "yes" and ui.Wrap.YES or ui.Wrap.NO)
		)
	end
end

function M:peek(job)
	local home = os.getenv("HOME")
	local theme = find_cmd({
		home .. "/.config/glow/themes/catppuccin-mocha.json",
	}, os.getenv("YAZI_GLOW_STYLE") or "dark")
	local glow = find_cmd({
		home .. "/.local/share/mise/shims/glow",
		"/usr/local/bin/glow",
		"/usr/bin/glow",
		"/opt/homebrew/bin/glow",
	}, "glow")
	local glow_pty = find_cmd({
		home .. "/.config/yazi/glow-pty.py",
	}, nil)
	if not glow_pty then
		return require("code"):peek(job)
	end
	local out = run_glow(glow_pty, glow, theme, math.max(20, job.area.w), tostring(job.file.path))
	if not out or out == "" then
		return require("code"):peek(job)
	end
	render_text(job, out)
end

function M:seek(job) require("code"):seek(job) end

return M
