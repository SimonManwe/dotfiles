vim.g.mapleader = " "
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)

-- GitHub Copilot Keybindings
vim.keymap.set("n", "<leader>cp", ":Copilot panel<CR>", { desc = "Copilot Panel" })
vim.keymap.set("n", "<leader>ce", ":Copilot enable<CR>", { desc = "Copilot Enable" })
vim.keymap.set("n", "<leader>cd", ":Copilot disable<CR>", { desc = "Copilot Disable" })
vim.keymap.set("n", "<leader>cs", ":Copilot status<CR>", { desc = "Copilot Status" })
-- git log
vim.keymap.set("n", "<leader>gl", function()
	local file = vim.fn.expand("%:p")
	local cmd = string.format(
		"tmux popup -xC -yC -w90%% -h85%% -E \"git log --format='%%h %%s' --color=always -- %s"
			.. '| fzf --ansi --no-sort --preview \\"git show --color=always {1} -- %s | delta --paging=never '
			.. ' --line-numbers\\" --preview-window=right:60%%"',
		vim.fn.shellescape(file),
		vim.fn.shellescape(file)
	)
	vim.fn.system(cmd)
end, { desc = "Git log for current file in tmux popup" })
