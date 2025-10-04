local cfg = require('cargo-ghost.cfg')

---@param given string
---@param wanted string
local function is_updated(given, wanted)
	if given == wanted then
		return true
	end

	local given_clean = given:gsub('^[^%d]*', '')
	local wanted_clean = wanted:gsub('^[^%d]*', '')

	local given_parts = vim.split(given_clean, '%.')
	local wanted_parts = vim.split(wanted_clean, '%.')

	while #given_parts < 3 do
		table.insert(given_parts, '0')
	end
	while #wanted_parts < 3 do
		table.insert(wanted_parts, '0')
	end

	for i = 1, 3 do
		local given_num = tonumber(given_parts[i]) or 0
		local wanted_num = tonumber(wanted_parts[i]) or 0

		if given_num < wanted_num then
			return false
		elseif given_num > wanted_num then
			return true
		end
	end

	return true
end

---@param dep Dependency
---@param crate Crate
---@param buf integer
---@param ns integer
local function show_dep_version(dep, crate, buf, ns)
	local stable_version = crate.stable_version
	local newest_version = crate.newest_version
	local wanted = cfg.get().wanted_version == 'stable' and stable_version or newest_version
	local updated = is_updated(dep.version, wanted)
	local highlight = updated and 'Comment' or 'WarningMsg'

	local fmt
	if updated then
		fmt = cfg.get().format.version.updated
	else
		fmt = cfg.get().format.version.outdated
	end
	if not fmt then
		return
	end

	local text = fmt:gsub('{wanted}', wanted)
	vim.api.nvim_buf_set_extmark(buf, ns, dep.line, 0, {
		virt_text = { { text, highlight } },
		priority = cfg.get().priority,
	})
end

---@param dep Dependency
---@param crate Crate
---@param buf integer
---@param ns integer
local function show_dep_summary(dep, crate, buf, ns)
	local text = cfg.get().format.summary.format:gsub('{summary}', crate.summary)
	vim.api.nvim_buf_set_extmark(buf, ns, dep.line, 0, {
		virt_text = { { text, 'Comment' } },
		priority = cfg.get().priority + 10,
	})
end

---@param dep Dependency
---@param crate Crate
---@param buf integer
---@param ns integer
local function show_dep(dep, crate, buf, ns)
	if cfg.get().format.version.enabled then
		show_dep_version(dep, crate, buf, ns)
	end

	if cfg.get().format.summary.enabled then
		show_dep_summary(dep, crate, buf, ns)
	end
end

---@param dep Dependency
---@param err string
---@param buf integer
---@param ns integer
local function show_err(dep, err, buf, ns)
	local text = cfg.get().format.error
		:gsub('{version}', dep.version)
		:gsub('{error}', err)

	vim.api.nvim_buf_set_extmark(buf, ns, dep.line, 0, {
		virt_text = { { text, 'ErrorMsg' } },
		priority = cfg.get().priority,
	})
end

local M = {}
M.show_dep = show_dep
M.show_err = show_err
return M
