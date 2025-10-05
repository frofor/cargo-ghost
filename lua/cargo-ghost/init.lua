local cfg = require('cargo-ghost.cfg')
local api = require('cargo-ghost.api')
local parser = require('cargo-ghost.parser')
local ui = require('cargo-ghost.ui')
local ns = vim.api.nvim_create_namespace('cargo-ghost')
local queue = 0

---@param buf integer
local function update(buf)
	if not cfg.get().enabled then
		return
	end

	if queue ~= 0 then
		return
	end

	vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)

	local deps = parser.parse_cargo_toml(buf)
	for _, dep in ipairs(deps) do
		queue = queue + 1
		api.get_crate(dep.name, function(crate, err)
			if err then
				ui.show_err(dep, err, buf, ns)
			else
				ui.show_dep(dep, crate, buf, ns)
			end
			queue = queue - 1
		end)
	end
end

---@param opts table
local function setup(opts)
	cfg.setup(opts)

	local group = vim.api.nvim_create_augroup('CargoGhost', { clear = true })
	vim.api.nvim_create_autocmd({ 'BufRead', 'BufNewFile', 'BufWritePost' }, {
		group = group,
		pattern = 'Cargo.toml',
		callback = function(args) update(args.buf) end,
	})
end

local function reattach()
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if not vim.api.nvim_buf_is_loaded(buf) then
			goto continue
		end

		local name = vim.api.nvim_buf_get_name(buf)
		if not name:match('Cargo%.toml$') then
			goto continue
		end

		vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
		update(buf)
		::continue::
	end
end

local function toggle()
	cfg.toggle()
	reattach()
end

local function toggle_version()
	cfg.toggle_version()
	reattach()
end

local function toggle_summary()
	cfg.toggle_summary()
	reattach()
end

---@class CargoGhost
local M = {}
M.setup = setup
M.reattach = reattach
M.toggle = toggle
M.toggle_version = toggle_version
M.toggle_summary = toggle_summary
return M
