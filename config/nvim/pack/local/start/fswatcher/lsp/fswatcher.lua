local function create_server(name, opts)
  return function(dispatchers)
    local closing = false
    local request_id = 0
    local ctx = { dispatchers = dispatchers }

    return {
      request = function(method, params, callback)
        request_id = request_id + 1

        if method == "initialize" then
          if opts.on_init then
            opts.on_init(ctx, params)
          end
          callback(nil, {
            capabilities = opts.capabilities or {},
            serverInfo = { name = name },
          })
        elseif method == "shutdown" then
          if opts.on_shutdown then
            opts.on_shutdown(ctx)
          end
          callback(nil, vim.NIL)
        elseif opts.requests and opts.requests[method] then
          local result, err = opts.requests[method](ctx, params)
          if err then
            callback({ code = -32603, message = err }, nil)
          else
            callback(nil, result)
          end
        end

        return true, request_id
      end,

      notify = function(method, params)
        if method == "exit" then
          if opts.on_shutdown then
            opts.on_shutdown(ctx)
          end
          closing = true
          dispatchers.on_exit(0, 0)
        elseif opts.notifications and opts.notifications[method] then
          opts.notifications[method](ctx, params)
        end
      end,

      is_closing = function()
        return closing
      end,

      terminate = function()
        closing = true
      end,
    }
  end
end

local function stop_watcher(w)
  if w and not w:is_closing() then
    w:stop()
    w:close()
  end
end

return {
  cmd = create_server("fswatcher", {
    capabilities = {
      textDocumentSync = { openClose = true },
    },

    on_init = function(ctx)
      ctx.watchers = {}
    end,

    notifications = {
      ["textDocument/didOpen"] = function(ctx, params)
        local uri = params.textDocument.uri
        if ctx.watchers[uri] then
          return
        end
        local path = vim.uri_to_fname(uri)
        local w = vim.uv.new_fs_event()
        if w then
          w:start(path, {}, vim.schedule_wrap(function()
            vim.cmd.checktime()
          end))
          ctx.watchers[uri] = w
        end
      end,

      ["textDocument/didClose"] = function(ctx, params)
        local uri = params.textDocument.uri
        stop_watcher(ctx.watchers[uri])
        ctx.watchers[uri] = nil
      end,
    },

    on_shutdown = function(ctx)
      for uri, w in pairs(ctx.watchers) do
        stop_watcher(w)
        ctx.watchers[uri] = nil
      end
    end,
  }),

  single_file_support = true,
}
