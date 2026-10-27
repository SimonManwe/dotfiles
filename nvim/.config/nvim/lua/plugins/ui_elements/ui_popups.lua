-- Messages to silently drop (matched against msg_show)
local skip_patterns = {
	"yank",
	"put",
	"more lines",
	"fewer lines",
	"written",
	"search hit BOTTOM",
	"search hit TOP",
}

local routes = {
	-- search count ([1/5]) has its own kind
	{ filter = { event = "msg_show", kind = "search_count" }, opts = { skip = true } },
}

for _, pattern in ipairs(skip_patterns) do
	table.insert(routes, {
		filter = { event = "msg_show", find = pattern },
		opts = { skip = true },
	})
end

return {
	"folke/noice.nvim",
	event = "VeryLazy",
	dependencies = {
		"MunifTanjim/nui.nvim",
		-- "rcarriga/nvim-notify" removed; snacks.notifier handles notifications now
	},
	opts = {
		notify = { enabled = false },
		lsp = {
			override = {
				["vim.lsp.util.convert_input_to_markdown_lines"] = true,
				["vim.lsp.util.stylize_markdown"] = true,
			},
		},
		presets = {
			bottom_search = false,
			command_palette = true,
			long_message_to_split = true,
			inc_rename = false,
			lsp_doc_border = false,
		},
		routes = routes,
	},
}
