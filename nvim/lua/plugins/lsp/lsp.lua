return {
	"neovim/nvim-lspconfig",
	dependencies = {
		"williamboman/mason.nvim",
		"williamboman/mason-lspconfig.nvim",
		"nvim-telescope/telescope.nvim",
		"hrsh7th/cmp-nvim-lsp",
	},
	config = function()
		-- Get completion capabilities from nvim-cmp
		local capabilities = require("cmp_nvim_lsp").default_capabilities()

		-- Keybindings for LSP using Telescope
		local on_attach = function(_, bufnr)
			local nmap = function(keys, func, desc)
				if desc then
					desc = "LSP: " .. desc
				end
				vim.keymap.set("n", keys, func, { buffer = bufnr, desc = desc })
			end
			nmap("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
			nmap("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction")
			nmap("gd", require("telescope.builtin").lsp_definitions, "[G]oto [D]efinition")
			nmap("gr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")
			nmap("gI", require("telescope.builtin").lsp_implementations, "[G]oto [I]mplementation")
			nmap("<leader>D", require("telescope.builtin").lsp_type_definitions, "Type [D]efinition")
			nmap("<leader>ds", require("telescope.builtin").lsp_document_symbols, "[D]ocument [S]ymbols")
			nmap("<leader>ws", require("telescope.builtin").lsp_dynamic_workspace_symbols, "[W]orkspace [S]ymbols")
			nmap("K", vim.lsp.buf.hover, "Hover Documentation")
			nmap("<C-k>", vim.lsp.buf.signature_help, "Signature Documentation")
			nmap("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")
		end

		-- Auto-attach keybindings when LSP attaches
		vim.api.nvim_create_autocmd("LspAttach", {
			group = vim.api.nvim_create_augroup("UserLspConfig", {}),
			callback = on_attach,
		})

		-- Document highlighting
		vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
			group = vim.api.nvim_create_augroup("LspDocumentHighlight", {}),
			callback = function()
				vim.lsp.buf.document_highlight()
			end,
		})

		vim.api.nvim_create_autocmd("CursorMoved", {
			group = vim.api.nvim_create_augroup("LspDocumentHighlight", {}),
			callback = function()
				vim.lsp.buf.clear_references()
			end,
		})

		-- LSP optimizations for large projects
		vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
			update_in_insert = false,
			virtual_text = {
				spacing = 4,
				prefix = "●",
			}
		})

		-- Enable LSP servers with capabilities (Neovim 0.11+ style)
		vim.lsp.enable("ts_ls", {
			capabilities = capabilities,
			settings = {
				typescript = {
					inlayHints = {
						includeInlayParameterNameHints = "all",
						includeInlayFunctionParameterTypeHints = true,
						includeInlayVariableTypeHints = true,
					},
				},
			},
		})

		vim.lsp.enable("html", {
			capabilities = capabilities
		})

		vim.lsp.enable("intelephense", {
			capabilities = capabilities
		})

		vim.lsp.enable("rust_analyzer", {
			capabilities = capabilities,
			settings = {
				["rust-analyzer"] = {
					check = {
						command = "clippy",
					},
					cargo = {
						allFeatures = true,
					},
				},
			},
		})

		vim.lsp.enable("lua_ls", {
			capabilities = capabilities,
			settings = {
				Lua = {
					diagnostics = {
						globals = { "vim" },
					},
					workspace = {
						library = vim.api.nvim_get_runtime_file("", true),
						checkThirdParty = false,
					},
					telemetry = {
						enable = false,
					},
				},
			},
		})

		-- Large file handling - disable LSP for files > 1MB
		vim.api.nvim_create_autocmd("BufReadPre", {
			callback = function()
				local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(0))
				if ok and stats and stats.size > 1024 * 1024 then
					vim.b.large_buf = true
					vim.opt_local.eventignore:append("FileType")
					vim.opt_local.bufhidden = "unload"
					vim.opt_local.swapfile = false
					vim.opt_local.undolevels = -1
					vim.opt_local.undofile = false
				end
			end,
		})
	end,
}
