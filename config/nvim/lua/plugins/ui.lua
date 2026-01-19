return {
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {
      bigfile = { enabled = false },
      dashboard = { enabled = false },
      explorer = { enabled = false },
      indent = { enabled = false },
      input = { enabled = false },
      notifier = { enabled = false },
      picker = { enabled = false },
      quickfile = { enabled = false },
      scope = { enabled = false },
      scroll = { enabled = false },
      statuscolumn = { enabled = false },
      words = { enabled = false },
    },
  },

  -- Explorer
  {
    "folke/snacks.nvim",
    ---@type snacks.Config
    opts = {
      explorer = { enabled = true },
      picker = {
        sources = {
          explorer = {
            hidden = true,
          },
        },
      },
    },
    keys = {
      {
        "<leader>e",
        function()
          Snacks.explorer.open()
        end,
        desc = "Open file explorer",
      },
    },
  },

  -- Notifications
  {
    "folke/snacks.nvim",
    ---@type snacks.Config
    opts = {
      notifier = { enabled = true },
    },
  },

  -- vim.ui.input and vim.ui.select I think?
  {
    "folke/snacks.nvim",
    ---@type snacks.Config
    opts = {
      input = { enabled = true },
      picker = { enabled = true },
    },
  },

  -- Indent
  {
    "folke/snacks.nvim",
    ---@type snacks.Config
    opts = {
      indent = {
        enabled = true,
        animate = { enabled = false },
      },
    },
  },
  {
    "j-hui/fidget.nvim",
    opts = {
      -- notification = {
      --   override_vim_notify = true,
      -- },
    },
  },
}
