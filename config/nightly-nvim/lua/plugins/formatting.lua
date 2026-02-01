return {
    "stevearc/conform.nvim",
    opts = {
        -- default_format_opts = { lsp_format = "fallback" },
        formatters_by_ft = {
            javascript = { "prettier" },
            javascriptreact = { "prettier" },
            typescript = { "prettier" },
            typescriptreact = { "prettier" },
            json = { "prettier" },
            lua = { "stylua", lsp_format = "fallback" },
            rust = { "rustfmt", lsp_format = "prefer" },
            -- ["_"] = { "trim_whitespace", "trim_newlines", lsp_format = "fallback" },
        },
        format_on_save = function()
            if not vim.g.auto_format then
                return nil
            end

            return {}
        end,
    },
    init = function()
        -- Use conform for gq.
        vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"

        -- Start auto-formatting by default (and disable with my ToggleFormat command).
        vim.g.auto_format = true
    end,
}
