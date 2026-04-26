-- Reload buffers when their files change externally.

local group = vim.api.nvim_create_augroup("auto-reload", { clear = true })

vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost", "BufFilePost" }, {
  group = group,
  callback = function(args)
    require("auto-reload").watch(args.buf)
  end,
})

vim.api.nvim_create_autocmd({ "BufUnload", "BufWipeout" }, {
  group = group,
  callback = function(args)
    require("auto-reload").stop(args.buf)
  end,
})

vim.api.nvim_create_autocmd("VimLeavePre", {
  group = group,
  callback = function()
    require("auto-reload").stop_all()
  end,
})
