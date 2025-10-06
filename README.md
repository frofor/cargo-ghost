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

- `enabled` (boolean): Whether plugin should be enabled (default: `true`).
- `priority` (integer): Priority of the virtual text. Highest priority is last (default: `90`).
- `wanted_version`: Wanted version of dependencies. Possible values:
  - `'stable'`: Stable version (default).
  - `'newest'`: Newest version, such as RC.
- `format`: Format of the virtual text.
  - `dependency`: Format of the dependency virtual text.
    - `enabled` (boolean): Whether virtual text should be shown (default: `true`).
    - `updated` (string?): Format if the dependency is updated (default: `'  latest'`).
    - `outdated` (string?): Format if the dependency is outdated (default: `' 󰇚 {wanted}'`).
    - `nonexistent` (string?): Format if the version does not exist (default: `'  {wanted}'`).
    - `nonexistent_stable` (string?): Format if the stable version does not exist (default: `'  unstable'`).
  - `error` (string): Format of the error (default: `'  {error}'`).
- `cache`:
  - `timeout` (integer): Timeout of the crates cache invalidation in milliseconds (default: `300000`).
