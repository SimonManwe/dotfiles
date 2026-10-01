return {
	"neovim/nvim-lspconfig",
	dependencies = {
		"williamboman/mason.nvim",
		"williamboman/mason-lspconfig.nvim",
		"nvim-telescope/telescope.nvim",
		"saghen/blink.cmp",
	},
	config = function()
		-- Get completion capabilities from blink.cmp
		local capabilities = require("blink.cmp").get_lsp_capabilities()

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
			nmap("K", vim.lsp.buf.hover, "Hover Documentation")
			nmap("<C-k>", vim.lsp.buf.signature_help, "Signature Documentation")
		end

		vim.keymap.set("n", "<leader>th", function()
			vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
		end, { desc = "Toggle inlay hints" })

		vim.api.nvim_create_autocmd("LspAttach", {
			group = vim.api.nvim_create_augroup("UserLspConfig", {}),
			callback = function(args)
				on_attach(args)

				local client = vim.lsp.get_client_by_id(args.data.client_id)
				if client and client:supports_method("textDocument/documentHighlight") then
					local group = vim.api.nvim_create_augroup("LspDocumentHighlight_" .. args.buf, { clear = true })

					vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
						group = group,
						buffer = args.buf,
						callback = vim.lsp.buf.document_highlight,
					})

					vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
						group = group,
						buffer = args.buf,
						callback = vim.lsp.buf.clear_references,
					})
				end
			end,
		})

		-- LSP optimizations for large projects
		vim.diagnostic.config({
			update_in_insert = false,
			virtual_text = {
				spacing = 4,
				prefix = "●",
			},
		})

		vim.lsp.config("ts_ls", {
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
		vim.lsp.enable("ts_ls")

		vim.lsp.config("html", {
			capabilities = capabilities,
		})
		vim.lsp.enable("html")

		-- Handled by rustacean.nvim
		-- vim.lsp.config("rust_analyzer", {
		-- 	capabilities = capabilities,
		-- 	settings = {
		-- 		["rust_analyzer"] = {
		-- 			check = {
		-- 				command = "clippy",
		-- 			},
		-- 			cargo = {
		-- 				allFeatures = true,
		-- 			},
		-- 		},
		-- 	},
		-- })
		-- vim.lsp.enable("rust_analyzer")
		vim.lsp.config("clangd", {
			capabilities = capabilities,
			cmd = {
				"clangd",
				"--background-index",
				"--clang-tidy",
				"--header-insertion=iwyu",
				"--completion-style=detailed",
			},
		})

		vim.lsp.enable("clangd")

		vim.lsp.config("lua_ls", {
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
		vim.lsp.enable("lua_ls")

		vim.lsp.config("intelephense", {
			capabilities = capabilities,
			settings = {
				intelephense = {
					files = {
						maxSize = 5000000,
						exclude = {
							"**/vendor/**/tests/**",
							"**/vendor/**/Tests/**",
							"**/node_modules/**",
							"**/data/**",
							"**/log/**",
							"**/public/**/assets/**",
							"**/public/**/*.map",
						},
					},
					environment = {
						phpVersion = "8.4",
					},
					diagnostics = {
						undefinedTypes = false,
						undefinedFunctions = false,
						undefinedConstants = false,
						undefinedClassConstants = false,
						undefinedMethods = false,
						undefinedProperties = false,
						undefinedVariables = true,
					},
					stubs = {
						"apache",
						"bcmath",
						"bz2",
						"calendar",
						"Core",
						"ctype",
						"curl",
						"date",
						"dom",
						"fileinfo",
						"filter",
						"ftp",
						"gd",
						"gettext",
						"gmp",
						"hash",
						"iconv",
						"imap",
						"intl",
						"json",
						"libxml",
						"mbstring",
						"mysqli",
						"openssl",
						"pcntl",
						"pcre",
						"PDO",
						"pdo_mysql",
						"pgsql",
						"Phar",
						"posix",
						"Reflection",
						"session",
						"SimpleXML",
						"soap",
						"sockets",
						"sodium",
						"SPL",
						"standard",
						"superglobals",
						"tokenizer",
						"xml",
						"xmlreader",
						"xmlwriter",
						"zip",
						"zlib",
						"redis",
						"apcu",
					},
				},
			},
		})
		vim.lsp.enable("intelephense")

		vim.lsp.config("cssls", {
			capabilities = capabilities,
			settings = {
				css = {
					validate = true,
					lint = {
						unknownAtRules = "ignore", -- Ignore for Tailwind @apply, @layer, etc.
					},
				},
				scss = {
					validate = true,
					lint = {
						unknownAtRules = "ignore",
					},
				},
				less = {
					validate = true,
				},
			},
		})
		vim.lsp.enable("cssls")

		vim.lsp.config("tailwindcss", {
			capabilities = capabilities,
			filetypes = {
				"html",
				"css",
				"scss",
				"javascript",
				"javascriptreact",
				"typescript",
				"typescriptreact",
			},
			settings = {
				tailwindCSS = {
					experimental = {
						classRegex = {
							-- Support for clsx, classnames, cn(), cva()
							{ "clsx\\(([^)]*)\\)", "(?:'|\"|`)([^']*)(?:'|\"|`)" },
							{ "cn\\(([^)]*)\\)", "(?:'|\"|`)([^']*)(?:'|\"|`)" },
							{ "cva\\(([^)]*)\\)", "[\"'`]([^\"'`]*).*?[\"'`]" },
							{ "className.*?=.*?[\"'`]([^\"'`]*)" },
						},
					},
				},
			},
			root_dir = function(bufnr, on_dir)
				local root = vim.fs.root(bufnr, { "tsconfig.json", "jsconfig.json" })
					or vim.fs.root(bufnr, "package.json")
					or vim.fs.root(bufnr, "node_modules")
				if root then
					on_dir(root)
				end
			end,
		})
		vim.lsp.enable("tailwindcss")

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
