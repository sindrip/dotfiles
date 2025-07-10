-- Basic Settings
vim.g.mapleader = " "

vim.opt.relativenumber = true
vim.opt.number = true
vim.opt.list = true
vim.opt.listchars = {
  tab = "→ ",
  nbsp = "␣",
  trail = "·",
  space = "·",
  extends = "⟩",
  precedes = "⟨",
}
vim.opt.scrolloff = 3
vim.opt.sidescrolloff = 5
vim.opt.cursorline = true
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.shiftwidth = 2
vim.opt.softtabstop = -1
vim.opt.shiftround = true
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.hidden = true
vim.opt.swapfile = false
vim.opt.undofile = true
vim.opt.signcolumn = "number"
vim.opt.completeopt = { "menu", "menuone", "noinsert", "noselect" }
-- Consider
-- vim.opt.laststatus = 3
vim.g.netrw_winsize = 20
vim.g.netrw_liststyle = 3
vim.g.netrw_browse_split = 4

require "config.lazy"

-- vim.lsp.enable { "elixirls", "rust_analyzer", "nixd", "lua_ls" }
vim.lsp.enable { "lexical", "rust_analyzer", "nixd", "lua_ls" }

-- Diagnostic
vim.diagnostic.config {
  jump = { float = true },
}

vim.keymap.set(
  "n",
  "<leader>q",
  vim.diagnostic.setloclist,
  { noremap = true, silent = true }
)
