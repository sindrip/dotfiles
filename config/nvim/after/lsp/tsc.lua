-- TS7 currently registers an ancestor-wide **/* watcher that exhausts
-- Neovim's per-directory kqueue watchers on macOS.
---@type vim.lsp.Config
return {
  capabilities = {
    workspace = {
      didChangeWatchedFiles = {
        dynamicRegistration = false,
      },
    },
  },
  -- nvim-lspconfig's tsc config prefers the workspace-local
  -- node_modules/.bin/tsc unconditionally, but `tsc --lsp` only exists in
  -- TypeScript 7+ (the native tsgo port). In projects pinned to an older
  -- TypeScript the local binary rejects the flag and the client dies at
  -- spawn with exit code 1. Version-gate each candidate and fall back to
  -- the global TS7 (typescript-go via nix) when the local one is too old.
  cmd = function(dispatchers, config)
    local function major_version(bin)
      local res = vim.system({ bin, "--version" }):wait()
      return tonumber((res.stdout or ""):match("Version (%d+)")) or 0
    end

    local candidates = {}
    if config and config.root_dir then
      table.insert(candidates, vim.fs.joinpath(config.root_dir, "node_modules/.bin/tsc"))
      table.insert(candidates, vim.fs.joinpath(config.root_dir, "node_modules/.bin/tsgo"))
    end
    vim.list_extend(candidates, { "tsc", "tsgo" })

    local cmd = "tsc"
    for _, bin in ipairs(candidates) do
      if vim.fn.executable(bin) == 1 and major_version(bin) >= 7 then
        cmd = bin
        break
      end
    end

    return vim.lsp.rpc.start({ cmd, "--lsp", "--stdio" }, dispatchers)
  end,
}
