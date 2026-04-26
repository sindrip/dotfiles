-- Format-on-save via conform.

local M = {}

M.enabled = true

function M.toggle()
  M.enabled = not M.enabled
  vim.notify("Auto format: " .. (M.enabled and "on" or "off"))
end

function M.setup()
  local web = { "biome_strict", "prettier_strict", "biome", "prettier", stop_after_first = true }

  require("conform").setup({
    formatters = {
      biome_strict = { inherit = "biome", require_cwd = true },
      prettier_strict = { inherit = "prettier", require_cwd = true },
    },

    formatters_by_ft = {
      javascript = web,
      javascriptreact = web,
      typescript = web,
      typescriptreact = web,
      json = web,
      jsonc = web,
      css = web,
      html = web,
      graphql = web,
      markdown = { "prettier_strict", "prettier", stop_after_first = true },
      lua = { "stylua" },
      sh = { "shfmt" },
      bash = { "shfmt" },
      go = { name = "gopls", lsp_format = "prefer" },
      rust = { name = "rust_analyzer", lsp_format = "prefer" },
      ["_"] = { "trim_whitespace", "trim_newlines" },
    },

    format_on_save = function()
      if not M.enabled then
        return
      end

      return { timeout_ms = 500 }
    end,
  })
end

return M
