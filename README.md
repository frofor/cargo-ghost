# cargo-ghost

A plugin that analyzes Cargo.toml to provide helpful insights in Neovim.

## Features

- Shows dependency version information in virtual text
- Shows dependency documentation window on hover

## Installation

To install the latest version of the plugin with [lazy.nvim](https://github.com/folke/lazy.nvim), add the following to your configuration:

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

The plugin can be configured with the following options in the `setup` function:

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
    - Possible placeholders:
      - `{actual}`: Actual version of the dependency.
      - `{wanted}`: Wanted version of the dependency, falls back to `'?.?.?'`.
  - `error` (string): Format of the error (default: `'  {error}'`).
    - Possible placeholders:
      - `{error}`: Error message.
- `cache`:
  - `timeout` (integer): Timeout of the crates cache invalidation in milliseconds (default: `300000`).

## License

This crate is distributed under the terms of MIT License.

See [LICENSE](https://codeberg.org/frofor/cargo-ghost/src/branch/main/LICENSE) for details.
