return {
	"mfussenegger/nvim-dap",
	dependencies = {
		"rcarriga/nvim-dap-ui",
		"nvim-neotest/nvim-nio",
		"theHamsta/nvim-dap-virtual-text",
		"williamboman/mason.nvim",
	},
	config = function()
		local dap = require("dap")
		local dapui = require("dapui")

		dapui.setup()
		require("nvim-dap-virtual-text").setup()

		-- Auto open/close the UI when a debug session starts/ends
		dap.listeners.after.event_initialized["dapui_config"] = function()
			dapui.open()
		end
		dap.listeners.before.event_terminated["dapui_config"] = function()
			dapui.close()
		end
		dap.listeners.before.event_exited["dapui_config"] = function()
			dapui.close()
		end

		local mason_registry = require("mason-registry")
		local php_debug_path = mason_registry.get_package("php-debug-adapter"):get_install_path()

		dap.adapters.php = {
			type = "executable",
			command = "node",
			args = { php_debug_path .. "/extension/out/phpDebug.js" },
		}

		dap.configurations.php = {
			{
				type = "php",
				request = "launch",
				name = "Listen for Xdebug (Spryker Docker SDK)",
				port = 9003, -- Xdebug 3 default; use 9000 if you're still on Xdebug 2
				hostname = "0.0.0.0",
				log = true,
				pathMappings = {
					["/data"] = "${workspaceFolder}",
				},
			},
		}

		local keymap = vim.keymap.set
		keymap("n", "<F5>", dap.continue, { desc = "DAP Continue" })
		keymap("n", "<F10>", dap.step_over, { desc = "DAP Step Over" })
		keymap("n", "<F11>", dap.step_into, { desc = "DAP Step Into" })
		keymap("n", "<F12>", dap.step_out, { desc = "DAP Step Out" })
		keymap("n", "<leader>db", dap.toggle_breakpoint, { desc = "Toggle Breakpoint" })
		keymap("n", "<leader>dB", function()
			dap.set_breakpoint(vim.fn.input("Condition: "))
		end, { desc = "Conditional Breakpoint" })
		keymap("n", "<leader>dr", dap.repl.open, { desc = "Open DAP REPL" })
		keymap("n", "<leader>du", dapui.toggle, { desc = "Toggle DAP UI" })
		keymap("n", "<leader>dt", dap.terminate, { desc = "Terminate Debug Session" })
	end,
}
