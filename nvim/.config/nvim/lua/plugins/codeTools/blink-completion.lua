return {
	"saghen/blink.cmp",
	dependencies = {
		"saghen/blink.lib",
		-- optional: provides snippets for the snippet source
		"rafamadriz/friendly-snippets",
		"L3MON4D3/LuaSnip",
	},
	build = function()
		-- build the fuzzy matcher, optionally add a timeout to `pwait(timeout_ms)`
		-- you can use `gb` in `:Lazy` to rebuild the plugin as needed
		require("blink.cmp").build():pwait()
	end,

	---@module 'blink.cmp'
	---@type blink.cmp.Config
	opts = {
		keymap = {
			preset = "default",
			["<Tab>"] = { "select_next", "snippet_forward", "fallback" },
			["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
			["<C-b>"] = { "scroll_documentation_up", "fallback" },
			["<C-f>"] = { "scroll_documentation_down", "fallback" },
			["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
			["<C-e>"] = { "hide", "fallback" },
			["<CR>"] = { "accept", "fallback" },
		},

		snippets = {
			preset = "luasnip",
		},

		completion = {
			keyword = { range = "prefix" },
			menu = {
				border = "rounded",
				draw = {
					columns = { { "kind_icon" }, { "label", "label_description", gap = 1 }, { "source_name" } },
				},
			},
			list = { selection = { preselect = false, auto_insert = true } },
			documentation = {
				auto_show = false,
				window = { border = "rounded" },
			},
			ghost_text = { enabled = false },
			accept = { auto_brackets = { enabled = true } },
		},

		sources = {
			default = { "lazydev", "lsp", "path", "snippets", "buffer" },
			per_filetype = {
				lua = { inherit_defaults = true, "lazydev" },
			},
			providers = {
				lazydev = {
					name = "LazyDev",
					module = "lazydev.integrations.blink",
					-- make lazydev completions top priority (see `:h blink.cmp`)
					score_offset = 100,
				},
				buffer = {
					min_keyword_length = 2,
					max_items = 50,
				},
			},
		},
		cmdline = {
			enabled = true,
		},

		fuzzy = { implementation = "rust" },
	},

	config = function(_, opts)
		-- Workaround for an upstream blink.cmp bug on nvim 0.12.0-dev.
		local utils = require("blink.cmp.lib.utils")
		local to_cursor = utils.vim_pos_to_cursor
		utils.vim_pos_to_cursor = function(pos)
			local cursor = to_cursor(pos)
			if type(cursor[1]) == "table" then
				return cursor[1]
			end
			return cursor
		end

		require("blink.cmp").setup(opts)
	end,
}
