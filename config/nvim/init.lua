vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.o.number = true
vim.o.relativenumber = true
vim.o.signcolumn = "yes"
vim.o.pumborder = "rounded"
vim.o.clipboard = "unnamedplus"
vim.o.undofile = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.splitright = true
vim.o.splitbelow = true
vim.o.scrolloff = 8
vim.o.updatetime = 250
vim.o.termguicolors = true
vim.o.cursorline = true
vim.o.expandtab = true
vim.o.shiftwidth = 2
vim.o.tabstop = 2
vim.o.foldlevelstart = 99
vim.o.foldcolumn = "auto:1"
vim.o.foldtext = ""
vim.o.foldnestmax = 1
vim.o.fillchars = "fold: ,foldopen:⌵,foldclose:›,foldsep: ,foldinner: "

-- Build hooks (must be defined BEFORE vim.pack.add)

vim.api.nvim_create_autocmd("PackChanged", {
  callback = function(ev)
    if ev.data.spec.name == "nvim-treesitter" and ev.data.kind == "update" then
      if not ev.data.active then
        vim.cmd.packadd("nvim-treesitter")
      end
      vim.cmd("TSUpdate")
    end
  end,
})

-- Plugins

vim.pack.add({
  "https://github.com/catppuccin/nvim",
  "https://github.com/folke/which-key.nvim",
  "https://github.com/nvim-treesitter/nvim-treesitter",
})

-- Colorscheme

vim.cmd.colorscheme("catppuccin-frappe")

-- Treesitter

local ok, ts = pcall(require, "nvim-treesitter")
if ok then
  ts.install({ "typescript", "tsx", "javascript", "rust" })
end

vim.api.nvim_create_autocmd("FileType", {
  callback = function()
    if pcall(vim.treesitter.start) then
      vim.wo[0][0].foldmethod = "expr"
      vim.wo[0][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
    end
  end,
})

-- Keymaps

vim.keymap.set("n", "<leader>r", function()
  local session = vim.fn.stdpath("state") .. "/restart.vim"
  vim.cmd.mksession({ args = { session }, bang = true })
  vim.cmd.restart({ args = { "source", session } })
end, { desc = "Restart nvim with session" })
