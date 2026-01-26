vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Search options
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.inccommand = "split"

-- Indentation
vim.o.shiftwidth = 4
vim.o.tabstop = 4
vim.o.expandtab = true

-- Can't live without this
vim.o.undofile = true

vim.o.number = true
vim.o.relativenumber = true
vim.o.signcolumn = "yes"
vim.o.cursorline = true
vim.o.list = true
vim.opt.listchars = {
    tab = "→ ",
    nbsp = "␣",
    trail = "·",
    -- space = "·",
    extends = "⟩",
    precedes = "⟨",
}
vim.o.wrap = false

-- Splits
-- vim.o.splitkeep = 'screen'
vim.o.splitbelow = true
vim.o.splitright = true

-- Status line
vim.o.laststatus = 3
vim.o.cmdheight = 1

vim.o.scrolloff = 8
vim.o.sidescrolloff = 5

vim.opt.completeopt = { "menu", "menuone", "noselect" }

vim.o.winborder = "rounded"

-- Folds
-- vim.o.foldcolumn = "1"
vim.o.foldlevel = 99
vim.o.foldnestmax = 1

vim.pack.add({
    { src = "https://github.com/fcancelinha/nordern.nvim" },
    { src = "https://github.com/rmehri01/onenord.nvim" },
    { src = "https://github.com/AlexvZyl/nordic.nvim" },
    { src = "https://github.com/folke/tokyonight.nvim" },
    { src = "https://github.com/ellisonleao/gruvbox.nvim" },
})
vim.cmd.colorscheme("gruvbox")

-- Disable health checks for these providers
vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_python3_provider = 0

vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Scroll up and center" })
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Scroll down and center" })
vim.keymap.set("n", "n", "nzzzv", { desc = "Next search result and center" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Previous search result and center" })
vim.keymap.set("n", "<esc>", "<cmd>nohlsearch<cr>", { desc = "Clear search highlight" })

vim.api.nvim_create_user_command("RestartSession", function()
    local session = vim.fn.stdpath("state") .. "/Session.vim"
    vim.cmd.mksession({ args = { session }, bang = true })
    vim.cmd.restart({ args = { "source", session } })
end, { desc = "Reload Neovim", bang = true })

vim.keymap.set("n", "<leader>r", "<cmd>RestartSession<CR>")

vim.keymap.set("n", "<leader>x", "<cmd>.lua<CR>", { desc = "Execute the current line" })
-- vim.keymap.set("n", "<leader><leader>x", "<cmd>source %<CR>", { desc = "Execute the current file" })

-- UI related autocommands
local cursorline_group = vim.api.nvim_create_augroup("sindrip/cursorline", { clear = true })
vim.api.nvim_create_autocmd("WinEnter", {
    group = cursorline_group,
    desc = "Enable cursorline in active window",
    callback = function()
        vim.wo.cursorline = true
    end
})
vim.api.nvim_create_autocmd("WinLeave", {
    group = cursorline_group,
    desc = "Disable cursorline when leaving",
    callback = function()
        vim.wo.cursorline = false
    end
})

vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("sindrip/auto_comments", { clear = true }),
    callback = function()
        vim.opt.formatoptions:remove({ "c", "r", "o" })
    end,
})

vim.api.nvim_create_autocmd("TextYankPost", {
    group = vim.api.nvim_create_augroup("sindrip/highlight_yank", { clear = true }),
    pattern = "*",
    desc = "highlight selection on yank",
    callback = function()
        vim.hl.on_yank({ timeout = 200 })
    end,
})

vim.pack.add({
    { src = "https://github.com/nvim-telescope/telescope.nvim" },
    { src = "https://github.com/nvim-lua/plenary.nvim" },
})
local builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader>ff", function()
    builtin.find_files({ hidden = true, file_ignore_patterns = { ".git" } })
end, { desc = "Telescope find files" })
vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Telescope live grep" })
vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Telescope buffers" })
vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Telescope help tags" })

vim.pack.add({
    { src = "https://github.com/mason-org/mason.nvim" },
    { src = "https://github.com/folke/sidekick.nvim" },
})

require("mason").setup({})
vim.lsp.enable({
    "copilot",
    "lua_ls",
    "rust_analyzer",
    "vtsls",
})
require("sidekick").setup({})

-- vim.lsp.config('*', {
-- 	capabilities = {
-- 		textDocument = {
-- 			semantic_tokens = nil
-- 		}
-- 	}
-- })

vim.keymap.set('n', '<leader>th', function()
    -- local bufnr = vim.current_buf;
    -- local opts = { bufnr = 0 }
    local opts = {}
    vim.lsp.inlay_hint.enable(
        not vim.lsp.inlay_hint.is_enabled(opts),
        opts
    )
end, { desc = "Toggle LSP inlay hints" })

