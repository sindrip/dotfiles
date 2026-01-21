vim.g.mapleader = ' '
vim.g.maplocalleader = '\\'


vim.o.undofile = true
vim.o.autoread = true -- Is this needed?

vim.o.ignorecase = true
vim.o.smartcase = true

local vscode = require('vscode')

-- Vim notifications are displayed in the VSCode notification system
vim.notify = vscode.notify

-- Keymaps
vim.keymap.set('n', '<ESC>', ':nohlsearch<CR>', { desc = 'Clear search highlighting' })

-- vim.keymap.set({ "n", "t" }, "<leader>t", function()
--     vscode.action('workbench.action.createTerminalEditor')
-- end, { desc = "Open terminal" })


vim.keymap.set('n', '<leader>r', function()
    vim.notify('Restarting Neovim extension...')
    vscode.action('vscode-neovim.restart')
end, { desc = 'Restart neovim extension' })
vim.keymap.set('n', '<leader>un', function()
        vscode.action('notifications.clearAll')
    end,
    { desc = 'Dismiss Notifications' })
vim.keymap.set('n', '<leader>ut', function()
        if vscode.get_config('workbench.editor.showTabs') == 'none' then
            vscode.update_config('workbench.editor.showTabs', 'multiple', 'global')
        else
            vscode.update_config('workbench.editor.showTabs', 'none', 'global')
        end
    end,
    { desc = 'Toggle tabs' })

-- "Telescope"
vim.keymap.set('n', '<leader>ff', function()
        vscode.action('workbench.action.quickOpen')
    end,
    { desc = 'Find files' })
-- vim.keymap.set('n', '<leader>fg', function()
--         vscode.action('workbench.action.findInFiles')
--     end,
--     { desc = 'Find grep' })
vim.keymap.set('n', '<leader>fg', function()
        vscode.action('television.ToggleTextFinder')
    end,
    { desc = 'Find grep' })

-- AutoCommands
vim.api.nvim_create_autocmd('TextYankPost', {
    group = vim.api.nvim_create_augroup('sindrip/highlight_yank', { clear = true }),
    pattern = '*',
    desc = 'Highlight yanked text',
    callback = function()
        vim.hl.on_yank({ timeout = 200 })
    end,
})

vim.api.nvim_create_autocmd('FileType', {
    group = vim.api.nvim_create_augroup('sindrip/no_auto_comment', { clear = true }),
    callback = function()
        vim.opt_local.formatoptions:remove({ 'c', 'r', 'o' })
    end,
})
