return {
	-- Completion engine
	{
		"hrsh7th/nvim-cmp",
		event = "InsertEnter",
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"hrsh7th/cmp-cmdline",
			"L3MON4D3/LuaSnip",
			"saadparwaiz1/cmp_luasnip",
			"rafamadriz/friendly-snippets",
			"zbirenbaum/copilot-cmp",
		},
		config = function()
			local cmp = require("cmp")
			local luasnip = require("luasnip")

			-- Load VSCode-style snippets
			require("luasnip.loaders.from_vscode").lazy_load()

			cmp.setup({
				snippet = {
					expand = function(args)
						luasnip.lsp_expand(args.body)
					end,
				},

				window = {
					completion = cmp.config.window.bordered(),
					documentation = cmp.config.window.bordered(),
				},

				mapping = cmp.mapping.preset.insert({
					["<C-b>"] = cmp.mapping.scroll_docs(-4),
					["<C-f>"] = cmp.mapping.scroll_docs(4),
					["<C-Space>"] = cmp.mapping.complete(),
					["<C-e>"] = cmp.mapping.abort(),
					["<CR>"] = cmp.mapping.confirm({ select = false }),

					-- Tab completion
					["<Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_next_item()
						elseif luasnip.expand_or_jumpable() then
							luasnip.expand_or_jump()
						else
							fallback()
						end
					end, { "i", "s" }),

					["<S-Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_prev_item()
						elseif luasnip.jumpable(-1) then
							luasnip.jump(-1)
						else
							fallback()
						end
					end, { "i", "s" }),
				}),

			sources = cmp.config.sources({
				{ name = "copilot", priority = 1100 },
				{ name = "nvim_lsp", priority = 1000 },
				{ name = "luasnip", priority = 750 },
					{
						name = "buffer",
						priority = 500,
						option = {
							get_bufnrs = function()
								local buf = vim.api.nvim_get_current_buf()
								local byte_size = vim.api.nvim_buf_get_offset(buf, vim.api.nvim_buf_line_count(buf))
								if byte_size > 1024 * 1024 then -- 1MB limit
									return {}
								end
								return { buf }
							end,
						},
					},
					{ name = "path", priority = 250 },
				}),

				keyword_length = 2,

				performance = {
					debounce = 150,
					throttle = 60,
					fetching_timeout = 200,
					max_view_entries = 50,
				},

				formatting = {
					fields = { "abbr", "kind", "menu" },
					format = function(entry, item)
						local menu_icon = {
							copilot = "[Copilot]",
							nvim_lsp = "[LSP]",
							luasnip = "[Snip]",
							buffer = "[Buf]",
							path = "[Path]",
						}
						item.menu = menu_icon[entry.source.name]
						return item
					end,
				},

				experimental = {
					ghost_text = false,
				},
			})

			-- Command line completion
			cmp.setup.cmdline("/", {
				mapping = cmp.mapping.preset.cmdline(),
				sources = {
					{ name = "buffer" },
				},
			})

			cmp.setup.cmdline(":", {
				mapping = cmp.mapping.preset.cmdline(),
				sources = cmp.config.sources({
					{ name = "path" },
				}, {
					{ name = "cmdline" },
				}),
			})
		end,
	},

	-- Snippet engine
	{
		"L3MON4D3/LuaSnip",
		version = "v2.*",
		build = "make install_jsregexp",
	},
}
