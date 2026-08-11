return {
	{
		"phpactor/phpactor",
		build = "composer install --no-dev --optimize-autoloader",
		ft = "php",
		keys = {
			{ "<leader>pm", ":PhpactorContextMenu<CR>", desc = "Phpactor: Context Menu" },
			{ "<leader>pn", ":PhpactorClassNew<CR>", desc = "Phpactor: New Class" },
			{ "<leader>pi", ":PhpactorImportClass<CR>", desc = "Phpactor: Import Class" },
			{ "<leader>pt", ":PhpactorTransform<CR>", desc = "Phpactor: Transform" },
		},
	},

	-- YAML support (for Spryker configs)
	{
		"cuducos/yaml.nvim",
		ft = { "yaml", "yml" },
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
			"nvim-telescope/telescope.nvim",
		},
	},
	-- Advanced text objects for PHP (e.g., ci$ for variable names)
	{
		"kana/vim-textobj-user",
		dependencies = {
			"2072/PHP-Indenting-for-VIm",
		},
	},
	-- Inline Laravel/Symfony docs (helpful for Spryker's Symfony base)
	{
		"ccaglak/phptools.nvim",
		keys = {
			{ "<leader>lm", "<cmd>PhpMethod<cr>", desc = "PHP: Method Info" },
			{ "<leader>lc", "<cmd>PhpClass<cr>", desc = "PHP: Class Info" },
		},
		opts = {
			ui = true, -- Show in floating window
		},
	},
}
