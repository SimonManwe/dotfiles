return {
	"mikavilpas/yazi.nvim",
	event = "VeryLazy",
	keys = {
		{
			"<leader>y",
			"<cmd>Yazi<cr>",
			desc = "Open yazi",
		},
		{
			-- Open in the current working directory
			"<leader>Y",
			"<cmd>Yazi cwd<cr>",
			desc = "Open yazi in cwd",
		},
	},
	opts = {
		-- Replace netrw entirely
		open_for_directories = false,

		-- Floating window settings
		yazi_floating_window_winblend = 0,
		yazi_floating_window_border = "rounded",

		-- Custom keymaps while yazi is focused
		keymaps = {
			show_help = "<f1>",
			open_file_in_vertical_split = "<c-v>",
			open_file_in_horizontal_split = "<c-x>",
			open_file_in_tab = "<c-t>",
			grep_in_directory = "<c-s>",
			replace_in_directory = "<c-g>",
			cycle_open_buffers = "<tab>",
			copy_relative_path_to_selected_files = "<c-y>",
			send_to_quickfix_list = "<c-q>",
			change_working_directory = "<c-\\>",
		},

		-- What to do when a file is opened
		open_file_function = function(chosen_file, config, state)
			vim.cmd("edit " .. chosen_file)
		end,

		-- Log level (useful for debugging)
		log_level = vim.log.levels.OFF,
	},
}
