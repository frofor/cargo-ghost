---@class Dependency
---@field name string
---@field version string
---@field line integer

---@param buf integer
---@return Dependency[]
local function parse_cargo_toml(buf)
	local deps = {}
	local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, true)
	local in_deps = false

	for linenr, line in ipairs(lines) do
		in_deps = line:match('^%s*%[dependencies')
			or line:match('^%s*%[dev%-dependencies')
			or line:match('^%s*%[build%-dependencies')
			or (in_deps and not line:match('^%s*%['))

		if not in_deps then
			goto continue
		end

		local name, version = line:match('^%s*([%w_%-]+)%s*=%s*["\']([^"\']+)["\']')
		if name then
			table.insert(deps, { name = name, version = version, line = linenr - 1 })
			goto continue
		end

		name, version = line:match('^%s*([%w_%-]+)%s*=%s*{.*version%s*=%s*["\']([^"\']+)["\']')
		if name then
			table.insert(deps, { name = name, version = version, line = linenr - 1 })
		end

		::continue::
	end

	return deps
end

local M = {}
M.parse_cargo_toml = parse_cargo_toml
return M