-- The updatetime is needed for cursorHold stuff (kind of)
vim.o.updatetime = 250
vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
        local bufnr = args.buf
        local client = assert(vim.lsp.get_client_by_id(args.data.client_id))

        vim.keymap.set('n', 'grA', function()
            vim.lsp.buf.code_action({
                context = { only = { "source" } },
            })
        end, { desc = "LSP: source actions", buffer = bufnr })

        -- Disable SemanticTokens and use built-in TreeSitter
        vim.lsp.semantic_tokens.enable(false)
        -- if client:supports_method('textDocument/semanticTokens') then
        -- vim.lsp.semantic_tokens.enable(false)
        -- end
        if client:supports_method("textDocument/codeLens") then
            vim.notify(client.name .. " supports codeLens")
        end

        -- if client:supports_method("textDocument/inlayHint") then
        --     --     -- vim.defer_fn(function()
        --     --     -- print('inlay initial: ' .. tostring(vim.lsp.inlay_hint.is_enabled()))
        --     --     -- vim.lsp.inlay_hint.enable(vim.lsp.inlay_hint.is_enabled())
        --     -- vim.lsp.inlay_hint.enable(true)
        --     --     -- Set this client to the global state.
        --     --     -- vim.lsp.inlay_hint.enable(vim.lsp.inlay_hint.is_enabled())
        --     --     -- end, 100)
        -- end

        local enable_cursor_highlight = false
        if client:supports_method("textDocument/documentHighlight") and enable_cursor_highlight then
            local under_cursor_highlights_group =
                vim.api.nvim_create_augroup("mariasolos/cursor_highlights", { clear = false })
            vim.api.nvim_create_autocmd({ "CursorHold", "InsertLeave" }, {
                group = under_cursor_highlights_group,
                desc = "Highlight references under the cursor",
                buffer = bufnr,
                callback = vim.lsp.buf.document_highlight,
            })
            vim.api.nvim_create_autocmd({ "CursorMoved", "InsertEnter", "BufLeave" }, {
                group = under_cursor_highlights_group,
                desc = "Clear highlight references",
                buffer = bufnr,
                callback = vim.lsp.buf.clear_references,
            })
        end

        if client:supports_method("textDocument/completion") then
            -- Optional: trigger autocompletion on EVERY keypress. May be slow!
            local chars = {}
            for i = 32, 126 do
                table.insert(chars, string.char(i))
            end
            client.server_capabilities.completionProvider.triggerCharacters = chars

            vim.lsp.completion.enable(true, client.id, args.buf, { autotrigger = true })
        end

        if client:supports_method("textDocument/documentColor") then
            vim.lsp.document_color.enable(true, bufnr, { style = "virtual" })
            -- vim.lsp.document_color.
        end

        if client:supports_method('textDocument/formatting') then
            vim.keymap.set('n', '<leader>cf', function()
                vim.lsp.buf.format({ bufnr = bufnr })
            end, { desc = 'LSP: format document', buffer = bufnr })
        end

        -- if client:supports_method('textDocument/inlineCompletion', bufnr) then
        if client:supports_method(vim.lsp.protocol.Methods.textDocument_inlineCompletion, bufnr) then
            vim.lsp.inline_completion.enable(true, { bufnr = bufnr })
            vim.keymap.set(
                "i",
                "<C-F>",
                vim.lsp.inline_completion.get,
                { desc = "LSP: accept inline completion", buffer = bufnr }
            )
            vim.keymap.set(
                "i",
                "<C-G>",
                vim.lsp.inline_completion.select,
                { desc = "LSP: switch inline completion", buffer = bufnr }
            )
        end
    end,
})

local original_handler = vim.lsp.handlers["$/progress"]
vim.lsp.handlers["$/progress"] = function(err, result, ctx, config)
    -- Call original handler first
    if original_handler then
        original_handler(err, result, ctx, config)
    end

    -- -- vim.notify(err)
    -- if result.value.kind == "begin" then
    --     -- vim.notify("begin")
    --     -- vim.lsp.inlay_hint.enable(vim.g.enable_inlay_hints)
    -- end
end

vim.diagnostic.config({
    virtual_text = true,
    severity_sort = true,
    -- virtual_lines = {
    --   current_line = false
    -- }
})
-- The default keybindings don't open the float like they used to do.
vim.keymap.set("n", "[d", function()
    vim.diagnostic.jump({ count = -1, float = true })
end, { desc = "Go to previous diagnostic" })
vim.keymap.set("n", "]d", function()
    vim.diagnostic.jump({ count = 1, float = true })
end, { desc = "Go to next diagnostic" })


-- vim.pack.add({
--     { src = "https://github.com/folke/which-key.nvim" },
-- })

vim.pack.add({
    {
        src = "https://github.com/folke/which-key.nvim",
        data = {
            setup = function()
                -- vim.notify('Hello me init')
                -- vim.notify('hello')
            end,
        },
    },
}, {
    load = function(plug)
        local data = plug.spec.data or {}
        local setup = data.setup

        vim.cmd.packadd(plug.spec.name)

        if setup and type(setup) == "function" then
            setup()
        end
    end,
})

vim.pack.add({
    { src = "https://github.com/mikavilpas/yazi.nvim" },
    { src = "https://github.com/nvim-lua/plenary.nvim" }, -- Dependency
})

vim.keymap.set("n", "<leader>-", "<cmd>Yazi toggle<cr>", { desc = "Toggle yazi" })
-- vim.keymap.set("n", "<leader>E", "<cmd>Yazi toggle<cr>", { desc = "Toggle yazi" })

require("vim._extui").enable({
    enable = true, -- Whether to enable or disable the UI.
    msg = {        -- Options related to the message module.
        ---@type 'cmd'|'msg' Where to place regular messages, either in the
        ---cmdline or in a separate ephemeral message window.
        -- target = "cmd",
        target = "cmd",
        timeout = 4000, -- Time a message is visible in the message window.
    },
})
