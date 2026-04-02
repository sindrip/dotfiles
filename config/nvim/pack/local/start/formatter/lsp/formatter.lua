local spec_cache = {}

local function get_spec(name)
  if spec_cache[name] == nil then
    local ok, spec = pcall(require, "formatter.formatters." .. name)
    spec_cache[name] = ok and spec or false
  end
  return spec_cache[name] or nil
end

local function has_config(config_files, dirname)
  return #vim.fs.find(config_files, { upward = true, path = dirname, limit = 1 }) > 0
end

local function resolve_cmd(cmd, dirname)
  local found = vim.fs.find("node_modules/.bin/" .. cmd, { upward = true, path = dirname })
  return found[1] or cmd
end

local function resolve(filetype, formatters_by_ft, dirname)
  local chain = formatters_by_ft[filetype]
  if not chain then
    return nil
  end
  for _, name in ipairs(chain) do
    local spec = get_spec(name)
    if spec then
      local cmd = resolve_cmd(spec.cmd, dirname)
      if vim.fn.executable(cmd) == 1 then
        if not spec.config_files or has_config(spec.config_files, dirname) then
          return spec, cmd
        end
      end
    end
  end
  return nil
end

local function run_cmd(cmd, content)
  local result = vim.system(cmd, { stdin = content }):wait(5000)
  if result.code ~= 0 then
    return nil, result.stderr or (cmd[1] .. " exited with code " .. result.code)
  end
  if not result.stdout or result.stdout == "" then
    return nil, cmd[1] .. " produced no output"
  end
  return result.stdout
end

local function format(cmd, spec, filepath, content)
  return run_cmd({ cmd, unpack(spec.args(filepath)) }, content)
end

local function format_range(cmd, spec, filepath, content, range)
  if not spec.range_args then
    return format(cmd, spec, filepath, content)
  end
  local lines = vim.split(content, "\n", { plain = true })
  local start_offset = 0
  for i = 1, range.start.line do
    start_offset = start_offset + #lines[i] + 1
  end
  start_offset = start_offset + range.start.character
  local end_offset = 0
  for i = 1, range["end"].line do
    end_offset = end_offset + #lines[i] + 1
  end
  end_offset = end_offset + range["end"].character
  return run_cmd({ cmd, unpack(spec.range_args(filepath, start_offset, end_offset)) }, content)
end

local function compute_edits(old, new)
  local edits = {}
  local old_lines = vim.split(old, "\n", { plain = true })
  local new_lines = vim.split(new, "\n", { plain = true })
  for _, hunk in ipairs(vim.text.diff(old, new, { result_type = "indices" })) do
    local old_start, old_count, new_start, new_count = unpack(hunk)
    local replacement = {}
    for i = new_start, new_start + new_count - 1 do
      replacement[#replacement + 1] = new_lines[i]
    end
    edits[#edits + 1] = {
      range = {
        start = { line = old_start - 1, character = 0 },
        ["end"] = { line = old_start - 1 + old_count, character = 0 },
      },
      newText = #replacement > 0 and (table.concat(replacement, "\n") .. "\n") or "",
    }
  end
  return edits
end

return {
  cmd = function(dispatchers)
    local closing = false
    local request_id = 0
    local token = "formatter"
    local notified_fts = {}
    local formatters_by_ft = {}

    local function progress(value)
      dispatchers.notification("$/progress", { token = token, value = value })
    end

    local function handle_format(params, callback, runner)
      local uri = params.textDocument.uri
      local bufnr = vim.uri_to_bufnr(uri)
      local filepath = vim.uri_to_fname(uri)
      local dirname = vim.fn.fnamemodify(filepath, ":h")
      local spec, cmd = resolve(vim.bo[bufnr].filetype, formatters_by_ft, dirname)
      if not spec then
        callback(nil, {})
        return
      end

      local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
      local content = table.concat(lines, "\n") .. "\n"

      local output, err = runner(cmd, spec, filepath, content)
      if err then
        callback({ code = -32603, message = err }, nil)
        return
      end

      if output == content then
        callback(nil, {})
        return
      end

      callback(nil, compute_edits(content, output))
    end

    return {
      request = function(method, params, callback)
        request_id = request_id + 1

        if method == "initialize" then
          local opts = params.initializationOptions or {}
          formatters_by_ft = opts.formatters_by_ft or {}
          callback(nil, {
            capabilities = {
              documentFormattingProvider = true,
              documentRangeFormattingProvider = true,
              textDocumentSync = { openClose = true },
            },
            serverInfo = { name = "formatter" },
          })
        elseif method == "textDocument/formatting" then
          handle_format(params, callback, function(cmd, spec, filepath, content)
            return format(cmd, spec, filepath, content)
          end)
        elseif method == "textDocument/rangeFormatting" then
          handle_format(params, callback, function(cmd, spec, filepath, content)
            return format_range(cmd, spec, filepath, content, params.range)
          end)
        elseif method == "shutdown" then
          callback(nil, vim.NIL)
        end

        return true, request_id
      end,

      notify = function(method, params)
        if method == "initialized" then
          dispatchers.server_request("window/workDoneProgress/create", { token = token }, function() end)
        elseif method == "textDocument/didOpen" then
          local bufnr = vim.uri_to_bufnr(params.textDocument.uri)
          local ft = vim.bo[bufnr].filetype
          if not notified_fts[ft] then
            notified_fts[ft] = true
            local dirname = vim.fn.fnamemodify(vim.uri_to_fname(params.textDocument.uri), ":h")
            local spec, cmd = resolve(ft, formatters_by_ft, dirname)
            if spec then
              progress({ kind = "begin", title = cmd })
              progress({ kind = "end" })
            end
          end
        elseif method == "exit" then
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

  single_file_support = true,
}
