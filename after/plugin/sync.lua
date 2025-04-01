--- after/plugin/sync.lua
--- sync custom changes in and out of kickstart
local nvrc = vim.fn.stdpath("config")
local git = "~/dev/neovimrc"

function Split(d)
	local sep = "/"
	local t = {}
	for s in string.gmatch(d, "([^" .. sep .. "]+)") do
		table.insert(t, s)
	end
	return t
end

function IndexOf(t)
	local length = 0
	local root = 0
	for k, v in pairs(t) do
		length = length + 1
		if v == "nvim" then
			root = k
		end
	end
	return root, length
end

function Paths(directories, start, ending)
	local num_paths = ending - start
	local subpaths = {}
	local paths = {}
	local base = {}
	local complete_paths = {}

	--- get everything up to nvim
	for _, v in pairs(directories) do
		table.insert(base, v)
		if v == "nvim" then
			break
		end
	end

	--- get everything after nvim
	for subpath = start + 1, ending do
		table.insert(subpaths, directories[subpath])
	end

	--- create multiple nested path
	for complement = 1, num_paths do
		print(table.concat(base, ", "))
		base[start + complement] = subpaths[complement]
		table.insert(paths, { unpack(base) })
	end

	return paths
end

function Stat(d)
	local ok = vim.loop.fs_stat(d)
	if not ok then
		error("problem stating " .. d)
	end
	return ok
end

function Mkdir(d)
	local ok = vim.loop.fs_mkdir(d, 755)
	if not ok then
		error("problem creating " .. d)
	end
	return ok
end

function Copy(s, d)
	Check(d)
	--- path join
	local cmd = s .. "/* " .. d
	os.execute("cp -R " .. cmd)
end

function Check(d)
	local dirs = Split(d)
	local start, length = IndexOf(dirs)
	local p = Paths(dirs, start, length)
	print(table.concat(p[1], "/") .. "\n")
	print("and then\n")
	print(table.concat(p[2], "/") .. "\n")
	print("and then\n")
	print(table.concat(p[3], "/") .. "\n")
	--[[
	local exists, _ = Stat(d)
	if not exists then
		local ok, err = Mkdir(d)
		if not ok then
			error("error creating " .. d .. err)
		end
	end
	--]]
end

function Sync(paths)
	--- default params if none
	setmetatable(paths, { __index = { source = vim.fn.getcwd(), destination = nvrc } })
	local source, destination = paths[1] or paths.source, paths[2] or paths.destination
	-- local config = "/after/plugin"
	local config = "/after/plugin/somethingelse"
	local plugins = "/lua/custom/plugins"

	-- Copy(source .. plugins, destination .. plugins)
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
