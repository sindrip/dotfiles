return {
  "stevearc/conform.nvim",
  opts = {
    formatters_by_ft = {
      lua = { "stylua" },
      nix = { "nixfmt" },
      elixir = { "mix" },
      ["*"] = { "trim_whitespace", "trim_newlines" },
    },
    format_after_save = {
      lsp_format = "fallback",
    },
  },
}
