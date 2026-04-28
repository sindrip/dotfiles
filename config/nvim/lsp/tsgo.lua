return {
  capabilities = {
    general = {
      -- Match vtsls/Copilot so attached TS clients agree on LSP offsets.
      positionEncodings = { "utf-16" },
    },
  },
  on_attach = function(client, bufnr)
    -- When opening a file from vtsls workspace diagnostics, pull once immediately.
    vim.schedule(function()
      if vim.api.nvim_buf_is_valid(bufnr) and vim.lsp.buf_is_attached(bufnr, client.id) then
        client:request("textDocument/diagnostic", {
          textDocument = vim.lsp.util.make_text_document_params(bufnr),
        }, nil, bufnr)
      end
    end)
  end,
}
