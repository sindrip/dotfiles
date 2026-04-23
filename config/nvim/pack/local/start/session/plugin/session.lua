-- Automatic per-cwd session save/load.
-- Saves on VimLeavePre, auto-loads on VimEnter when launched with no args.

vim.opt.sessionoptions:remove("blank") -- scratch/sidebar windows (e.g. snacks explorer)
vim.opt.sessionoptions:remove("terminal")

local group = vim.api.nvim_create_augroup("session", { clear = true })

vim.api.nvim_create_autocmd("VimLeavePre", {
  group = group,
  callback = function()
    require("session").save()
  end,
})

vim.api.nvim_create_autocmd("VimEnter", {
  group = group,
  nested = true,
  callback = function()
    if vim.fn.argc() == 0 then
      require("session").load()
    end
  end,
})
