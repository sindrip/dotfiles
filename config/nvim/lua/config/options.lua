vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- vim.opt.softtabstop = -1
-- Options
vim.o.swapfile = false
vim.o.autoread = true
vim.o.number = true
vim.o.relativenumber = true
vim.o.scrolloff = 8
vim.o.sidescrolloff = 8
vim.o.cursorline = true
vim.o.splitbelow = true
vim.o.splitright = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.shiftwidth = 2
vim.o.shiftround = true
vim.o.expandtab = true
vim.o.tabstop = 2
vim.o.smartindent = true
vim.o.undofile = true
-- vim.o.undolevels = 10000
-- vim.opt.signcolumn = "number"
vim.o.signcolumn = "yes"
vim.o.laststatus = 3
vim.o.list = true
vim.opt.listchars = {
  tab = "→ ",
  nbsp = "␣",
  trail = "·",
  -- space = "·",
  extends = "⟩",
  precedes = "⟨",
}
-- vim.opt.completeopt = { "menu", "menuone", "noinsert", "noselect" }
vim.opt.completeopt = { "menu", "menuone", "noselect" }

vim.o.wrap = false

vim.o.inccommand = "split" -- Preview off-screen substitution

vim.diagnostic.config({
  virtual_text = true,
  -- virtual_lines = {
  --   current_line = false
  -- }
})
