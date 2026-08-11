return {
	"mrcjkb/rustaceanvim",
	version = "^9",
	lazy = false,

	config = function()
		local mason_registry = require("mason-registry")
		local codelldb_adapter = mason_registry.get_package("codelldb"):get_install_path() .. "/extension/"
		local codelldb_path = codelldb_adapter .. "adapter/codelldb"
		local liblldb_path = codelldb_adapter .. "lldb/lib/liblldb.so"
		vim.g.rustaceanvim = {
			server = {
				settings = {
					["rust-analyzer"] = {
						cargo = {
							allFeatures = true,
						},
					},
				},
			},
			dap = {
				adapter = require("rustaceanvim.config").get_codelldb_adapter(codelldb_path, liblldb_path),
			},
		}

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
