-- vtsls is a diagnostics sidecar for tsgo.
-- tsgo owns open-buffer TypeScript LSP features; vtsls only keeps project-wide
-- diagnostics for unopened workspace files.

local function loaded_bufnr_from_uri(uri)
  local bufnr = vim.uri_to_bufnr(uri)
  if vim.api.nvim_buf_is_loaded(bufnr) then
    return bufnr
  end
end

local function is_dependency_uri(uri)
  return vim.fs.normalize(vim.uri_to_fname(uri)):find("/node_modules/", 1, true) ~= nil
end

return {
  handlers = {
    ["textDocument/publishDiagnostics"] = function(err, params, ctx)
      -- Project diagnostics can include dependency files; keep quickfix focused.
      if is_dependency_uri(params.uri) then
        return
      end

      local bufnr = loaded_bufnr_from_uri(params.uri)
      if bufnr then
        return
      end

      vim.lsp.diagnostic.on_publish_diagnostics(err, params, ctx)
    end,
  },
  on_attach = function(client, bufnr)
    -- Open buffers get diagnostics from tsgo; clear any stale vtsls entries.
    vim.diagnostic.reset(vim.lsp.diagnostic.get_namespace(client.id), bufnr)
    -- Keep text sync for project diagnostics, but do not route editor features here.
    client.server_capabilities = {
      textDocumentSync = client.server_capabilities.textDocumentSync,
    }
  end,
  settings = {
    typescript = {
      tsserver = {
        experimental = { enableProjectDiagnostics = true },
      },
    },
    javascript = {
      tsserver = {
        experimental = { enableProjectDiagnostics = true },
      },
    },
  },
}
