return {
	"folke/which-key.nvim",
	event = "VeryLazy",
	init = function()
		vim.o.timeout = true
		vim.o.timeoutlen = 500 -- Delay before which-key appears (ms)
	end,
	opts = {
		triggers = { "<leader>" },
	},
}
