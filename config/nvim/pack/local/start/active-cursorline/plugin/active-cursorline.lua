-- Only show the cursorline in the focused window.

local group = vim.api.nvim_create_augroup("active-cursorline", { clear = true })

vim.api.nvim_create_autocmd("WinEnter", {
  group = group,
  callback = function()
    vim.wo.cursorline = true
  end,
})

vim.api.nvim_create_autocmd("WinLeave", {
  group = group,
  callback = function()
    vim.wo.cursorline = false
  end,
})
