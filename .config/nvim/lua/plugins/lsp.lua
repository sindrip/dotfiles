return {
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
    },
    config = function()
      require("mason").setup()
      require("mason-lspconfig").setup {
        automatic_installation = true,
      }

      local capabilities = require("blink.cmp").get_lsp_capabilities()

      local on_attach = function(_, bufnr)
        -- Enable completion triggered by <c-x><c-o>
        --vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")

        -- Mappings.
        -- See `:help vim.lsp.*` for documentation on any of the below functions
        local bufopts = { noremap = true, silent = true, buffer = bufnr }
        --vim.keymap.set("n", "gD", vim.lsp.buf.declaration, bufopts)
        vim.keymap.set("n", "gd", vim.lsp.buf.definition, bufopts)
        vim.keymap.set("n", "K", vim.lsp.buf.hover, bufopts)
        --vim.keymap.set("n", "gi", vim.lsp.buf.implementation, bufopts)
        vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, bufopts)
        --vim.keymap.set("n", "<space>wa", vim.lsp.buf.add_workspace_folder, bufopts)
        --vim.keymap.set("n", "<space>wr", vim.lsp.buf.remove_workspace_folder, bufopts)
        --vim.keymap.set("n", "<space>wl", function()
        --  print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
        --end, bufopts)
        --vim.keymap.set("n", "<space>D", vim.lsp.buf.type_definition, bufopts)
        vim.keymap.set("n", "<space>rn", vim.lsp.buf.rename, bufopts)
        vim.keymap.set("n", "<space>ca", vim.lsp.buf.code_action, bufopts)
        --vim.keymap.set("n", "gr", vim.lsp.buf.references, bufopts)
        --vim.keymap.set("n", "<space>f", vim.lsp.buf.formatting, bufopts)
      end

      require("lspconfig").rust_analyzer.setup {
        on_attach = on_attach,
        capabilities = capabilities,
      }
      require("lspconfig").elixirls.setup {
        on_attach = on_attach,
        capabilities = capabilities,
      }

      require("lspconfig").lua_ls.setup {
        on_attach = on_attach,
        capabilities = capabilities,
        settings = {
          Lua = {
            runtime = {
              version = "LuaJIT",
            },
            diagnostics = {
              disable = { "missings-fields" },
            },
            workspace = {
              checkThirdParty = false,
              library = {
                vim.env.VIMRUNTIME,
                "${3rd}/luv/library",
              },
            },
            telemetry = {
              enable = false,
            },
          },
        },
      }
    end,
  },
}
