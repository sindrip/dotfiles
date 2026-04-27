vim.api.nvim_create_autocmd("UIEnter", {
  once = true,
  callback = function()
    vim.o.cmdheight = 0
    require("vim._core.ui2").enable({})
  end,
})
