vim.pack.add({
    { src = "https://github.com/nvim-treesitter/nvim-treesitter" },
})

require("nvim-treesitter").install({
    'lua',
    'typescript',
})

-- Consider moving this to a more appropriate place, or not using it at all.
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

            vim.wo.foldmethod = "expr"
            vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"

            vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end
    end,
})
