return {
  {
    "m4xshen/autoclose.nvim",
    event = "InsertEnter",  -- Load when entering insert mode
    opts = {
      keys = {
        ["("] = { close = true, escape = true, pair = "()" },
        ["["] = { close = true, escape = true, pair = "[]" },
        ["{"] = { close = true, escape = true, pair = "{}" },
        ["<"] = { close = true, escape = true, pair = "<>" },
        ["'"] = { close = true, escape = true, pair = "''" },
        ['"'] = { close = true, escape = true, pair = '""' },
      },
    },
  },
}

