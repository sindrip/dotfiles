-- vtsls is a diagnostics sidecar for tsgo.
-- tsgo owns open-buffer TypeScript LSP features; vtsls only keeps project-wide
-- diagnostics for unopened workspace files.

local function loaded_bufnr_from_uri(uri)
  local bufnr = vim.uri_to_bufnr(uri)
  if vim.api.nvim_buf_is_loaded(bufnr) then
    return bufnr
  end
end

local dependency_path_fragments = {
  "/node_modules/", -- npm, pnpm (under node_modules/.pnpm/), bun (default + isolated)
  "/.yarn/", -- yarn berry / PnP (cache/, unplugged/, __virtual__/)
}

local function is_dependency_uri(uri)
  local path = vim.fs.normalize(vim.uri_to_fname(uri))
  for _, fragment in ipairs(dependency_path_fragments) do
    if path:find(fragment, 1, true) then
      return true
    end
  end
  return false
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
        -- Covers :bunload -> vtsls publish -> reload, where on_attach does not re-run.
        vim.diagnostic.reset(vim.lsp.diagnostic.get_namespace(ctx.client_id), bufnr)
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
