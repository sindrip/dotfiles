-- Briefly highlight yanked text.

vim.api.nvim_create_autocmd("TextYankPost", {
  group = vim.api.nvim_create_augroup("ui-tweaks.yank-highlight", { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})
