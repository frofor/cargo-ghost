---@class Dependency
---@field name string
---@field version string
---@field line integer

---@param lines string[]
---@param linenr integer
---@return Dependency|nil, integer
local function parse_dep(lines, linenr)
	local line = lines[linenr]
	local crate, version = line:match('^%s*([%w_%-]+)%s*=%s*"([^"]+)"')
	if crate and version then
		local dep = { name = crate, version = version, line = linenr - 1 }
		return dep, linenr + 1
	end

	crate = line:match('^%s*([%w_%-]+)%s*=%s*{')
	if not crate then
		return nil, linenr + 1
	end

	if not line:match('version%s*=') then
		while true do
			linenr = linenr + 1
			if linenr == #lines then
				return nil, linenr
			end

			line = lines[linenr]
			if line:match('version%s*=') then
				break
			elseif line:match('}') then
				return nil, linenr + 1
			end
		end
	end

	version = line:match('version%s*=%s*"([^"]+)"')
	if not version then
		return nil, linenr + 1
	end

	local dep = { name = crate, version = version, line = linenr - 1 }
	return dep, linenr + 1
end

---@param buf integer
---@return Dependency[]
local function parse_cargo_toml(buf)
	local deps = {}
	local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, true)
	local in_deps = false

	local linenr = 1
	while linenr <= #lines do
		local line = lines[linenr]
		if line:match('^%s*%[dependencies')
			or line:match('^%s*%[dev-dependencies')
			or line:match('^%s*%[build-dependencies')
		then
			in_deps = true
		elseif line:match('^%s*%[') then
			in_deps = false
		end

		if not in_deps then
			linenr = linenr + 1
			goto continue
		end

		local dep, new_linenr = parse_dep(lines, linenr)
		if dep then
			table.insert(deps, dep)
		end
		linenr = new_linenr

		::continue::
	end

	return deps
end

local M = {}
M.parse_cargo_toml = parse_cargo_toml
return M
