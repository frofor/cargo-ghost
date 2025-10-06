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
local function show_dep(dep, crate, buf, ns)
	if not cfg.get().format.dependency.enabled then return end

	local stable = crate.stable_version
	local newest = crate.newest_version
	local wanted
	if cfg.get().wanted_version == 'stable' then wanted = stable else wanted = newest end

	local text, highlight
	if not wanted then
		text, highlight = cfg.get().format.dependency.nonexistent_stable, 'ErrorMsg'
	elseif is_outdated(wanted, dep.version) then
		text, highlight = cfg.get().format.dependency.nonexistent, 'ErrorMsg'
	elseif is_outdated(dep.version, wanted) then
		text, highlight = cfg.get().format.dependency.outdated, 'WarningMsg'
	else
		text, highlight = cfg.get().format.dependency.updated, 'Comment'
	end

	if not text then return end
	text = text:gsub('{actual}', dep.version):gsub('{wanted}', wanted or '?.?.?')

	vim.api.nvim_buf_set_extmark(buf, ns, dep.line, 0, {
		virt_text = { { text, highlight } },
		priority = cfg.get().priority,
	})
end

---@param dep Dependency
---@param err string
---@param buf integer
---@param ns integer
local function show_dep_err(dep, err, buf, ns)
	local text = cfg.get().format.error
		:gsub('{version}', dep.version)
		:gsub('{error}', err)

	vim.api.nvim_buf_set_extmark(buf, ns, dep.line, 0, {
		virt_text = { { text, 'ErrorMsg' } },
		priority = cfg.get().priority,
	})
end

---@param n integer
---@return string
local function fmt_downloads(n)
	local abs = math.abs(n)
	if abs < 1e3 then return tostring(abs) end
	if abs < 1e6 then return string.format('%.1fK', abs / 1e3) end
	if abs < 1e9 then return string.format('%.1fM', abs / 1e6) end
	return string.format('%.1fB', abs / 1e9)
end

---@param crate Crate
local function open_dep_win(crate)
	local lines = {}
	table.insert(lines, string.format(' %s v%s', crate.name, crate.stable_version or '?.?.?'))
	table.insert(lines, string.rep('-', #crate.name + 2))
	for l in crate.desc:gmatch('[^\r\n]+') do table.insert(lines, l) end
	table.insert(lines, '')
	table.insert(lines, '󰇚 Total:  ' .. fmt_downloads(crate.downloads))
	table.insert(lines, '󰇚 Recent: ' .. fmt_downloads(crate.recent_downloads))
	table.insert(lines, '')
	table.insert(lines, '󰋜 Home: ' .. (crate.home or '--'))
	table.insert(lines, '󰏗 Docs: ' .. (crate.docs or '--'))
	table.insert(lines, '󰊤 Repo: ' .. (crate.repo or '--'))

	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
	vim.api.nvim_open_win(buf, true, {
		relative = 'cursor',
		width = 60,
		height = math.min(#lines, 20),
		row = 1,
		col = 0,
		style = 'minimal',
		border = 'single',
	})

	vim.cmd('highlight default CargoGhostPrimary guifg=#e5c07b gui=bold')
	vim.cmd('highlight default CargoGhostSecondary guifg=#61afef')
	vim.cmd('highlight default CargoGhostTertiary guifg=#7c7c7c')

	local ns = vim.api.nvim_create_namespace('cargo-ghost-float')
	vim.hl.range(buf, ns, 'CargoGhostPrimary', { 0, 2 }, { 0, #crate.name + 4 })

	for i, line in ipairs(lines) do
		local row = i - 1
		if line:match("^󰇚 Total:")
			or line:match("󰇚 Recent:")
			or line:match("^󰋜 Home:")
			or line:match("^󰏗 Docs:")
			or line:match("^󰊤 Repo:")
		then
			local colon = line:find(':')
			vim.hl.range(buf, ns, 'CargoGhostTertiary', { row, 0 }, { row, colon })
			vim.hl.range(buf, ns, 'CargoGhostSecondary', { row, colon }, { row, -1 })
		end
	end
end

local M = {}
M.show_dep = show_dep
M.show_dep_err = show_dep_err
M.open_dep_win = open_dep_win
return M
