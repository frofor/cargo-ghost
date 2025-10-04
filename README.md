# cargo-ghost

👻 Cargo Ghost — a little companion that haunts Cargo.toml with subtle, helpful virtual text.

## Features

- Shows dependency version information

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
{
	enabled = true,
	priority = 90,
	wanted_version = 'stable',
	format = {
		updated = ' # updated',
		outdated = ' # {wanted}',
		error = ' # {error}',
	},
	highlight = {
		updated = 'Comment',
		outdated = 'WarningMsg',
		error = 'ErrorMsg',
	},
	cache = {
		timeout = 300000,
	},
}
```
