return {
  "mbbill/undotree",
  lazy = true,          -- enable lazy-loading
  keys = {
    {
      "<leader>u",
      function()
        vim.cmd("UndotreeToggle")
      end,
      desc = "Toggle Undotree",
    },
  },
  config = function()
    -- optional settings
    vim.g.undotree_WindowLayout = 2  -- vertical split
    vim.g.undotree_SplitWidth = 30
  end,
}

