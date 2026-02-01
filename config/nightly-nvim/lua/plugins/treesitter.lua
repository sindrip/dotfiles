return {
    "nvim-treesitter/nvim-treesitter",
    lazy = false,
    build = ":TSUpdate",
    config = function()
        require("nvim-treesitter").install({
            "typescript",
            "lua"
        })

        vim.opt.sessionoptions:remove("folds")
        vim.api.nvim_create_autocmd("FileType", {
            group = vim.api.nvim_create_augroup("sindrip/treesitter", { clear = true }),
            pattern = "*",
            desc = "Start TreeSitter",
            callback = function(args)
                local ft = args.match
                local lang = vim.treesitter.language.get_lang(ft)
                if lang and vim.treesitter.language.add(lang) then
                    vim.treesitter.start()

                    vim.wo[0][0].foldmethod = "expr"
                    vim.wo[0][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"

                    vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
                end
            end,
        })
    end,
}
