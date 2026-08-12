-- Temporary local config until nvim-lspconfig#4493 lands.
---@type vim.lsp.Config
return {
  cmd = { "tsc", "--lsp", "--stdio" },
  filetypes = {
    "javascript",
    "javascriptreact",
    "typescript",
    "typescriptreact",
  },
  -- TS7 currently registers an ancestor-wide **/* watcher that exhausts
  -- Neovim's per-directory kqueue watchers on macOS.
  capabilities = {
    workspace = {
      didChangeWatchedFiles = {
        dynamicRegistration = false,
      },
    },
  },
  settings = {
    typescript = {
      inlayHints = {
        parameterNames = {
          enabled = "literals",
          suppressWhenArgumentMatchesName = true,
        },
        parameterTypes = { enabled = true },
        variableTypes = { enabled = true },
        propertyDeclarationTypes = { enabled = true },
        functionLikeReturnTypes = { enabled = true },
        enumMemberValues = { enabled = true },
      },
    },
  },
  root_dir = function(bufnr, on_dir)
    local lockfiles = { "package-lock.json", "yarn.lock", "pnpm-lock.yaml", "bun.lockb", "bun.lock" }
    local project_root = vim.fs.root(bufnr, { lockfiles, { ".git" } })
    local deno_root = vim.fs.root(bufnr, { "deno.json", "deno.jsonc" })
    local deno_lock_root = vim.fs.root(bufnr, { "deno.lock" })

    if deno_lock_root and (not project_root or #deno_lock_root > #project_root) then
      return
    end
    if deno_root and (not project_root or #deno_root >= #project_root) then
      return
    end

    on_dir(project_root or vim.fn.getcwd())
  end,
}
