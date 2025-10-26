---@class DependencyFormatConfig
---@field enabled boolean
---@field updated string?
---@field outdated string?
---@field nonexistent string?
---@field nonexistent_stable string?

---@class FormatConfig
---@field dependency DependencyFormatConfig
---@field error string

---@class CacheConfig
---@field timeout integer

---@class Config
---@field enabled boolean
---@field priority integer
---@field wanted_version 'stable'|'latest'
---@field format FormatConfig
---@field cache CacheConfig
local cfg = {
	enabled = true,
	priority = 90,
	wanted_version = 'stable',
	format = {
		dependency = {
			enabled = true,
			updated = '  latest',
			outdated = ' 󰇚 {wanted}',
			nonexistent = '  {wanted}',
			nonexistent_stable = '  unstable',
		},
		error = '  {error}',
	},
	cache = {
		timeout = 300000,
	},
}

---@param opts table
local function setup(opts)
	cfg = vim.tbl_deep_extend('force', cfg, opts or {})
end

local function get()
	return cfg
end

local function toggle()
	cfg.enabled = not cfg.enabled
end

local function toggle_dep()
	cfg.format.dependency.enabled = not cfg.format.dependency.enabled
end

local M = {}
M.setup = setup
M.get = get
M.toggle = toggle
M.toggle_dep = toggle_dep
return M
