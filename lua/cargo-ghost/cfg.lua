---@class HighlightConfig
---@field latest string
---@field outdated string
---@field error string

---@class CacheConfig
---@field timeout integer

---@class Config
---@field enabled boolean
---@field priority integer
---@field prefix string
---@field required_version 'stable'|'newest'
---@field highlight HighlightConfig
---@field cache CacheConfig
local cfg = {
	enabled = true,
	priority = 90,
	prefix = ' # ',
	required_version = 'stable',
	highlight = {
		latest = 'Comment',
		outdated = 'WarningMsg',
		error = 'ErrorMsg',
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

local M = {}
M.setup = setup
M.get = get
return M
