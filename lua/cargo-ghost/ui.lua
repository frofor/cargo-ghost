local cfg = require('cargo-ghost.cfg')

---@param actual string
---@param wanted string
local function is_outdated(actual, wanted)
	local actual_clean = actual:gsub('^[^%d]*', '')
	local wanted_clean = wanted:gsub('^[^%d]*', '')
	if actual_clean == wanted_clean then return false end

	local actual_parts = vim.split(actual_clean, '%.')
	local wanted_parts = vim.split(wanted_clean, '%.')
	while #actual_parts < 3 do table.insert(actual_parts, '0') end
	while #wanted_parts < 3 do table.insert(wanted_parts, '0') end

	for i = 1, 3 do
		local actual_num = tonumber(actual_parts[i]) or 0
		local wanted_num = tonumber(wanted_parts[i]) or 0
		if actual_num < wanted_num then return true end
		if actual_num > wanted_num then return false end
	end

	return false
end

---@param dep Dependency
---@param crate Crate
---@param buf integer
---@param ns integer
local function show_dep_version(dep, crate, buf, ns)
	local stable = crate.stable_version
	local newest = crate.newest_version
	local wanted = cfg.get().wanted_version == 'stable' and stable or newest

	local text, highlight
	if is_outdated(wanted, dep.version) then
		text, highlight = cfg.get().format.version.nonexistent, 'ErrorMsg'
	elseif is_outdated(dep.version, wanted) then
		text, highlight = cfg.get().format.version.outdated, 'WarningMsg'
	else
		text, highlight = cfg.get().format.version.updated, 'Comment'
	end

	if not text then return end
	text = text:gsub('{actual}', dep.version):gsub('{wanted}', wanted)

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
