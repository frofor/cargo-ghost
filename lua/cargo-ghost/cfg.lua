---@class VirtualTextConfig
---@field prefix string

---@class HighlightConfig
---@field latest string
---@field outdated string
---@field error string

---@class CacheConfig
---@field timeout integer

---@class Config
---@field enabled boolean
---@field virtual_text VirtualTextConfig
---@field highlight HighlightConfig
---@field cache CacheConfig
local cfg = {
	enabled = true,
	virtual_text = {
		prefix = ' # ',
	},
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
