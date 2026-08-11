vim.api.nvim_create_autocmd("FileType", {
	pattern = "markdown",
	callback = function()
		vim.opt_local.conceallevel = 2
	end,
})

-- Spryker Docblock Skeleton generation
vim.api.nvim_create_autocmd("FileType", {
	pattern = "php",
	callback = function()
		local bufnr = vim.api.nvim_get_current_buf()

		-- Quick docblock above current line
		vim.keymap.set("n", "<leader>pD", function()
			local line = vim.api.nvim_win_get_cursor(0)[1]
			vim.api.nvim_buf_set_lines(bufnr, line - 1, line - 1, false, {
				"/**",
				" * ",
				" */",
			})
			vim.api.nvim_win_set_cursor(0, { line, 4 }) -- Place cursor after " * "
			vim.cmd("startinsert!")
		end, { buffer = bufnr, desc = "PHP: Insert DocBlock above" })
	end,
})
