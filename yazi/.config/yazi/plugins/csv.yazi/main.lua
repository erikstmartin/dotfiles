local M = {}

function M:peek(job)
	-- job.file.mime is nil in yazi 26; the mime is on the job itself. Fall back
	-- to the extension when the mime is missing or generic (e.g. text/plain)
	local mime = job.mime or ""
	local is_tsv = mime:find("tab%-separated") or mime == "text/tsv"
		or tostring(job.file.url):lower():find("%.tsv$")
	local fmt = is_tsv and "--itsv" or "--icsv"
	local child = Command("mlr")
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

function M:spot(job) require("code"):spot(job) end

return M
