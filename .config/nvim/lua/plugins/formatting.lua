return {
  "stevearc/conform.nvim",
  opts = {
    default_format_opts = { lsp_format = "fallback" },
    formatters_by_ft = {
      lua = { "stylua" },
      nix = { "nixfmt" },
      -- elixir = { "mix" },
      -- rust = { "rustfmt" },
      ["_"] = { "trim_whitespace", "trim_newlines", lsp_format = "prefer" },
    },
    format_on_save = {
      -- These options will be passed to conform.format()
      timeout_ms = 500,
    },
    -- format_after_save = {
    --   lsp_format = "fallback",
    -- },
  },
}
