return {
  {
    "neovim/nvim-lspconfig",
    config = function()
      -- local capabilities = require("blink.cmp").get_lsp_capabilities()

      -- local on_attach = function(_, bufnr)
      --   -- Enable completion triggered by <c-x><c-o>
      --   --vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")
      --
      --   -- Mappings.
      --   -- See `:help vim.lsp.*` for documentation on any of the below functions
      --   local bufopts = { noremap = true, silent = true, buffer = bufnr }
      --   --vim.keymap.set("n", "gD", vim.lsp.buf.declaration, bufopts)
      --   vim.keymap.set("n", "gd", vim.lsp.buf.definition, bufopts)
      --   vim.keymap.set("n", "K", vim.lsp.buf.hover, bufopts)
      --   --vim.keymap.set("n", "gi", vim.lsp.buf.implementation, bufopts)
      --   vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, bufopts)
      --   --vim.keymap.set("n", "<space>wa", vim.lsp.buf.add_workspace_folder, bufopts)
      --   --vim.keymap.set("n", "<space>wr", vim.lsp.buf.remove_workspace_folder, bufopts)
      --   --vim.keymap.set("n", "<space>wl", function()
      --   --  print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
      --   --end, bufopts)
      --   --vim.keymap.set("n", "<space>D", vim.lsp.buf.type_definition, bufopts)
      --   vim.keymap.set("n", "<space>rn", vim.lsp.buf.rename, bufopts)
      --   vim.keymap.set("n", "<space>ca", vim.lsp.buf.code_action, bufopts)
      --   --vim.keymap.set("n", "gr", vim.lsp.buf.references, bufopts)
      --   --vim.keymap.set("n", "<space>f", vim.lsp.buf.formatting, bufopts)
      --
      --   vim.lsp.completion.enable(true, client.id, bufnr, {
      --     autotrigger = true,
      --     convert = function(item)
      --       return { abbr = item.label:gsub("%b()", "") }
      --     end,
      --   })
      -- end

      vim.lsp.config("elixirls", {
        -- Unix
        cmd = { "elixir-ls" },
      })

      vim.lsp.config("lua_ls", {
        on_init = function(client)
          if client.workspace_folders then
            local path = client.workspace_folders[1].name
            if
              path ~= vim.fn.stdpath "config"
              and (
                vim.uv.fs_stat(path .. "/.luarc.json")
                or vim.uv.fs_stat(path .. "/.luarc.jsonc")
              )
            then
              return
            end
          end

          client.config.settings.Lua =
            vim.tbl_deep_extend("force", client.config.settings.Lua, {
              runtime = {
                -- Tell the language server which version of Lua you're using (most
                -- likely LuaJIT in the case of Neovim)
                version = "LuaJIT",
                -- Tell the language server how to find Lua modules same way as Neovim
                -- (see `:h lua-module-load`)
                path = {
                  "lua/?.lua",
                  "lua/?/init.lua",
                },
              },
              -- Make the server aware of Neovim runtime files
              workspace = {
                checkThirdParty = false,
                library = {
                  vim.env.VIMRUNTIME,
                  -- Depending on the usage, you might want to add additional paths
                  -- here.
                  "${3rd}/luv/library",
                  -- '${3rd}/busted/library'
                },
                -- Or pull in all of 'runtimepath'.
                -- NOTE: this is a lot slower and will cause issues when working on
                -- your own configuration.
                -- See https://github.com/neovim/nvim-lspconfig/issues/3189
                -- library = {
                --   vim.api.nvim_get_runtime_file('', true),
                -- }
              },
            })
        end,
        settings = {
          Lua = {},
        },
      })

      vim.lsp.enable { "elixirls", "rust_analyzer", "nixd", "lua_ls" }

      -- require("lspconfig").lua_ls.setup {
      --   on_attach = on_attach,
      --   capabilities = capabilities,
      --   settings = {
      --     Lua = {
      --       runtime = {
      --         version = "LuaJIT",
      --       },
      --       diagnostics = {
      --         disable = { "missings-fields" },
      --       },
      --       workspace = {
      --         checkThirdParty = false,
      --         library = {
      --           vim.env.VIMRUNTIME,
      --           "${3rd}/luv/library",
      --         },
      --       },
      --       telemetry = {
      --         enable = false,
      --       },
      --     },
      --   },
      -- }
    end,
  },
}
