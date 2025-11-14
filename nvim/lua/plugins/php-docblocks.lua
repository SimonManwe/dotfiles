return {
	{
		"danymat/neogen",
		dependencies = "nvim-treesitter/nvim-treesitter",
		ft = { "php", "javascript", "typescript", "lua", "python" },
		keys = {
			{ "<leader>nf", "<cmd>Neogen func<cr>", desc = "Neogen: Function DocBlock" },
			{ "<leader>nc", "<cmd>Neogen class<cr>", desc = "Neogen: Class DocBlock" },
			{ "<leader>nt", "<cmd>Neogen type<cr>", desc = "Neogen: Type DocBlock" },
			{ "<leader>nn", "<cmd>Neogen<cr>", desc = "Neogen: Auto DocBlock" },
		},
		config = function()
			require("neogen").setup({
				enabled = true,
				snippet_engine = "luasnip",
				languages = {
					php = {
						template = {
							annotation_convention = "phpdoc", -- Use PHPDoc style
						},
					},
				},
			})
		end,
	},
}
