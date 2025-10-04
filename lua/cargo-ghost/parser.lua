---@class Dependency
---@field name string
---@field version string
---@field line integer

---@param line string
---@param linenr integer
---@return Dependency|nil
local function parse_dep(line, linenr)
	local crate, version = line:match('^%s*([%w_%-]+)%s*=%s*["\']([^"\']+)["\']')
	if crate and version then
		return { name = crate, version = version, line = linenr - 1 }
	end

	crate = line:match('^%s*([%w_%-]+)%s*=%s*{')
	if not crate then
		return nil
	end

	version = line:match('version%s*=%s*["\']([^"\']+)["\']')
	if not version then
		return nil
	end

	return { name = crate, version = version, line = linenr - 1 }
end

---@param buf integer
---@return Dependency[]
local function parse_cargo_toml(buf)
	local deps = {}
	local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, true)
	local in_deps = false

	for linenr, line in ipairs(lines) do
		if line:match('^%s*%[dependencies')
			or line:match('^%s*%[dev-dependencies')
			or line:match('^%s*%[build-dependencies')
		then
			in_deps = true
		elseif line:match('^%s*%[') then
			in_deps = false
		end

		if not in_deps then
			goto continue
		end

		local dep = parse_dep(line, linenr)
		if dep then
			table.insert(deps, dep)
		end

		::continue::
	end

	return deps
end

local M = {}
M.parse_cargo_toml = parse_cargo_toml
return M
