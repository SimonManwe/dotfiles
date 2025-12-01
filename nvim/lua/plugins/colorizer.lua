-- Shows color previews inline for CSS, hex codes, etc.
return {
	"NvChad/nvim-colorizer.lua",
	event = { "BufReadPre", "BufNewFile" },
	opts = {
		filetypes = {
			"css",
			"scss",
			"sass",
			"html",
			"javascript",
			"javascriptreact",
			"typescript",
			"typescriptreact",
			"lua",
		},
		user_default_options = {
			RGB = true, -- #RGB hex codes
			RRGGBB = true, -- #RRGGBB hex codes
			names = true, -- "Name" codes like Blue
			RRGGBBAA = true, -- #RRGGBBAA hex codes
			rgb_fn = true, -- CSS rgb() and rgba() functions
			hsl_fn = true, -- CSS hsl() and hsla() functions
			css = true, -- Enable all CSS features
			css_fn = true, -- Enable all CSS *functions*: rgb_fn, hsl_fn
			mode = "background", -- Set the display mode
			tailwind = true, -- Enable tailwind colors
			sass = { enable = true, parsers = { "css" } }, -- Enable sass colors
			virtualtext = "■",
		},
	},
}
