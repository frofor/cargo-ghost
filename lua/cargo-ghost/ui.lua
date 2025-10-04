local cfg = require('cargo-ghost.cfg')

---@param cur string
---@param exp string
---@return boolean
local function is_outdated(cur, exp)
	if cur == exp then
		return false
	end

	local cur_clean = cur:gsub('^[^%d]*', '')
	local exp_clean = exp:gsub('^[^%d]*', '')

	local cur_parts = vim.split(cur_clean, '%.')
	local exp_parts = vim.split(exp_clean, '%.')

	while #cur_parts < 3 do
		table.insert(cur_parts, '0')
	end
	while #exp_parts < 3 do
		table.insert(exp_parts, '0')
	end

	for i = 1, 3 do
		local cur_num = tonumber(cur_parts[i]) or 0
		local exp_num = tonumber(exp_parts[i]) or 0

		if cur_num < exp_num then
			return true
		elseif cur_num > exp_num then
			return false
		end
	end

	return false
end

---@param dep Dependency
---@param info CrateInfo
---@param buf integer
---@param ns integer
local function show_dep_info(dep, info, buf, ns)
	local cur = dep.version
	local exp = cfg.get().required_version == 'stable' and info.stable_version or info.newest_version
	local outdated = is_outdated(cur, exp)

	local highlight = outdated and cfg.get().highlight.outdated or cfg.get().highlight.latest
	local suffix = outdated and exp or 'latest'
	local text = string.format('%s%s', cfg.get().prefix, suffix)

	vim.api.nvim_buf_set_extmark(buf, ns, dep.line, 0, {
		virt_text = { { text, highlight } },
		priority = cfg.get().priority,
	})
end

---@param dep Dependency
---@param text string
---@param buf integer
---@param ns integer
local function show_error(dep, text, buf, ns)
	local formatted = string.format('%s%s', cfg.get().prefix, text)

	vim.api.nvim_buf_set_extmark(buf, ns, dep.line, 0, {
		virt_text = { { formatted, cfg.get().highlight.error } },
		priority = cfg.get().priority,
	})
end

local M = {}
M.show_dep_info = show_dep_info
M.show_error = show_error
return M
