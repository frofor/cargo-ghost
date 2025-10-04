local cfg = require('cargo-ghost.cfg')

---@class Crate
---@field summary string
---@field stable_version string
---@field newest_version string

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
				fn(nil, 'crates.io failed')
				return
			end

			local ok, data = pcall(vim.json.decode, res.stdout)
			if not ok then
				fn(nil, 'crates.io JSON failed')
				return
			end

			if data.errors then
				fn(nil, data.errors[1].detail)
				return
			end

			local summary = data.crate.description:gsub('\n', ' ')
			local stable = data.crate.max_stable_version
			local newest = data.crate.newest_version
			local crate = { summary = summary, stable_version = stable, newest_version = newest }
			cache[name] = { crate = crate, time = now }
			fn(crate, nil)
		end)
	end)
end

local M = {}
M.get_crate = get_crate
return M
