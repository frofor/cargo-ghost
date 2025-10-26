local cfg = require('cargo-ghost.cfg')

---@param v any
---@return string|number|boolean?
local function prim(v)
	local t = type(v)
	if t == 'string' or t == 'number' or t == 'boolean' then return v end
	return nil
end

---@class Crate
---@field name string
---@field desc string
---@field home string?
---@field docs string?
---@field repo string?
---@field stable_version string?
---@field latest_version string
---@field downloads integer
---@field recent_downloads integer

---@class CrateCache
---@field crate Crate
---@field time number

---@type table<string, CrateCache>
local cache = {}

---@param name string
---@param fn fun(crate: Crate?, err: string?)
local function get_crate(name, fn)
	local cache_timeout = cfg.get().cache.timeout
	local now = vim.loop.now()
	if cache[name] and now - cache[name].time < cache_timeout then
		fn(cache[name].crate, nil)
		return
	end

	local cmd = {
		'curl',
		'-s',
		'--max-time', '10',
		'--user-agent', 'cargo-ghost',
		string.format('https://crates.io/api/v1/crates/%s', name),
	}

	vim.system(cmd, {}, function(res)
		vim.schedule(function()
			if res.code ~= 0 then
				fn(nil, 'curl failed')
				return
			end

			local ok, data = pcall(vim.json.decode, res.stdout)
			if not ok then
				fn(nil, 'json failed')
				return
			end

			if data.errors then
				fn(nil, data.errors[1].detail)
				return
			end

			local crate = {
				name = data.crate.name,
				desc = data.crate.description:gsub('\n', ' '),
				home = prim(data.crate.homepage),
				docs = prim(data.crate.documentation),
				repo = prim(data.crate.repository),
				stable_version = prim(data.crate.max_stable_version),
				latest_version = data.crate.max_version,
				downloads = data.crate.downloads,
				recent_downloads = data.crate.recent_downloads,
			}
			cache[name] = { crate = crate, time = now }
			fn(crate, nil)
		end)
	end)
end

local M = {}
M.get_crate = get_crate
return M
