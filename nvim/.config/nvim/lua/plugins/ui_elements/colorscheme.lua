return {
	{
		"catppuccin/nvim",
		name = "catppuccin",
		priority = 1000,
		lazy = false,
		config = function()
			require("catppuccin").setup({
				flavour = "macchiato", -- latte, frappe, macchiato, mocha
				transparent_background = true,
				term_colors = true,
				integrations = {
					treesitter = true,
					telescope = true,
					nvimtree = true,
					cmp = true,
					neotest = true,
					dap = true,
					dap_ui = true,
					gitsigns = true,
					which_key = true,
					indent_blankline = { enabled = true },
					native_lsp = {
						enabled = true,
						virtual_text = {
							errors = { "italic" },
							hints = { "italic" },
							warnings = { "italic" },
							information = { "italic" },
						},
						underlines = {
							errors = { "underline" },
							hints = { "underline" },
							warnings = { "underline" },
							information = { "underline" },
						},
					},
				},
				custom_highlights = function(colors)
					return {
						TelescopeNormal = { bg = "NONE" },
						TelescopeBorder = { bg = "NONE" },
						TelescopePromptNormal = { bg = "NONE" },
						TelescopePromptBorder = { bg = "NONE" },
						TelescopePromptTitle = { bg = "NONE" },
						TelescopePreviewNormal = { bg = "NONE" },
						TelescopePreviewBorder = { bg = "NONE" },
						TelescopePreviewTitle = { bg = "NONE" },
						TelescopeResultsNormal = { bg = "NONE" },
						TelescopeResultsBorder = { bg = "NONE" },
						TelescopeResultsTitle = { bg = "NONE" },
					}
				end,
			})
		end,
	},
	{
		"scottmckendry/cyberdream.nvim",
		lazy = false,
		priority = 1000,
		config = function()
			require("cyberdream").setup({
				variant = "auto",
				transparent = true,
				italic_comments = true,
				hide_fillchars = true,
				borderless_pickers = false,
				borderless_telescope = true,
				terminal_colors = true,
				extensions = {
					telescope = true,
					treesitter = true,
					cmp = true,
					gitsigns = true,
					trouble = true,
					whichkey = true,
				},
			})
			vim.cmd.colorscheme("cyberdream")
		end,
	},
	{
		"catppuccin/nvim",
		keys = {
			{
				"<leader>tt",
				function()
					local variants = {
						"catppuccin-latte",
						"catppuccin-frappe",
						"catppuccin-macchiato",
						"catppuccin-mocha",
						"cyberdream",
					}

					vim.ui.select(variants, {
						prompt = "Select theme:",
					}, function(choice)
						if choice then
							vim.cmd("colorscheme " .. choice)
						end
					end)
				end,
				desc = "Switch Theme",
			},
		},
	},
}
