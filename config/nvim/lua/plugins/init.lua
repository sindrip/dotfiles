return {
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local builtin = require("telescope.builtin")
      vim.keymap.set("n", "<leader>ff",
        function() builtin.find_files({ hidden = true, file_ignore_patterns = { "^%.git/", "^node_modules" } }) end,
        { desc = "Find files" }
      )
      vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Find grep" })
      vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Find help" })
      vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Find buffers" })
      vim.keymap.set("n", "<leader>fd", builtin.diagnostics, { desc = "Find diagnostics" })
      -- Move this to UI later?
      vim.keymap.set("n", "<leader>fc", builtin.colorscheme, { desc = "Find colorscheme" })
    end,
  },
  {
    "folke/which-key.nvim",
    opts_extend = { "spec" },
    opts = {
      spec = {
        { "<leader>f", group = "+find" },
      },
    },
  },
  {
    enabled = false,
    "github/copilot.vim"
  },
}
