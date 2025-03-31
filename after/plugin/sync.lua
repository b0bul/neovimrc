--- after/plugin/sync.lua
--- sync custom changes in and out of kickstart
local nvrc = vim.fn.stdpath("config")
local git = "~/dev/neovimrc"

function Copy(s, d)
	--- path join
	local cmd = s .. "/* " .. d
	os.execute("cp -R " .. cmd)
end

function Sync(paths)
	--- default params if none
	setmetatable(paths, { __index = { source = vim.fn.getcwd(), destination = nvrc } })
	local source, destination = paths[1] or paths.source, paths[2] or paths.destination
	local config = "/after/plugin"
	local plugins = "/lua/custom/plugins"

	Copy(source .. plugins, destination .. plugins)
	Copy(source .. config, destination .. config)
end

--- "config from git"
vim.keymap.set("n", "<leader>cfg", function()
	Sync({ git, nvrc })
end)

--- "config to git"
vim.keymap.set("n", "<leader>ctg", function()
	Sync({ nvrc, git })
end)
