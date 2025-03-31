--- after/plugin/sync.lua
--- sync custom changes in and out of kickstart
--- cfg "config from git", ctg "config to git"
local nvrc = vim.fn.stdpath("config")
local git = "~/dev/neovimrc"

function Sync(paths)
	setmetatable(paths, { __index = { source = vim.fn.getcwd(), destination = nvrc } })
	local source, destination = paths[1] or paths.source, paths[2] or paths.destination
	local after = "/after/plugin"
	local lua = "/lua/custom/plugins"
	print("cp -R " .. source .. lua .. "/* " .. destination .. lua)
	print("cp -R " .. source .. after .. "/* " .. destination .. after)
	---os.execute("cp -R " .. home .. lua .. eomh .. lua)
end

vim.keymap.set("n", "<leader>cfg", function()
	Sync({ git, nvrc })
end)

vim.keymap.set("n", "<leader>ctg", function()
	Sync({ nvrc, git })
end)
