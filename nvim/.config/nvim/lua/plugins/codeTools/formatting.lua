return {
	"stevearc/conform.nvim",
	event = { "BufWritePre" },
	cmd = { "ConformInfo" },
	config = function()
		require("conform").setup({
			formatters_by_ft = {
				javascript = { "prettier" },
				typescript = { "prettier" },
				javascriptreact = { "prettier" },
				typescriptreact = { "prettier" },
				css = { "prettier" },
				scss = { "prettier" },
				sass = { "prettier" },
				less = { "prettier" },
				html = { "prettier" },
				json = { "prettier" },
				yaml = { "prettier" },
				markdown = { "prettier" },
				php = { "php_cs_fixer" },
				rust = { "rustfmt" },
			},

			format_on_save = function(bufnr)
				-- Disable for large files
				local buf_size = vim.api.nvim_buf_get_offset(bufnr, vim.api.nvim_buf_line_count(bufnr))
				if buf_size > 1024 * 1024 then -- 1MB
					return
				end

				-- Disable for specific file types if needed
				local bufname = vim.api.nvim_buf_get_name(bufnr)
				if bufname:match("/node_modules/") or bufname:match("/vendor/") then
					return
				end

				return {
					timeout_ms = 3000,
					lsp_format = "fallback",
				}
			end,

			formatters = {
				php_cs_fixer = {
					command = "php-cs-fixer",
					args = {
						"fix",
						"$FILENAME",
						"--rules=@PSR12", -- Spryker uses PSR-12
						"--allow-risky=yes",
					},
					stdin = false,
				},
				prettier = {
					prepend_args = {
						"--prose-wrap=always",
						"--print-width=120",
					},
				},
			},
		})

		vim.keymap.set({ "n", "v" }, "<leader>f", function()
			require("conform").format({
				lsp_fallback = true,
				async = false,
				timeout_ms = 1000,
			})
		end, { desc = "Format file or range" })
	end,
}
