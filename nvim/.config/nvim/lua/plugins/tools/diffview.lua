return {
	"sindrets/diffview.nvim",
	dependencies = "nvim-lua/plenary.nvim",
	config = function()
		require("diffview").setup({
			enhanced_diff_hl = true, -- nicer highlighting
			view = {
				merge_tool = {
					layout = "diff3_mixed", -- the 3-way layout
					disable_diagnostics = true,
				},
			},
			keymaps = {
				view = {
					{ "n", "<leader>co", "<cmd>diffget LOCAL<cr>", { desc = "Take LOCAL" } },
					{ "n", "<leader>ct", "<cmd>diffget REMOTE<cr>", { desc = "Take REMOTE" } },
				},
			},
		})
	end,
}
