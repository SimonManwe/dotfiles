vim.api.nvim_create_autocmd("FileType", {
	pattern = "php",
	callback = function()
		-- Spryker follows PSR-12, set appropriate indentation
		vim.opt_local.shiftwidth = 4
		vim.opt_local.tabstop = 4
		vim.opt_local.expandtab = true

		-- Spryker namespace detection helper
		vim.keymap.set("n", "<leader>sn", function()
			local filepath = vim.fn.expand("%:p")
			-- Convert file path to Spryker namespace
			local namespace = filepath:match("src/(Pyz/[^/]+/[^/]+)")
				or filepath:match("vendor/spryker/[^/]+/src/(Spryker/[^/]+/[^/]+)")

			if namespace then
				namespace = namespace:gsub("/", "\\")
				vim.fn.setreg("+", namespace)
				print("Copied namespace: " .. namespace)
			else
				print("Not in a Spryker module")
			end
		end, { buffer = true, desc = "Spryker: Copy Namespace" })

		-- Quick jump between Spryker layers (Client, Business, Persistence, etc.)
		vim.keymap.set("n", "<leader>sl", function()
			local current_file = vim.fn.expand("%:p")
			local layers = { "Client", "Business", "Persistence", "Communication", "Dependency" }

			local choices = {}
			for _, layer in ipairs(layers) do
				local target = current_file:gsub("/[^/]+/[^/]+%.php$", "/" .. layer)
				if vim.fn.isdirectory(target) == 1 then
					table.insert(choices, layer)
				end
			end

			if #choices > 0 then
				vim.ui.select(choices, {
					prompt = "Jump to layer:",
				}, function(choice)
					if choice then
						local target = current_file:gsub("/[^/]+/", "/" .. choice .. "/")
						vim.cmd("edit " .. target)
					end
				end)
			else
				print("No other layers found")
			end
		end, { buffer = true, desc = "Spryker: Jump to Layer" })
	end,
})

-- Lsp Keybindings:

vim.api.nvim_create_autocmd("FileType", {
	pattern = "php",
	callback = function()
		local bufnr = vim.api.nvim_get_current_buf()

		-- Restart Intelephense (useful after generating IDE helpers)
		vim.keymap.set("n", "<leader>lr", function()
			-- Stop all PHP LSP clients
			local clients = vim.lsp.get_clients({ bufnr = bufnr, name = "intelephense" })
			for _, client in ipairs(clients) do
				vim.lsp.stop_client(client.id)
			end

			-- Wait a bit and restart
			vim.defer_fn(function()
				vim.cmd("edit") -- Reopen buffer to trigger LSP attach
				vim.notify("Intelephense restarted", vim.log.levels.INFO)
			end, 500)
		end, { buffer = bufnr, desc = "LSP: Restart Intelephense" })

		-- Clear Intelephense cache and restart
		vim.keymap.set("n", "<leader>lc", function()
			-- Stop LSP
			local clients = vim.lsp.get_clients({ bufnr = bufnr, name = "intelephense" })
			for _, client in ipairs(clients) do
				vim.lsp.stop_client(client.id)
			end

			-- Clear cache (Unix/Linux/Mac)
			local cache_path = vim.fn.stdpath("cache") .. "/intelephense"
			vim.fn.delete(cache_path, "rf")

			-- Restart
			vim.defer_fn(function()
				vim.cmd("edit")
				vim.notify("Intelephense cache cleared and restarted", vim.log.levels.INFO)
			end, 500)
		end, { buffer = bufnr, desc = "LSP: Clear Cache & Restart" })

		-- Run Spryker IDE autocomplete generator and restart LSP
		vim.keymap.set("n", "<leader>gac", function()
			-- Save current position
			local pos = vim.api.nvim_win_get_cursor(0)

			-- Run in terminal (adjust path if needed)
			local command = "docker/sdk cli vendor/bin/console dev:ide-auto-completion:generate"

			vim.notify("Generating Spryker IDE helpers...", vim.log.levels.INFO)

			vim.fn.jobstart(command, {
				on_exit = function(_, exit_code)
					if exit_code == 0 then
						vim.notify("IDE helpers generated! Restarting LSP...", vim.log.levels.INFO)

						-- Restart Intelephense
						vim.schedule(function()
							local clients = vim.lsp.get_clients({ bufnr = bufnr, name = "intelephense" })
							for _, client in ipairs(clients) do
								vim.lsp.stop_client(client.id)
							end

							vim.defer_fn(function()
								vim.cmd("edit")
								vim.api.nvim_win_set_cursor(0, pos)
								vim.notify("Done! Autocomplete updated.", vim.log.levels.INFO)
							end, 1000)
						end)
					else
						vim.notify("Failed to generate IDE helpers", vim.log.levels.ERROR)
					end
				end,
				stdout_buffered = true,
				stderr_buffered = true,
			})
		end, { buffer = bufnr, desc = "Spryker: Generate IDE helpers & restart LSP" })
	end,
})

-- Docbloc stuff

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

		-- Extract method name and create docblock template
		vim.keymap.set("n", "<leader>pm", function()
			-- Get current line
			local line_num = vim.api.nvim_win_get_cursor(0)[1]
			local line = vim.api.nvim_buf_get_lines(bufnr, line_num - 1, line_num, false)[1]

			-- Parse method signature
			local func_match = line:match("function%s+(%w+)%s*%((.-)%)")
			if not func_match then
				vim.notify("Not on a function definition", vim.log.levels.WARN)
				return
			end

			-- Extract parameters
			local params_str = line:match("%((.-)%)")
			local params = {}
			if params_str and params_str ~= "" then
				for param in params_str:gmatch("[^,]+") do
					local type_hint = param:match("(%w+)%s+%$")
					local var_name = param:match("%$(%w+)")
					if type_hint and var_name then
						table.insert(params, { type = type_hint, name = var_name })
					end
				end
			end

			-- Extract return type
			local return_type = line:match("):%s*([%w\\]+)")

			-- Build docblock
			local docblock = { "/**", " * Method description" }

			if #params > 0 then
				table.insert(docblock, " *")
				for _, param in ipairs(params) do
					table.insert(docblock, " * @param " .. param.type .. " $" .. param.name)
				end
			end

			if return_type then
				table.insert(docblock, " *")
				table.insert(docblock, " * @return " .. return_type)
			end

			table.insert(docblock, " */")

			-- Insert above current line
			vim.api.nvim_buf_set_lines(bufnr, line_num - 1, line_num - 1, false, docblock)

			vim.notify("DocBlock generated", vim.log.levels.INFO)
		end, { buffer = bufnr, desc = "PHP: Generate method DocBlock from signature" })
	end,
})
