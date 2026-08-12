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

		dapui.setup({
			layouts = {
				{
					elements = {
						{ id = "scopes", size = 0.55 },
						{ id = "stacks", size = 0.30 },
						{ id = "breakpoints", size = 0.15 },
					},
					size = 50,
					position = "right",
				},
				{
					elements = {
						"repl",
					},
					size = 10,
					position = "bottom",
				},
			},
		})
		require("nvim-dap-virtual-text").setup()

		vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DapBreakpoint", linehl = "", numhl = "" })
		vim.fn.sign_define(
			"DapBreakpointCondition",
			{ text = "◆", texthl = "DapBreakpointCondition", linehl = "", numhl = "" }
		)
		vim.fn.sign_define("DapLogPoint", { text = "◉", texthl = "DapLogPoint", linehl = "", numhl = "" })
		vim.fn.sign_define(
			"DapBreakpointRejected",
			{ text = "✗", texthl = "DapBreakpointRejected", linehl = "", numhl = "" }
		)
		vim.fn.sign_define("DapStopped", { text = "▶", texthl = "DapStopped", linehl = "DapStoppedLine", numhl = "" })

		vim.api.nvim_set_hl(0, "DapBreakpoint", { fg = "#e51400" })
		vim.api.nvim_set_hl(0, "DapBreakpointCondition", { fg = "#e5a500" })
		vim.api.nvim_set_hl(0, "DapLogPoint", { fg = "#61afef" })
		vim.api.nvim_set_hl(0, "DapBreakpointRejected", { fg = "#888888" })
		vim.api.nvim_set_hl(0, "DapStopped", { fg = "#98c379" })
		vim.api.nvim_set_hl(0, "DapStoppedLine", { bg = "#31353f" })

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

		-- Config specifically for Spryker
		dap.configurations.php = {
			{
				name = "Listen for XDebug (Spryker)",
				type = "php",
				request = "launch",
				port = 9003,
				pathMappings = {
					["/data"] = "${workspaceFolder}",
				},
				log = true,
				xdebugSettings = {
					max_children = 256,
					max_data = 1024,
					max_depth = 5,
				},
			},
			{
				name = "Launch current script",
				type = "php",
				request = "launch",
				port = 9003,
				cwd = "${fileDirname}",
				program = "${file}",
				runtimeExecutable = "php",
			},
		}

		-- DAP Setup for Node/ NextJS
		local js_debug_path = mason_registry.get_package("js-debug-adapter"):get_install_path()

		dap.adapters["pwa-node"] = {
			type = "server",
			host = "localhost",
			port = "${port}",
			executable = {
				command = "node",
				args = { js_debug_path .. "/js-debug/src/dapDebugServer.js", "${port}" },
			},
		}
		dap.adapters["pwa-chrome"] = dap.adapters["pwa-node"]

		local configs = {
			{
				type = "pwa-node",
				request = "attach",
				name = "Next.js: Attach to server",
				port = 9229,
				cwd = "${workspaceFolder}",
				sourceMaps = true,
				skipFiles = { "<node_internals>/**", "**/node_modules/**" },
				resolveSourceMapLocations = {
					"${workspaceFolder}/**",
					"!**/node_modules/**",
				},
				sourceMapPathOverrides = {
					["turbopack://[project]/*"] = "${workspaceFolder}/*",
					["webpack://_N_E/*"] = "${workspaceFolder}/*",
					["webpack://[project]/*"] = "${workspaceFolder}/*",
					["webpack:///./~/*"] = "${workspaceFolder}/node_modules/*",
					["webpack://?:*/*"] = "${workspaceFolder}/*",
				},
			},
			{
				type = "pwa-chrome",
				request = "launch",
				name = "Next.js: Launch Chrome",
				url = "http://localhost:3000",
				webRoot = "${workspaceFolder}",
				sourceMaps = false,
			},
		}

		for _, lang in ipairs({ "javascript", "typescript", "javascriptreact", "typescriptreact" }) do
			dap.configurations[lang] = dap.configurations[lang] or {}
			vim.list_extend(dap.configurations[lang], configs)
		end

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

		keymap("n", "<leader>dfr", function()
			dapui.float_element("repl", { width = 90, height = 25, enter = true, position = "center", title = "repl" })
		end, { desc = "Open DAP REPL (floating)" })
		keymap("n", "<leader>dfs", function()
			dapui.float_element(
				"scopes",
				{ width = 90, height = 25, enter = true, position = "center", title = "scopes" }
			)
		end, { desc = "Open DAP Scopes (floating)" })
		keymap("n", "<leader>dfc", function()
			dapui.float_element(
				"console",
				{ width = 90, height = 25, enter = true, position = "center", title = "console" }
			)
		end, { desc = "Open DAP Console (floating)" })
	end,
}
