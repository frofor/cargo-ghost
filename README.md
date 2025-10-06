# cargo-ghost

👻 Cargo Ghost — a little companion that haunts Cargo.toml with subtle, helpful virtual text.

## Features

- Shows dependency version information in virtual text
- Shows dependency documentation window on hover

## Installation

```lua
{
	'frofor/cargo-ghost',
	config = function()
		local cargo_ghost = require('cargo-ghost')
		cargo_ghost.setup()
	end,
}
```

## Configuration

```lua
---@class FormatVersionConfig
---@field enabled boolean
---@field updated string?
---@field outdated string?
---@field nonexistent string?

---@class FormatConfig
---@field version FormatVersionConfig
---@field error string

---@class CacheConfig
---@field timeout integer

---@class Config
---@field enabled boolean
---@field priority integer
---@field wanted_version 'stable'|'newest'
---@field format FormatConfig
---@field cache CacheConfig
{
	enabled = true,
	priority = 90,
	wanted_version = 'stable',
	format = {
		version = {
			enabled = true,
			updated = nil,
			outdated = ' # {wanted}',
			nonexistent = ' # version does not exist',
		},
		error = ' # {error}',
	},
	cache = {
		timeout = 300000,
	},
}
```
