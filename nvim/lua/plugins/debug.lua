-- stylua: ignore file

return {
	-- Core DAP plugin
	{
		"mfussenegger/nvim-dap",
		dependencies = {
			"rcarriga/nvim-dap-ui",
			"nvim-neotest/nvim-nio",
			"theHamsta/nvim-dap-virtual-text",
		},
		config = function()
			local dap = require("dap")
			local dapui = require("dapui")

			-- Setup DAP UI
			dapui.setup({
				icons = {
					expanded = "▾",
					collapsed = "▸",
					current_frame = "▸",
				},
				mappings = {
					expand = { "<CR>", "<2-LeftMouse>" },
					open = "o",
					remove = "d",
					edit = "e",
					repl = "r",
					toggle = "t",
				},
				layouts = {
					{
						elements = {
							"scopes",
							"breakpoints",
							"stacks",
							"watches",
						},
						size = 50,
						position = "left",
					},
					{
						elements = {
							"repl",
							"console",
						},
						size = 10,
						position = "bottom",
					},
				},
				controls = {
					enabled = true,
					element = "repl",
					icons = {
						pause = "⏸",
						play = "▶",
						step_into = "⏎",
						step_over = "⏭",
						step_out = "⏮",
						step_back = "b",
						run_last = "▶▶",
						terminate = "⏹",
					},
				},
				floating = {
					border = "rounded",
					mappings = {
						close = { "q", "<Esc>" },
					},
				},
			})

			-- Virtual text setup
			require("nvim-dap-virtual-text").setup({
				enabled = true,
				enabled_commands = true,
				highlight_changed_variables = true,
				highlight_new_as_changed = false,
				show_stop_reason = true,
				commented = false,
			})

			-- Auto open/close DAP UI
			dap.listeners.after.event_initialized["dapui_config"] = function()
				dapui.open()
			end
			dap.listeners.before.event_terminated["dapui_config"] = function()
				dapui.close()
			end
			dap.listeners.before.event_exited["dapui_config"] = function()
				dapui.close()
			end

			-- XDebug adapter configuration for PHP
			dap.adapters.php = {
				type = "executable",
				command = "node",
				args = {
					vim.fn.stdpath("data") .. "/mason/packages/php-debug-adapter/extension/out/phpDebug.js",
				},
			}

			-- PHP/Spryker debug configuration
			dap.configurations.php = {
				{
					name = "Listen for XDebug (Spryker)",
					type = "php",
					request = "launch",
					port = 9003,
					pathMappings = {
						["/data"] = "${workspaceFolder}",
					},
					log = false,
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

			-- Debugging keybindings
			vim.keymap.set("n", "<F5>", dap.continue, { desc = "Debug: Start/Continue" })
			vim.keymap.set("n", "<F10>", dap.step_over, { desc = "Debug: Step Over" })
			vim.keymap.set("n", "<F6>", dap.step_into, { desc = "Debug: Step Into" })
			vim.keymap.set("n", "<F12>", dap.step_out, { desc = "Debug: Step Out" })
			vim.keymap.set("n", "<leader>bp", dap.toggle_breakpoint, { desc = "Debug: Toggle Breakpoint" })
			vim.keymap.set("n", "<leader>Bp", function()
				dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
			end, { desc = "Debug: Set Conditional Breakpoint" })
			vim.keymap.set("n", "<leader>dr", dap.repl.open, { desc = "Debug: Open REPL" })
			vim.keymap.set("n", "<leader>dl", dap.run_last, { desc = "Debug: Run Last" })
			vim.keymap.set("n", "<leader>dt", dapui.toggle, { desc = "Debug: Toggle UI" })

			-- Stack trace navigation
			vim.keymap.set("n", "<leader>du", dap.up, { desc = "Debug: Stack Up" })
			vim.keymap.set("n", "<leader>dd", dap.down, { desc = "Debug: Stack Down" })
			vim.keymap.set("n", "<leader>df", function()
				require("dapui").float_element("stacks", { width = 100, height = 30, enter = true })
			end, { desc = "Debug: Floating Stacktrace" })
			vim.keymap.set("n", "<leader>ds", function()
				require("dapui").toggle({ layout = 1 })
			end, { desc = "Debug: Toggle Stack Panel" })

			-- Hover to see variable values
			vim.keymap.set("n", "<leader>dh", function()
				require("dap.ui.widgets").hover()
			end, { desc = "Debug: Hover Variables" })

			-- Frames sidebar widget (alternative stacktrace view)
			vim.keymap.set("n", "<leader>dF", function()
				local widgets = require("dap.ui.widgets")
				widgets.sidebar(widgets.frames):open()
			end, { desc = "Debug: Open Frames Sidebar" })

			-- Breakpoint signs/icons
			vim.fn.sign_define("DapBreakpoint", { text = "🔴", texthl = "", linehl = "", numhl = "" })
			vim.fn.sign_define("DapBreakpointCondition", { text = "🟡", texthl = "", linehl = "", numhl = "" })
			vim.fn.sign_define("DapBreakpointRejected", { text = "🔵", texthl = "", linehl = "", numhl = "" })
			vim.fn.sign_define("DapStopped", { text = "➡️", texthl = "", linehl = "debugPC", numhl = "" })

			-- Highlight for current debug line
			vim.api.nvim_set_hl(0, "debugPC", { bg = "#3d3d3d" })
		end,
	},

	-- Install PHP debug adapter via Mason
	{
		"jay-babu/mason-nvim-dap.nvim",
		dependencies = {
			"williamboman/mason.nvim",
			"mfussenegger/nvim-dap",
		},
		config = function()
			require("mason-nvim-dap").setup({
				ensure_installed = { "php" },
				automatic_installation = true,
				handlers = {},
			})
		end,
	},
}
