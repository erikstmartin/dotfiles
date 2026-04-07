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

local function run_markdown(job, fmt, mlr, glow_pty, glow, theme)
	local md = Command(mlr):arg({ fmt, "--omd", "cat", tostring(job.file.path) }):output()
	if not md then
		return require("code"):peek(job)
	end
	local tmp = os.tmpname()
	local f = io.open(tmp, "w")
	if not f then
		render_text(job, md.stdout or "")
		return
	end
	f:write(md.stdout or "")
	f:close()
	local rendered = run_glow(glow_pty, glow, theme, math.max(20, job.area.w), tmp)
	os.remove(tmp)
	if rendered and rendered ~= "" then
		render_text(job, rendered)
	else
		render_text(job, md.stdout or "")
	end
end

function M:peek(job)
	local is_tsv = (job.file.mime or ""):find("tab%-separated") or job.file.mime == "text/tsv"
	local fmt = is_tsv and "--itsv" or "--icsv"
	local home = os.getenv("HOME")
	local mlr = find_cmd({
		home .. "/.local/share/mise/shims/mlr",
		"/usr/local/bin/mlr",
		"/usr/bin/mlr",
		"/opt/homebrew/bin/mlr",
	}, "mlr")
	local glow = find_cmd({
		home .. "/.local/share/mise/shims/glow",
		"/usr/local/bin/glow",
		"/usr/bin/glow",
		"/opt/homebrew/bin/glow",
	}, "glow")
	local theme = find_cmd({
		home .. "/.config/glow/themes/catppuccin-mocha.json",
	}, os.getenv("YAZI_GLOW_STYLE") or "dark")
	local glow_pty = find_cmd({
		home .. "/.config/yazi/glow-pty.py",
	}, nil)

	local mode = "table"
	if os.getenv("YAZI_CSV_MODE") == "markdown" then
		mode = "markdown"
	end

	if mode == "markdown" then
		return run_markdown(job, fmt, mlr, glow_pty, glow, theme)
	end

	local child = Command(mlr)
		:arg({ fmt, "--opprint", "--barred", "cat", tostring(job.file.path) })
		:stdout(Command.PIPED)
		:stderr(Command.PIPED)
		:spawn()

	if not child then
		return require("code"):peek(job)
	end

	local limit = job.area.h
	local i, lines = 0, ""
	repeat
		local next, event = child:read_line()
		if event == 1 then
			return require("code"):peek(job)
		elseif event ~= 0 then
			break
		end

		i = i + 1
		if i > job.skip then
			lines = lines .. next
		end
	until i >= job.skip + limit

	child:start_kill()
	if job.skip > 0 and i < job.skip + limit then
		ya.emit("peek", { math.max(0, i - limit), only_if = job.file.url, upper_bound = true })
	else
		lines = lines:gsub("\t", string.rep(" ", rt.preview.tab_size))
		ya.preview_widget(
			job,
			ui.Text.parse(lines):area(job.area):wrap(rt.preview.wrap == "yes" and ui.Wrap.YES or ui.Wrap.NO)
		)
	end
end

function M:seek(job) require("code"):seek(job) end

return M
