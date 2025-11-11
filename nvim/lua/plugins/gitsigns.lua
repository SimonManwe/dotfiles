return {
  "lewis6991/gitsigns.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  event = "BufReadPre",  -- lazy-load when a file is read
  config = function()
    require("gitsigns").setup({
      signs = {
	      add = { text = '' },
	      change = { text = '' },
	      delete = { text = '' },
	      topdelete = { text = '󰐊' },
	      changedelete = { text = '󱂇' },
      },
      current_line_blame = true,  -- show git blame on the current line
      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns
        local map = function(mode, l, r, opts)
          opts = opts or {}
          opts.buffer = bufnr
          vim.keymap.set(mode, l, r, opts)
        end

        -- Navigation
        map("n", "]h", gs.next_hunk, { desc = "Next Git hunk" })
        map("n", "[h", gs.prev_hunk, { desc = "Previous Git hunk" })

        -- Actions
        map({ "n", "v" }, "<leader>hs", ":Gitsigns stage_hunk<CR>", { desc = "Stage hunk" })
        map({ "n", "v" }, "<leader>hr", ":Gitsigns reset_hunk<CR>", { desc = "Reset hunk" })
        map("n", "<leader>hS", gs.stage_buffer, { desc = "Stage buffer" })
        map("n", "<leader>hu", gs.undo_stage_hunk, { desc = "Undo stage hunk" })
        map("n", "<leader>hR", gs.reset_buffer, { desc = "Reset buffer" })
        map("n", "<leader>hp", gs.preview_hunk, { desc = "Preview hunk" })
        map("n", "<leader>hb", function() gs.blame_line({ full = true }) end, { desc = "Blame line" })
        map("n", "<leader>tb", gs.toggle_current_line_blame, { desc = "Toggle line blame" })
        map("n", "<leader>hd", gs.diffthis, { desc = "Diff this file" })
      end,
    })
  end,
}

