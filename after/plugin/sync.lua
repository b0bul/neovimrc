local SyncCustomChanges = function(path)
	local after = "after/plugin/"
	local lua = "lua/custom/plugin/"
	os.execute("cp -R " .. vim.fn.stdpath("config") .. after .. path .. after)
	os.execute("cp -R " .. vim.fn.stdpath("config") .. lua .. path .. lua)
end

vim.keymap.set("n", "<leader>co", function()
	SyncCustomChanges("~/dev/neovimrc")
end)
