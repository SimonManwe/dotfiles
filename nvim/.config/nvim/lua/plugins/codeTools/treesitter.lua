return {
	"nvim-treesitter/nvim-treesitter",
	branch = "main",
	lazy = false,
	build = ":TSUpdate",
	config = function()
		require("nvim-treesitter").setup({
			install_dir = vim.fn.stdpath("data") .. "/site",
		})
		local ts = require("nvim-treesitter")

		ts.install({
			"lua",
			"vim",
			"vimdoc",
			"bash",
			"javascript",
			"json",
			"xml",
			"yaml",
			"regex",
			"typescript",
			"html",
			"css",
			"python",
			"php",
			"rust",
			"tmux",
		})

		vim.api.nvim_create_autocmd("FileType", {
			callback = function()
				pcall(vim.treesitter.start)
			end,
		})

		vim.api.nvim_create_autocmd("FileType", {
			callback = function()
				vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
			end,
		})
	end,
}
