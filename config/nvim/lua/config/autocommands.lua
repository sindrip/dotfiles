-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
  group = vim.api.nvim_create_augroup("highlight_yank", { clear = true }),
  pattern = "*",
  desc = "highlight selection on yank",
  callback = function()
    vim.hl.on_yank({ timeout = 200 })
  end,
})

-- Open help in vertical split (I think I prefer sending it to a new tab)
vim.api.nvim_create_autocmd("BufWinEnter", {
  group = vim.api.nvim_create_augroup("help_vertical", { clear = true }),
  callback = function()
    if vim.bo.buftype == "help" then
      vim.cmd.wincmd("L")
    end
  end,
})

-- Remove 'o' from formatoptions for all filetypes
vim.api.nvim_create_autocmd("Filetype", {
  group = vim.api.nvim_create_augroup("auto_comments", { clear = true }),
  callback = function()
    vim.opt.formatoptions:remove("o") -- Don't continue comments with 'o' or 'O'
    -- c and r are often removed as well
  end,
})

-- -- CmdLine 0
-- local group = vim.api.nvim_create_augroup("cmdline_height", { clear = true })
-- local set_cmdheight = function(val)
--   if vim.opt.cmdheight:get() ~= val then
--     vim.o.cmdheight = val
--   end
-- end
-- vim.api.nvim_create_autocmd("CmdlineEnter", {
--   pattern = "*",
--   group = group,
--   callback = function()
--     set_cmdheight(1)
--     vim.cmd.redraw()
--     vim.notify "Entered Command Line"
--   end,
-- })
--
-- vim.api.nvim_create_autocmd("CmdlineLeave", {
--   pattern = "*",
--   group = group,
--   callback = function()
--     set_cmdheight(0)
--     vim.notify "Left Command Line"
--   end
-- })
