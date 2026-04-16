vim.g.mapleader = " "
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)

-- GitHub Copilot Keybindings
vim.keymap.set("n", "<leader>cp", ":Copilot panel<CR>", { desc = "Copilot Panel" })
vim.keymap.set("n", "<leader>ce", ":Copilot enable<CR>", { desc = "Copilot Enable" })
vim.keymap.set("n", "<leader>cd", ":Copilot disable<CR>", { desc = "Copilot Disable" })
vim.keymap.set("n", "<leader>cs", ":Copilot status<CR>", { desc = "Copilot Status" })
--neovim git log
vim.keymap.set("n", "<leader>gl", function()
	local file = vim.fn.expand("%:p")

	-- create a scratch buffer
	local buf = vim.api.nvim_create_buf(false, true)

	-- open floating window
	local width = math.floor(vim.o.columns * 0.9)
	local height = math.floor(vim.o.lines * 0.85)
	local win = vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		width = width,
		height = height,
		col = math.floor((vim.o.columns - width) / 2),
		row = math.floor((vim.o.lines - height) / 2),
		style = "minimal",
		border = "none", -- or 'rounded' etc
	})

	-- transparent background
	vim.api.nvim_win_set_option(win, "winblend", 20) -- 0-100, match your kitty opacity

	-- run fzf-lua or telescope or raw fzf in terminal buffer
	vim.fn.termopen(
		string.format(
			"git log --format='%%h %%s' --color=always -- %s | "
				.. "fzf --ansi --no-sort --preview 'git show --color=always {1} -- %s "
				.. "| DELTA_FEATURES=-side-by-side delta --paging=never' --preview-window=right:60%%",
			vim.fn.shellescape(file),
			vim.fn.shellescape(file)
		),
		{
			on_exit = function()
				vim.api.nvim_win_close(win, true)
			end,
		}
	)

	vim.cmd("startinsert")
end, { desc = "Git log for current file in floating window" })
