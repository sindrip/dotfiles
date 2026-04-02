-- Reload buffers when files change on disk.
return {
  cmd = function(dispatchers)
    local closing = false
    local watcher = nil

    local function cleanup()
      if watcher and not watcher:is_closing() then
        watcher:stop()
        watcher:close()
      end
      watcher = nil
    end

    local request_id = 0

    return {
      request = function(method, params, callback)
        request_id = request_id + 1

        if method == "initialize" then
          local root = params.rootUri and vim.uri_to_fname(params.rootUri) or params.rootPath
          if root then
            watcher = vim.uv.new_fs_event()
            if watcher then
              watcher:start(root, { recursive = true }, vim.schedule_wrap(function()
                vim.cmd.checktime()
              end))
            end
          end
          callback(nil, {
            capabilities = {},
            serverInfo = { name = "file_watcher" },
          })
        elseif method == "shutdown" then
          cleanup()
          callback(nil, vim.NIL)
        end

        return true, request_id
      end,

      notify = function(method)
        if method == "exit" then
          cleanup()
          closing = true
          dispatchers.on_exit(0, 0)
        end
      end,

      is_closing = function()
        return closing
      end,

      terminate = function()
        closing = true
      end,
    }
  end,

  root_markers = { ".git" },

  single_file_support = true,
}
