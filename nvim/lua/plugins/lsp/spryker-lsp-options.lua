return {
	{
		"neovim/nvim-lspconfig",
		opts = function(_, opts)
			-- Ensure Intelephense knows about Spryker's generated files
			if not opts.servers then
				opts.servers = {}
			end
			if not opts.servers.intelephense then
				opts.servers.intelephense = {}
			end

			-- Intelephense configuration for Spryker
			opts.servers.intelephense = vim.tbl_deep_extend("force", opts.servers.intelephense or {}, {
				settings = {
					intelephense = {
						stubs = {
							"apache",
							"bcmath",
							"Core",
							"curl",
							"date",
							"dom",
							"fileinfo",
							"filter",
							"ftp",
							"gd",
							"gettext",
							"hash",
							"iconv",
							"intl",
							"json",
							"libxml",
							"mbstring",
							"mysqli",
							"mysqlnd",
							"openssl",
							"pcntl",
							"pcre",
							"PDO",
							"pdo_mysql",
							"Phar",
							"readline",
							"redis",
							"Reflection",
							"session",
							"SimpleXML",
							"sockets",
							"sodium",
							"SPL",
							"standard",
							"tokenizer",
							"xml",
							"xdebug",
							"xmlreader",
							"xmlwriter",
							"yaml",
							"zip",
							"zlib",
						},
						files = {
							maxSize = 5000000,
							-- Include Spryker's IDE helper files
							associations = { "*.php" },
						},
						environment = {
							includePaths = {
								"vendor/spryker",
								"src/Generated",
							},
						},
						-- Force reindex on file changes
						diagnostics = {
							enable = true,
						},
					},
				},
			})

			return opts
		end,
	},
}
