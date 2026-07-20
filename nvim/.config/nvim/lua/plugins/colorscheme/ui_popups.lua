return {
	"folke/noice.nvim",
	event = "VeryLazy",
	dependencies = {
		"MunifTanjim/nui.nvim",
		"rcarriga/nvim-notify",
	},
	opts = {
		lsp = {
			-- override markdown rendering so that cmp and other plugins use Treesitter
			override = {
				["vim.lsp.util.convert_input_to_markdown_lines"] = true,
				["vim.lsp.util.stylize_markdown"] = true,
				["cmp.entry.get_documentation"] = true, -- requires hrsh7th/nvim-cmp
			},
		},
		presets = {
			bottom_search = false, -- keep classic bottom cmdline for live search
			command_palette = true, -- position cmdline + popupmenu together (floating)
			long_message_to_split = true, -- long messages go to a split, not a big popup
			inc_rename = false,  -- only relevant for inc-rename.nvim
			lsp_doc_border = false, -- no border on hover/signature popups
		},
		-- Supress common messages without value
		routes = {
			{
				filter = {
					event = "msg_show",
					kind = "",
					find = "yank",
				},
				opts = { skip = true },
			},
			{
				filter = {
					event = "msg_show",
					kind = "",
					find = "put",
				},
				opts = { skip = true },
			},
			{
				filter = {
					event = "msg_show",
					kind = "",
					find = "more lines",
				},
				opts = { skip = true },
			},
			{
				filter = {
					event = "msg_show",
					kind = "",
					find = "fewer lines",
				},
				opts = { skip = true },
			},
			{
				filter = {
					event = "msg_show",
					kind = "",
					find = "written",
				},
				opts = { skip = true },
			},
			{
				filter = {
					event = "msg_show",
					kind = "search_count",
				},
				opts = { skip = true },
			},
			{
				filter = {
					event = "msg_show",
					find = "search hit BOTTOM",
				},
				opts = { skip = true },
			},
			{
				filter = {
					event = "msg_show",
					find = "search hit TOP",
				},
				opts = { skip = true },
			},
		},
	},
}
