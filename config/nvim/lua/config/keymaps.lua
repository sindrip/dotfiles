-- Keep cursor centered when scrolling half-page up/down
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "<C-d>", "<C-d>zz")

-- Clear search highlights
vim.keymap.set("n", "<esc>", "<cmd>nohlsearch<CR>", { desc = "Clear highlights" })

-- Maybe we don't need this once 0.12 releases with the :restart command
vim.keymap.set("n", "<leader>x", "<cmd>.lua<CR>", { desc = "Execute the current line" })
vim.keymap.set("n", "<leader><leader>x", "<cmd>source %<CR>", { desc = "Execute the current file" })
