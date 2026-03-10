return {
	{
		"CopilotC-Nvim/CopilotChat.nvim",
		branch = "main",
		dependencies = {
			{ "zbirenbaum/copilot.lua" },
			{ "nvim-lua/plenary.nvim" },
		},
		opts = {
			debug = false,
			window = {
				layout = 'float', -- 'vertical', 'horizontal', 'float'
				width = 0.8,
				height = 0.8,
				border = 'rounded',
			},
			mappings = {
				complete = {
					detail = 'Use @<Tab> or /<Tab> for options.',
					insert = '<Tab>',
				},
				close = {
					normal = 'q',
					insert = '<C-c>'
				},
				reset = {
					normal = '<C-r>',
					insert = '<C-r>'
				},
				submit_prompt = {
					normal = '<CR>',
					insert = '<C-s>'
				},
				accept_diff = {
					normal = '<C-y>',
					insert = '<C-y>'
				},
				yank_diff = {
					normal = 'gy',
				},
				show_diff = {
					normal = 'gd'
				},
				show_info = {
					normal = 'gp'
				},
				show_context = {
					normal = 'gs'
				},
			},
		},
		keys = {
			-- Chat öffnen/schließen
			{
				"<leader>cc",
				":CopilotChatToggle<cr>",
				desc = "Copilot Chat Toggle",
				mode = { "n", "v" },
			},

			-- Visual Mode Commands (Code markieren und dann verwenden)
			{
				"<leader>ce",
				":CopilotChatExplain<cr>",
				mode = "x",
				desc = "Copilot: Explain Code",
			},
			{
				"<leader>ct",
				":CopilotChatTests<cr>",
				mode = "x",
				desc = "Copilot: Generate Tests",
			},
			{
				"<leader>cf",
				":CopilotChatFix<cr>",
				mode = "x",
				desc = "Copilot: Fix Code",
			},
			{
				"<leader>co",
				":CopilotChatOptimize<cr>",
				mode = "x",
				desc = "Copilot: Optimize Code",
			},
			{
				"<leader>cd",
				":CopilotChatDocs<cr>",
				mode = "x",
				desc = "Copilot: Generate Docs",
			},
			{
				"<leader>cr",
				":CopilotChatReview<cr>",
				mode = "x",
				desc = "Copilot: Review Code",
			},

			-- Normal Mode Commands
			{
				"<leader>cm",
				":CopilotChatCommit<cr>",
				desc = "Copilot: Generate Commit Message",
			},
			{
				"<leader>cq",
				function()
					local input = vim.fn.input("Quick Chat: ")
					if input ~= "" then
						require("CopilotChat").ask(input, { selection = require("CopilotChat.select").buffer })
					end
				end,
				desc = "Copilot: Quick Chat",
			},
		},
		config = function(_, opts)
			local chat = require("CopilotChat")
			chat.setup(opts)

			-- Autocommand um Chat-Fenster besser zu stylen
			vim.api.nvim_create_autocmd("BufEnter", {
				pattern = "copilot-*",
				callback = function()
					vim.opt_local.relativenumber = false
					vim.opt_local.number = false
				end,
			})
		end,
	},
}

