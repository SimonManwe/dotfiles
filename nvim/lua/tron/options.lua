vim.opt.number = true -- Shows absolute line number on current line
vim.opt.relativenumber = true -- Shows relative numbers for other lines
vim.o.autoindent = true
vim.o.expandtab = false
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.o.autoread = true
vim.o.autowrite = true
vim.o.autowriteall = true
vim.opt.updatetime = 250 -- Make this faster (default is 4000)
vim.opt.clipboard = "unnamedplus" -- Use system clipboard
vim.opt.ignorecase = true -- Case insensitive search
vim.opt.smartcase = true -- ...unless uppercase used
vim.opt.undofile = true -- Persistent undo history
vim.opt.signcolumn = "yes" -- Always show sign column (no jumping)
vim.opt.splitright = true -- Open vertical splits right
vim.opt.splitbelow = true -- Open horizontal splits below
vim.opt.termguicolors = true -- True color support
-- Scrolloffset
vim.opt.scrolloff = 4
vim.opt.sidescrolloff = 6

-- Folding (nvim-ufo)
vim.opt.foldcolumn = "1"
vim.opt.foldlevel = 99
vim.opt.foldlevelstart = 99
vim.opt.foldenable = true
vim.opt.foldopen:remove("hor") -- Don't open folds when moving horizontally
vim.o.fillchars = "eob: ,fold: ,foldopen:,foldsep: ,foldinner: ,foldclose:"
