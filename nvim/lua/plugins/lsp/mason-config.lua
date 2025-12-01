return {
	{
		"mason-org/mason.nvim",
		config = function()
			require("mason").setup()
		end,
	},
	{
		"mason-org/mason-lspconfig.nvim",
		opts = {},
		dependencies = {
			{ "mason-org/mason.nvim", opts = {} },
			"neovim/nvim-lspconfig",
		},
		config = function()
			require("mason-lspconfig").setup({
				ensure_installed = {
					"lua_ls",
					"rust_analyzer",
					"html",
					"intelephense",
					"ts_ls",
					"cssls",
					"tailwindcss",
				},
			})
		end,
	},
	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		dependencies = { "williamboman/mason.nvim" },
		config = function()
			require("mason-tool-installer").setup({
				ensure_installed = {
					"prettier", -- Prettier formatter
					"eslint_d", -- ESLint (faster daemon version)
					"php-cs-fixer", -- PHP formatter
					"rustfmt", -- Rust formatter
					"stylelint", -- css formatter
				},
				auto_update = true,
				run_on_start = true,
			})
		end,
	},
}
