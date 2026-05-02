local adapter = require("inline-assist.adapter")

-- Keymaps: global insert-mode bindings, adapter operations are no-ops
-- when no inline completion server is attached.

vim.keymap.set("i", "<C-]>", function()
  local bufnr = vim.api.nvim_get_current_buf()

  if adapter.is_active(bufnr) then
    adapter.select(bufnr)
  else
    adapter.request(bufnr)
  end
end, { desc = "Request/cycle inline completion" })

vim.keymap.set("i", "<C-y>", function()
  local bufnr = vim.api.nvim_get_current_buf()

  if adapter.accept(bufnr) then
    vim.defer_fn(function()
      adapter.request(bufnr)
    end, 10)
  else
    return "<C-y>"
  end
end, { expr = true, desc = "Accept inline completion" })

vim.keymap.set("i", "<C-e>", function()
  local bufnr = vim.api.nvim_get_current_buf()

  if adapter.is_active(bufnr) or adapter.is_pending() then
    adapter.dismiss(bufnr)
  else
    return "<C-e>"
  end
end, { expr = true, desc = "Dismiss inline completion" })
