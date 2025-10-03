local cfg = require('cargo-ghost.cfg')

---@class CrateCache
---@field version string
---@field time number

---@type table<string, CrateCache>
local cache = {}

---@param crate string
---@param fn fun(version: string?, err: string?)
local function get_latest_version(crate, fn)
	local now = vim.loop.now()

	if cache[crate] and now - cache[crate].time < cfg.get().cache.timeout then
		fn(cache[crate].version, nil)
		return
	end

	local cmd = {
		'curl',
		'-s',
		'--max-time', '10',
		'--user-agent', 'cargo-ghost',
		string.format('https://crates.io/api/v1/crates/%s', crate),
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

			local version = data.crate.newest_version
			cache[crate] = { version = version, time = now }
			fn(version, nil)
		end)
	end)
end

local M = {}
M.get_latest_version = get_latest_version
return M
