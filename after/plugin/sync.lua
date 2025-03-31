--- after/plugin/sync.lua
--- sync custom changes in and out of kickstart
--- cfg "config from git", ctg "config to git"
local nvrc = vim.fn.stdpath("config")
local git = "~/dev/neovimrc"

function Copy(s, d)
	--- path join
	local cmd = s .. "/* " .. d
	print("cp -R " .. cmd)
end

function Sync(paths)
	setmetatable(paths, { __index = { source = vim.fn.getcwd(), destination = nvrc } })
	local source, destination = paths[1] or paths.source, paths[2] or paths.destination
	local after = "/after/plugin"
	local lua = "/lua/custom/plugins"

	Copy(source .. lua, destination .. lua)
	Copy(source .. after, destination .. after)
	---os.execute("cp -R " .. home .. lua .. eomh .. lua)
end

vim.keymap.set("n", "<leader>cfg", function()
	Sync({ git, nvrc })
end)

vim.keymap.set("n", "<leader>ctg", function()
	Sync({ nvrc, git })
end)
