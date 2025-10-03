local cfg = require('cargo-ghost.cfg')

---@param version string
---@param latest string
---@return boolean
local function is_outdated(version, latest)
	if version == latest then
		return false
	end

	local version_clean = version:gsub('^[^%d]*', '')
	local latest_clean = latest:gsub('^[^%d]*', '')

	local version_parts = vim.split(version_clean, '%.')
	local latest_parts = vim.split(latest_clean, '%.')

	while #version_parts < 3 do
		table.insert(version_parts, '0')
	end
	while #latest_parts < 3 do
		table.insert(latest_parts, '0')
	end

	for i = 1, 3 do
		local version_num = tonumber(version_parts[i]) or 0
		local latest_num = tonumber(latest_parts[i]) or 0

		if version_num < latest_num then
			return true
		elseif version_num > latest_num then
			return false
		end
	end

	return false
end

---@param version string
---@param latest string
---@param line integer
---@param buf integer
---@param ns integer
local function show_version(version, latest, line, buf, ns)
	local outdated = is_outdated(version, latest)
	local highlight = outdated and cfg.get().highlight.outdated or cfg.get().highlight.latest
	local suffix = outdated and latest or 'latest'
	local text = string.format('%s%s', cfg.get().prefix, suffix)

	vim.api.nvim_buf_set_extmark(buf, ns, line, 0, {
		virt_text = { { text, highlight } },
		priority = cfg.get().priority,
	})
end

---@param text string
---@param line integer
---@param buf integer
---@param ns integer
local function show_error(text, line, buf, ns)
	local formatted = string.format('%s%s', cfg.get().prefix, text)

	vim.api.nvim_buf_set_extmark(buf, ns, line, 0, {
		virt_text = { { formatted, cfg.get().highlight.error } },
		priority = cfg.get().priority,
	})
end

local M = {}
M.show_version = show_version
M.show_error = show_error
return M
