--- after/plugin/sync.lua
--- sync custom changes in and out of kickstart
--- cfg "config from git", ctg "config to git"
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

vim.keymap.set("n", "<leader>cfg", function()
	Sync({ git, nvrc })
end)

vim.keymap.set("n", "<leader>ctg", function()
	Sync({ nvrc, git })
end)
