local Server = require("lsp-server")

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

local function run_cmd(cmd, content, cwd)
  local result = vim.system(cmd, { stdin = content, cwd = cwd }):wait(5000)

  if result.code ~= 0 then
    return nil, result.stderr or (cmd[1] .. " exited with code " .. result.code)
  end

  if not result.stdout or result.stdout == "" then
    return nil, cmd[1] .. " produced no output"
  end

  return result.stdout
end

local function format(cmd, spec, filepath, content, cwd)
  return run_cmd({ cmd, unpack(spec.args(filepath)) }, content, cwd)
end

local function format_range(cmd, spec, filepath, content, range, cwd)
  if not spec.range_args then
    return format(cmd, spec, filepath, content, cwd)
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

  return run_cmd({ cmd, unpack(spec.range_args(filepath, start_offset, end_offset)) }, content, cwd)
end

local function compute_edits(old, new)
  local edits = {}
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

local function handle_format(self, params, runner)
  local uri = params.textDocument.uri
  local bufnr = vim.uri_to_bufnr(uri)
  local filepath = vim.uri_to_fname(uri)
  local dirname = vim.fn.fnamemodify(filepath, ":h")

  local spec, cmd = resolve(vim.bo[bufnr].filetype, self.formatters_by_ft, dirname)
  if not spec then
    return {}
  end

  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local content = table.concat(lines, "\n") .. "\n"

  local output, err = runner(cmd, spec, filepath, content, dirname)
  if err then
    return nil, err
  end

  if output == content then
    return {}
  end

  return compute_edits(content, output)
end

-- LSP server

local M = Server.new("formatter")

M.capabilities = {
  documentFormattingProvider = true,
  documentRangeFormattingProvider = true,
  textDocumentSync = { openClose = true },
}

function M:on_init(params)
  self.formatters_by_ft = (params.initializationOptions or {}).formatters_by_ft or {}
  self.notified_fts = {}
end

M.notifications["textDocument/didOpen"] = function(self, params)
  local bufnr = vim.uri_to_bufnr(params.textDocument.uri)
  local ft = vim.bo[bufnr].filetype

  if self.notified_fts[ft] then
    return
  end
  self.notified_fts[ft] = true

  local dirname = vim.fn.fnamemodify(vim.uri_to_fname(params.textDocument.uri), ":h")
  local spec, cmd = resolve(ft, self.formatters_by_ft, dirname)

  if spec then
    self.dispatchers.server_request("window/workDoneProgress/create", { token = self.name }, function() end)
    self.dispatchers.notification("$/progress", { token = self.name, value = { kind = "begin", title = cmd } })
    self.dispatchers.notification("$/progress", { token = self.name, value = { kind = "end" } })
  end
end

M.requests["textDocument/formatting"] = function(self, params)
  return handle_format(self, params, format)
end

M.requests["textDocument/rangeFormatting"] = function(self, params)
  return handle_format(self, params, function(cmd, spec, filepath, content, cwd)
    return format_range(cmd, spec, filepath, content, params.range, cwd)
  end)
end

return M:build()
