return {
	"tpope/vim-fugitive",
	lazy = false,
	keys = {
		{ "<leader>gh", "<cmd>diffget //2<cr>", desc = "Take left (ours)" },
		{ "<leader>gl", "<cmd>diffget //3<cr>", desc = "Take right (theirs)" },
	},
}
