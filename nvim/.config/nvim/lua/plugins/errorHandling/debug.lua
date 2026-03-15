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

			-- Custom formatted stacktrace with better path handling
			vim.keymap.set("n", "<leader>ds", function()
				local widgets = require("dap.ui.widgets")
				local sidebar = widgets.sidebar(widgets.frames, {
					width = 80, -- Wider for long paths
				}, "vsplit")

				-- Custom formatter for frames to shorten Spryker paths
				local original_render = sidebar.render
				sidebar.render = function(self)
					if self.view and self.view.get_items then
						local items = self.view:get_items()
						for _, item in ipairs(items or {}) do
							if item.name then
								-- Shorten vendor paths
								item.name = item.name:gsub("/data/vendor/spryker/", "vendor/")
								item.name = item.name:gsub("/data/src/Pyz/", "Pyz/")
								item.name = item.name:gsub("/data/", "")
								-- Limit line length
								if #item.name > 75 then
									item.name = "..." .. item.name:sub(-72)
								end
							end
						end
					end
					return original_render(self)
				end

				sidebar:open()
			end, { desc = "Debug: Stacktrace Sidebar" })

			-- Better floating stacktrace
			vim.keymap.set("n", "<leader>df", function()
				local session = require("dap").session()
				if not session then
					vim.notify("No active debug session", vim.log.levels.WARN)
					return
				end

				-- Get stack frames
				local frames = session.current_frame and session.threads[session.stopped_thread_id].frames or {}

				if #frames == 0 then
					vim.notify("No stack frames available", vim.log.levels.WARN)
					return
				end

				-- Format frames with shortened paths
				local lines = { "Stack Trace:", "" }
				for i, frame in ipairs(frames) do
					local name = frame.name or "unknown"
					local source = frame.source and frame.source.path or "?"
					local line = frame.line or 0

					-- Shorten paths
					source = source:gsub("/data/vendor/spryker/", "v/")
					source = source:gsub("/data/src/Pyz/", "Pyz/")
					source = source:gsub("/data/", "")

					-- Format: frame number, function name, file:line
					local marker = (i == 1) and "➡️ " or "   "
					local frame_line = string.format("%s%2d. %s", marker, i, name)
					local location = string.format("     %s:%d", source, line)

					table.insert(lines, frame_line)
					table.insert(lines, location)
				end

				-- Create floating window
				local buf = vim.api.nvim_create_buf(false, true)
				vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
				vim.api.nvim_buf_set_option(buf, "modifiable", false)
				vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")

				local width = 100
				local height = math.min(#lines + 2, 40)
				local opts = {
					relative = "editor",
					width = width,
					height = height,
					col = (vim.o.columns - width) / 2,
					row = (vim.o.lines - height) / 2,
					style = "minimal",
					border = "rounded",
					title = " Stack Trace ",
					title_pos = "center",
				}

				local win = vim.api.nvim_open_win(buf, true, opts)

				-- Keymaps in floating window
				vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = buf, nowait = true })
				vim.keymap.set("n", "<Esc>", "<cmd>close<cr>", { buffer = buf, nowait = true })

				-- Jump to frame on Enter
				vim.keymap.set("n", "<CR>", function()
					local line_num = vim.api.nvim_win_get_cursor(win)[1]
					-- Find which frame this is (every 2 lines = 1 frame)
					local frame_idx = math.floor((line_num - 2) / 2) + 1
					if frame_idx > 0 and frame_idx <= #frames then
						vim.cmd("close")
						require("dap").set_index(frame_idx)
					end
				end, { buffer = buf, nowait = true })
			end, { desc = "Debug: Floating Stacktrace" })

			-- Original frames sidebar (backup)
			vim.keymap.set("n", "<leader>dF", function()
				local widgets = require("dap.ui.widgets")
				widgets.sidebar(widgets.frames):open()
			end, { desc = "Debug: Frames Sidebar (Raw)" })

			-- Hover to see variable values
			vim.keymap.set("n", "<leader>dh", function()
				require("dap.ui.widgets").hover()
			end, { desc = "Debug: Hover Variables" })

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
