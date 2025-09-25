return {
	"nvim-telescope/telescope.nvim",
	-- …other telescope settings
	dependencies = {
		-- …other dependencies
		"jsongerber/telescope-ssh-config",
	},
	config = function()
		local telescope = require("telescope")

		telescope.setup({
			-- …other settings
			extensions = {
				-- This is default and can be ommited
				["ssh-config"] = {
					client = "oil", -- or 'netrw'
					ssh_config_path = "~/.ssh/config",
				},
			},
		})

		-- …other Telescope extensions
		telescope.load_extension("ssh-config")

		-- Optional: map :Telescope ssh-config to a keymap
		vim.keymap.set({ "n", "v" }, "<leader>fc", "<cmd>Telescope ssh-config<CR>", { desc = "Open an ssh connexion" })
	end,
}
