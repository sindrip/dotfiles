local M = {}

local watchers = {}

function M.stop(buf)
  local w = watchers[buf]
  if w and not w:is_closing() then
    w:stop()
    w:close()
  end
  watchers[buf] = nil
end

function M.stop_all()
  for buf, _ in pairs(watchers) do
    M.stop(buf)
  end
end

function M.watch(buf)
  M.stop(buf)

  if vim.bo[buf].buftype ~= "" then
    return
  end

  local name = vim.api.nvim_buf_get_name(buf)
  if name == "" then
    return
  end

  local w = vim.uv.new_fs_event()
  if not w then
    return
  end

  w:start(
    name,
    {},
    vim.schedule_wrap(function()
      pcall(vim.cmd.checktime)
      M.watch(buf)
    end)
  )

  watchers[buf] = w
end

return M
