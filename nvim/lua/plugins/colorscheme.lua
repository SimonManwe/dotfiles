return {
  "catppuccin/nvim",
  name = "catppuccin",
  priority = 1000,
  config = function()
    require("catppuccin").setup({
      flavour = "macchiato", -- latte, frappe, macchiato, mocha
      transparent_background = true,
      term_colors = true,
      integrations = {
        treesitter = true,
        telescope = true,
        nvimtree = true,
        cmp = true,
      }
    })
    vim.cmd.colorscheme("catppuccin")
  end
}

