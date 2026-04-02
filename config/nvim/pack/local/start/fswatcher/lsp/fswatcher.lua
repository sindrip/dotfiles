-- Watches open files for external changes and reloads buffers via checktime.
local Server = require("lsp-server")
local M = Server.new("fswatcher")

M.capabilities = { textDocumentSync = { openClose = true } }

local function stop_watcher(w)
  if w and not w:is_closing() then
    w:stop()
    w:close()
  end
end

function M:watch(uri)
  stop_watcher(self.watchers[uri])

  local w = vim.uv.new_fs_event()
  if not w then
    return
  end

  w:start(
    vim.uri_to_fname(uri),
    {},
    vim.schedule_wrap(function()
      vim.cmd.checktime()
      self:watch(uri)
    end)
  )

  self.watchers[uri] = w
end

function M:on_init()
  self.watchers = {}

  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    local name = vim.api.nvim_buf_get_name(buf)

    local is_file = name ~= "" and vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].buftype == ""

    if is_file then
      self:watch(vim.uri_from_fname(name))
    end
  end
end

M.notifications["textDocument/didOpen"] = function(self, params)
  self:watch(params.textDocument.uri)
end

M.notifications["textDocument/didClose"] = function(self, params)
  local uri = params.textDocument.uri
  stop_watcher(self.watchers[uri])
  self.watchers[uri] = nil
end

function M:on_shutdown()
  for uri, w in pairs(self.watchers) do
    stop_watcher(w)
    self.watchers[uri] = nil
  end
end

return M:build()
