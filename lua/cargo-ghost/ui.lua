local cfg = require('cargo-ghost.cfg')

---@param given string
---@param wanted string
---@return boolean
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
---@param info CrateInfo
---@param buf integer
---@param ns integer
local function show_dep_info(dep, info, buf, ns)
	local given = dep.version
	local wanted = cfg.get().wanted_version == 'stable'
		and info.stable_version
		or info.newest_version
	local updated = is_updated(given, wanted)

	local format = updated and cfg.get().format.updated or cfg.get().format.outdated
	local text = format:gsub('{wanted}', wanted)
	local highlight = updated and cfg.get().highlight.updated or cfg.get().highlight.outdated

	vim.api.nvim_buf_set_extmark(buf, ns, dep.line, 0, {
		virt_text = { { text, highlight } },
		priority = cfg.get().priority,
	})
end

---@param dep Dependency
---@param err string
---@param buf integer
---@param ns integer
local function show_error(dep, err, buf, ns)
	local text = cfg.get().format.error
		:gsub('{version}', dep.version)
		:gsub('{error}', err)

	vim.api.nvim_buf_set_extmark(buf, ns, dep.line, 0, {
		virt_text = { { text, cfg.get().highlight.error } },
		priority = cfg.get().priority,
	})
end

local M = {}
M.show_dep_info = show_dep_info
M.show_error = show_error
return M
