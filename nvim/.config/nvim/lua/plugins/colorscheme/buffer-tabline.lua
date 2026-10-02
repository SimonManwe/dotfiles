return {
	"romgrk/barbar.nvim",
	dependencies = {
		"lewis6991/gitsigns.nvim", -- optional, git status
		"nvim-tree/nvim-web-devicons", -- optional, icons
	},
	init = function()
		vim.g.barbar_auto_setup = false
	end,
	config = function()
		require("barbar").setup({
			animation = false,
			tabpages = true,
			clickable = true,
			auto_hide = 1,
			exclude_ft = { "DiffviewFiles", "DiffviewFileHistory" },
		})

		vim.keymap.set("n", "<S-l>", "<Cmd>BufferNext<CR>")
		vim.keymap.set("n", "<S-h>", "<Cmd>BufferPrevious<CR>")
		vim.keymap.set("n", "<A-.>", "<Cmd>BufferMoveNext<CR>")
		vim.keymap.set("n", "<A-,>", "<Cmd>BufferMovePrevious<CR>")
		vim.keymap.set("n", "<leader>bl", "<Cmd>BufferCloseBuffersLeft<CR>", { desc = "Close buffers to the left" })
		vim.keymap.set("n", "<leader>br", "<Cmd>BufferCloseBuffersRight<CR>", { desc = "Close buffers to the right" })
		vim.keymap.set("n", "<leader>bp", "<Cmd>BufferPick<CR>")
		vim.keymap.set("n", "<leader>bd", "<Cmd>BufferClose<CR>")
	end,
}
