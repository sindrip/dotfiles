-- Briefly highlight yanked text.

vim.api.nvim_create_autocmd({ "TextYankPost", "TextPutPost" }, {
  group = vim.api.nvim_create_augroup("ui-tweaks.yank-highlight", { clear = true }),
  callback = function()
    vim.hl.hl_op()
  end,
})
