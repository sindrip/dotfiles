require("config.lazy")

-- vim.opt.softtabstop = -1
-- Options
vim.o.swapfile = false
vim.o.autoread = true
vim.o.number = true
vim.o.relativenumber = true
vim.o.scrolloff = 3
vim.o.sidescrolloff = 5
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

-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
  group = vim.api.nvim_create_augroup("highlight_yank", { clear = true }),
  pattern = "*",
  desc = "highlight selection on yank",
  callback = function()
    vim.hl.on_yank({ timeout = 200 })
  end,
})

-- open help in vertical split
vim.api.nvim_create_autocmd("BufWinEnter", {
  group = vim.api.nvim_create_augroup("help_vertical", { clear = true }),
  callback = function()
    if vim.bo.buftype == "help" then
      vim.cmd.wincmd("L")
    end
  end,
})

-- LSP
vim.lsp.enable("bashls")
vim.lsp.enable("lua_ls")

vim.diagnostic.config({
  virtual_text = true,
  -- virtual_lines = {
  --         current_line = false
  -- }
})

-- Setup plugins
require("lazy").setup({
  spec = {
    { import = "plugins" },
    {
      "catppuccin/nvim",
      name = "catppuccin",
      priority = 1000,
      config = function()
        require("catppuccin").setup({
          flavour = "frappe", -- latte, frappe, macchiato, mocha
          transparent_background = false,
        })
        vim.cmd.colorscheme("catppuccin")
      end,
    },

    {
      "nvim-telescope/telescope.nvim",
      dependencies = { "nvim-lua/plenary.nvim" },
      config = function()
        local builtin = require("telescope.builtin")
        vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find files" })
        vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Find grep" })
        vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Find help" })
      end,
    },
    {
      "nvim-treesitter/nvim-treesitter",
      lazy = false,
      build = ":TSUpdate",
    },
    { "neovim/nvim-lspconfig" },
    { "folke/which-key.nvim" },
    { "github/copilot.vim" },

    {
      "saghen/blink.cmp",
      dependencies = {},

      -- use a release tag to download pre-built binaries
      version = "1.*",

      ---@module 'blink.cmp'
      ---@type blink.cmp.Config
      opts = {
        -- 'default' (recommended) for mappings similar to built-in completions (C-y to accept)
        -- 'super-tab' for mappings similar to vscode (tab to accept)
        -- 'enter' for enter to accept
        -- 'none' for no mappings
        -- All presets have the following mappings:
        -- C-space: Open menu or open docs if already open
        -- C-n/C-p or Up/Down: Select next/previous item
        -- C-e: Hide menu
        -- C-k: Toggle signature help (if signature.enabled = true)
        --
        -- See :h blink-cmp-config-keymap for defining your own keymap
        keymap = { preset = "default" },
        appearance = {
          nerd_font_variant = "mono",
        },
        completion = { documentation = { auto_show = true } },
        sources = {
          default = { "lsp", "path", "snippets", "buffer" },
        },
        fuzzy = { implementation = "prefer_rust_with_warning" },
      },
      opts_extend = { "sources.default" },
    },

    ---------------------------------------------
    -- UI
    {
      "folke/snacks.nvim",
      priority = 1000,
      lazy = false,
      ---@type snacks.Config
      opts = {
        -- bigfile = { enabled = true },
        -- dashboard = { enabled = true },
        -- explorer = { enabled = true },
        indent = { enabled = true },
        -- input = { enabled = true },
        picker = { enabled = true },
        notifier = { enabled = true },
        -- quickfile = { enabled = true },
        -- scope = { enabled = true },
        -- scroll = { enabled = true },
        -- statuscolumn = { enabled = true },
        -- words = { enabled = true },
      },
    },

    -- {
    -- enabled = false,
    --   "folke/noice.nvim",
    -- },
    --
  },
})

-- Keymaps
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "<C-d>", "<C-d>zz")
