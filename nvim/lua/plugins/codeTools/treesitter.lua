return {
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",
	event = { "BufReadPost", "BufNewFile" },
	opts = {
		ensure_installed = {
			"lua", "vim", "vimdoc", "bash",
			"javascript", "json", "xml", "yaml",
			"regex", "typescript", "html", "css",
			"python", "php", "rust", "tmux",
		},
		highlight = { enable = true },
		indent = { enable = true },
	},
}
