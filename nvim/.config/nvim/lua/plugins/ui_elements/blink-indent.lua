return {
	"saghen/blink.indent",
	--- @module 'blink.indent'
	--- @type blink.indent.Config
	opts = {
		blocked = {
			filetypes = {
				include_defaults = true,
			},
		},
		static = {
			char = "▏",
			highlights = { "BlinkIndent" },
		},
		scope = {
			char = "▏",
			highlights = { "BlinkIndentViolet" },
		},
	},
}
