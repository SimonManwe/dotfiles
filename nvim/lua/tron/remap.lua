vim.g.mapleader = " "
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)

-- GitHub Copilot Keybindings
vim.keymap.set("n", "<leader>cp", ":Copilot panel<CR>", { desc = "Copilot Panel" })
vim.keymap.set("n", "<leader>ce", ":Copilot enable<CR>", { desc = "Copilot Enable" })
vim.keymap.set("n", "<leader>cd", ":Copilot disable<CR>", { desc = "Copilot Disable" })
vim.keymap.set("n", "<leader>cs", ":Copilot status<CR>", { desc = "Copilot Status" })

