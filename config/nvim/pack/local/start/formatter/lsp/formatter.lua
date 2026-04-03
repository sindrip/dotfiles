local Server = require("lsp-server")
local Hijack = require("formatter.hijack")

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

local function classify_step(entry)
  if type(entry) == "table" and entry.action then
    return "action"
  end
  if type(entry) == "string" and entry:match("^source%.") then
    return "action"
  end
  return "cli"
end

local function normalize_action(entry)
  if type(entry) == "table" then
    return entry.action, entry.server
  end
  return entry, nil
end

local function resolve_cli(name, dirname)
  local spec = get_spec(name)
  if not spec then
    return nil
  end

  local cmd = resolve_cmd(spec.cmd, dirname)
  if vim.fn.executable(cmd) ~= 1 then
    return nil
  end

  if spec.config_files and not has_config(spec.config_files, dirname) then
    return nil
  end

  return spec, cmd
end

local function resolve_group(groups, dirname)
  for _, group in ipairs(groups) do
    local steps = {}
    local viable = true

    for _, entry in ipairs(group) do
      local kind = classify_step(entry)
      if kind == "cli" then
        local spec, cmd = resolve_cli(entry, dirname)
        if not spec then
          viable = false
          break
        end
        steps[#steps + 1] = { kind = "cli", spec = spec, cmd = cmd }
      else
        local action, server = normalize_action(entry)
        steps[#steps + 1] = { kind = "action", action = action, server = server }
      end
    end

    if viable then
      return steps
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

local function apply_edits(content, edits)
  local lines = vim.split(content, "\n", { plain = true })

  table.sort(edits, function(a, b)
    if a.range.start.line ~= b.range.start.line then
      return a.range.start.line > b.range.start.line
    end
    return a.range.start.character > b.range.start.character
  end)

  for _, edit in ipairs(edits) do
    local start_line = edit.range.start.line + 1
    local end_line = edit.range["end"].line + 1
    local new_lines = vim.split(edit.newText, "\n", { plain = true })

    if edit.range.start.character > 0 and start_line <= #lines then
      new_lines[1] = lines[start_line]:sub(1, edit.range.start.character) .. new_lines[1]
    end

    if edit.range["end"].character > 0 and end_line <= #lines then
      new_lines[#new_lines] = new_lines[#new_lines] .. lines[end_line]:sub(edit.range["end"].character + 1)
    end

    for i = end_line, start_line, -1 do
      table.remove(lines, i)
    end
    for i, line in ipairs(new_lines) do
      table.insert(lines, start_line + i - 1, line)
    end
  end

  return table.concat(lines, "\n")
end

local function extract_edits(workspace_edit, uri)
  if workspace_edit.documentChanges then
    for _, change in ipairs(workspace_edit.documentChanges) do
      if change.textDocument and change.textDocument.uri == uri then
        return change.edits
      end
    end
  end

  if workspace_edit.changes then
    return workspace_edit.changes[uri]
  end

  return nil
end


local function exec_action(hijack, bufnr, content, action_kind, server_filter, method, params)
  local uri = vim.uri_from_bufnr(bufnr)

  if action_kind == "source.format" then
    local client
    local formatters = hijack:get_formatters(bufnr)
    for _, entry in ipairs(formatters) do
      if not server_filter or entry.name == server_filter then
        client = vim.lsp.get_client_by_id(entry.client_id)
        if client then
          break
        end
      end
    end
    if not client then
      return content
    end

    local result = client:request_sync(method, params, 5000, bufnr)
    if result and result.result and #result.result > 0 then
      return apply_edits(content, result.result)
    end

    return content
  end

  local lines = vim.split(content, "\n", { plain = true })
  local ca_params = {
    textDocument = { uri = uri },
    range = {
      start = { line = 0, character = 0 },
      ["end"] = { line = #lines, character = 0 },
    },
    context = {
      only = { action_kind },
      diagnostics = {},
    },
  }

  for client_id, entry in pairs(hijack:get(bufnr)) do
    if not server_filter or entry.name == server_filter then
      local client = vim.lsp.get_client_by_id(client_id)
      if client then
        local result = client:request_sync("textDocument/codeAction", ca_params, 5000, bufnr)
        if result and result.result then
          for _, action in ipairs(result.result) do
            if not action.edit then
              local resolved = client:request_sync("codeAction/resolve", action, 5000, bufnr)
              if resolved and resolved.result then
                action = resolved.result
              end
            end

            if action.edit then
              local edits = extract_edits(action.edit, uri)
              if edits then
                content = apply_edits(content, edits)
              end
            end
            if action.command then
              client:request_sync("workspace/executeCommand", action.command, 5000, bufnr)
            end
          end
          return content
        end
      end
    end
  end

  return content
end

local function run_pipeline(steps, ctx, content)
  for _, step in ipairs(steps) do
    if step.kind == "action" then
      content = exec_action(ctx.hijack, ctx.bufnr, content, step.action, step.server, ctx.method, ctx.params)
    elseif step.kind == "cli" then
      local output, err = run_cmd({ step.cmd, unpack(step.spec.args(ctx.filepath)) }, content, ctx.dirname)
      if not output then
        vim.notify("[formatter] " .. err, vim.log.levels.WARN)
        return nil
      end
      content = output
    end
  end

  return content
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

local function handle_format(self, method, params)
  local uri = params.textDocument.uri
  local bufnr = vim.uri_to_bufnr(uri)
  local filepath = vim.uri_to_fname(uri)
  local dirname = vim.fn.fnamemodify(filepath, ":h")

  local steps = resolve_group(self.formatters_by_ft[vim.bo[bufnr].filetype] or {}, dirname)
  if not steps then
    steps = { { kind = "action", action = "source.format" } }
  end

  local original = table.concat(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false), "\n") .. "\n"

  local final = run_pipeline(steps, {
    hijack = self.hijack,
    bufnr = bufnr,
    filepath = filepath,
    dirname = dirname,
    method = method,
    params = params,
  }, original)

  if not final or final == original then
    return {}
  end

  return compute_edits(original, final)
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
  self.hijack = Hijack.start(self.name)
end

function M:on_shutdown()
  self.hijack:stop()
end

M.notifications["textDocument/didOpen"] = function(self, params)
  local bufnr = vim.uri_to_bufnr(params.textDocument.uri)
  local ft = vim.bo[bufnr].filetype

  if self.notified_fts[ft] then
    return
  end
  self.notified_fts[ft] = true

  local dirname = vim.fn.fnamemodify(vim.uri_to_fname(params.textDocument.uri), ":h")
  local steps = resolve_group(self.formatters_by_ft[ft] or {}, dirname)
  if not steps then
    return
  end

  local names = {}
  for _, step in ipairs(steps) do
    names[#names + 1] = step.action or step.cmd
  end

  local title = table.concat(names, " | ")
  self.dispatchers.server_request("window/workDoneProgress/create", { token = self.name }, function() end)
  self.dispatchers.notification("$/progress", { token = self.name, value = { kind = "begin", title = title } })
  self.dispatchers.notification("$/progress", { token = self.name, value = { kind = "end" } })
end

M.requests["textDocument/formatting"] = function(self, params)
  return handle_format(self, "textDocument/formatting", params)
end

M.requests["textDocument/rangeFormatting"] = function(self, params)
  return handle_format(self, "textDocument/rangeFormatting", params)
end

return M:build()
