return {
  {
    "fcancelinha/nordern.nvim",
    -- "shaunsingh/nord.nvim",
    branch = "master",
    config = function()
      vim.cmd.colorscheme "nordern"
    end,
  },
  {
    "alexxGmZ/e-ink.nvim",
    priority = 1000,
    config = function()
      require("e-ink").setup()
      -- vim.cmd.colorscheme "e-ink"

      -- choose light mode or dark mode
      -- vim.opt.background = "dark"
      -- vim.opt.background = "light"
      --
      -- or do
      -- :set background=dark
      -- :set background=light
    end,
  },
  {
    "lewis6991/gitsigns.nvim",
    opts = {},
  },
  {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.8",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    config = function()
      local builtin = require "telescope.builtin"
      vim.keymap.set("n", "<leader>ff", builtin.find_files, { noremap = true })
      vim.keymap.set("n", "<leader>fg", builtin.live_grep, { noremap = true })
      vim.keymap.set("n", "<leader>fb", builtin.buffers, { noremap = true })
      vim.keymap.set("n", "<leader>fh", builtin.help_tags, { noremap = true })
    end,
  },
}
