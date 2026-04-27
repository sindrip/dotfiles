-- Equalize splits when the terminal is resized.

vim.api.nvim_create_autocmd("VimResized", {
  group = vim.api.nvim_create_augroup("ui-tweaks.equalize-splits", { clear = true }),
  callback = function()
    vim.cmd.wincmd("=")
  end,
})
