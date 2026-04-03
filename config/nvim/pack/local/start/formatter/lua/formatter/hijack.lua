local M = {}
M.__index = M

function M.start(server_name)
  local self = setmetatable({ server_name = server_name, entries = {}, autocmds = {} }, M)

  self.autocmds = {
    vim.api.nvim_create_autocmd("LspAttach", {
      callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if not client then
          return
        end

        if client.name == self.server_name then
          for _, c in ipairs(vim.lsp.get_clients({ bufnr = args.buf })) do
            if c.name ~= self.server_name then
              self:add(args.buf, c)
            end
          end
        else
          self:add(args.buf, client)
        end
      end,
    }),

    vim.api.nvim_create_autocmd("LspDetach", {
      callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if client and client.name ~= self.server_name then
          self:remove(args.buf, client.id)
        end
      end,
    }),
  }

  return self
end

function M:stop()
  for _, id in ipairs(self.autocmds) do
    vim.api.nvim_del_autocmd(id)
  end

  for bufnr, clients in pairs(self.entries) do
    for client_id, entry in pairs(clients) do
      local client = vim.lsp.get_client_by_id(client_id)
      if client then
        client.server_capabilities.documentFormattingProvider = entry.can_format
        client.server_capabilities.documentRangeFormattingProvider = entry.can_range_format
      end
    end
  end

  self.autocmds = {}
  self.entries = {}
end

function M:add(bufnr, client)
  if not self.entries[bufnr] then
    self.entries[bufnr] = {}
  end

  if self.entries[bufnr][client.id] then
    return
  end

  local caps = client.server_capabilities or {}
  self.entries[bufnr][client.id] = {
    name = client.name,
    can_format = caps.documentFormattingProvider or false,
    can_range_format = caps.documentRangeFormattingProvider or false,
  }

  caps.documentFormattingProvider = false
  caps.documentRangeFormattingProvider = false
end

function M:remove(bufnr, client_id)
  if not self.entries[bufnr] then
    return
  end

  self.entries[bufnr][client_id] = nil

  if not next(self.entries[bufnr]) then
    self.entries[bufnr] = nil
  end
end

function M:get(bufnr)
  return self.entries[bufnr] or {}
end

function M:get_formatters(bufnr)
  local result = {}
  for client_id, entry in pairs(self.entries[bufnr] or {}) do
    if entry.can_format or entry.can_range_format then
      result[#result + 1] = {
        client_id = client_id,
        name = entry.name,
        can_format = entry.can_format,
        can_range_format = entry.can_range_format,
      }
    end
  end
  return result
end

return M
