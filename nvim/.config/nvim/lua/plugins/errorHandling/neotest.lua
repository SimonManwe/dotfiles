return {
	"nvim-neotest/neotest",
	dependencies = {
		"nvim-neotest/nvim-nio",
		"nvim-lua/plenary.nvim",
		"antoinemadec/FixCursorHold.nvim",
		"nvim-treesitter/nvim-treesitter",
		"nvim-neotest/neotest-jest",
		"rouge8/neotest-rust",
		"olimorris/neotest-phpunit",
	},
	keys = {
		{ "<leader>Tt", function() require("neotest").run.run() end, desc = "Run nearest test" },
		{ "<leader>Tf", function() require("neotest").run.run(vim.fn.expand("%")) end, desc = "Run file tests" },
		{ "<leader>Ts", function() require("neotest").summary.toggle() end, desc = "Toggle summary" },
		{ "<leader>To", function() require("neotest").output.open({ enter = true }) end, desc = "Show output" },
		{ "<leader>TO", function() require("neotest").output_panel.toggle() end, desc = "Toggle output panel" },
		{ "<leader>TS", function() require("neotest").run.stop() end, desc = "Stop test" },
		{ "[t", function() require("neotest").jump.prev({ status = "failed" }) end, desc = "Prev failed test" },
		{ "]t", function() require("neotest").jump.next({ status = "failed" }) end, desc = "Next failed test" },
	},
	config = function()
		require("neotest").setup({
			adapters = {
				require("neotest-jest")({
					jestCommand = "npm test --",
				}),
				require("neotest-rust"),
				require("neotest-phpunit"),
			},
			floating = {
				border = "rounded",
				max_height = 0.6,
				max_width = 0.8,
			},
			output = {
				open_on_run = false,
			},
			status = {
				enabled = true,
				signs = false,
				virtual_text = true,
			},
			diagnostic = {
				enabled = false,
			},
			icons = {
				passed = "✓",
				failed = "✗",
				running = "◐",
				skipped = "○",
				unknown = "?",
			},
		})

		vim.api.nvim_set_hl(0, "NeotestPassed", { fg = "#a6e3a1" })  -- green
		vim.api.nvim_set_hl(0, "NeotestFailed", { fg = "#f38ba8" })  -- red
		vim.api.nvim_set_hl(0, "NeotestRunning", { fg = "#f9e2af" }) -- yellow
		vim.api.nvim_set_hl(0, "NeotestSkipped", { fg = "#9399b2" }) -- gray
	end,
}
