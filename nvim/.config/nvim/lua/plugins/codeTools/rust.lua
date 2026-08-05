return {
	"mrcjkb/rustaceanvim",
	-- This also sets up the rust lsp
	-- To avoid being surprised by breaking changes,
	-- I recommend you set a version range
	version = "^9",
	-- This plugin implements proper lazy-loading (see :h lua-plugin-lazy).
	-- No need for lazy.nvim to lazy-load it.
	lazy = false,
	["rust-analyzer"] = {
		cargo = {
			allFeatures = true,
		},
	},

	config = function()
		vim.keymap.set("n", "<space>rha", function()
			vim.cmd.RustLsp({ "hover", "actions" })
		end, { desc = "[R]ustLsp [H]over [A]ctions" })
		-- execute hover action
		vim.keymap.set("n", "<space>ra", "<Plug>RustHoverAction", { desc = "<N> Hover Action" })

		vim.keymap.set("n", "<space>rD", function()
			vim.cmd.RustLsp("openDocs")
		end, { desc = "[R]ust [D]ocs" })

		vim.keymap.set("n", "<space>rT", function()
			vim.cmd.RustLsp("relatedTests")
		end, { desc = "Rust [related] [T]ests" })
	end,
}
