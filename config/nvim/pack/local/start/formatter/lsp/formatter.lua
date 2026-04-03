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
      if entry == "source.format" then
        steps[#steps + 1] = { kind = "format" }
      elseif type(entry) == "string" and entry:match("^source%.") then
        steps[#steps + 1] = { kind = "action", action = entry }
      else
        local spec, cmd = resolve_cli(entry, dirname)
        if not spec then
          viable = false
          break
        end
        steps[#steps + 1] = { kind = "cli", spec = spec, cmd = cmd }
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
    local name = vim.fn.fnamemodify(cmd[1], ":t")
    return nil, name .. " failed"
  end

  if not result.stdout or result.stdout == "" then
    return nil, cmd[1] .. " produced no output"
  end

  return result.stdout
end

local function exec_action(bufnr, action_kind)
  local params = {
    textDocument = { uri = vim.uri_from_bufnr(bufnr) },
    range = {
      start = { line = 0, character = 0 },
      ["end"] = { line = vim.api.nvim_buf_line_count(bufnr), character = 0 },
    },
    context = { only = { action_kind }, diagnostics = {} },
  }

  local clients = vim.lsp.get_clients({ bufnr = bufnr, method = "textDocument/codeAction" })

  for _, client in ipairs(clients) do
    local res = client:request_sync("textDocument/codeAction", params, 5000, bufnr)
    if res and not res.err then
      for _, action in ipairs(res.result or {}) do
        if not action.edit then
          local resolved = client:request_sync("codeAction/resolve", action, 5000, bufnr)
          if resolved and resolved.result then
            action = resolved.result
          end
        end

        if action.edit then
          vim.lsp.util.apply_workspace_edit(action.edit, "utf-16")
        end
        if action.command then
          client:request_sync("workspace/executeCommand", action.command, 5000, bufnr)
        end
      end
    end
  end
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

local function apply_text_edits(content, edits)
  local scratch = vim.api.nvim_create_buf(false, true)
  local lines = vim.split(content, "\n", { plain = true })
  if #lines > 0 and lines[#lines] == "" then
    table.remove(lines)
  end
  vim.api.nvim_buf_set_lines(scratch, 0, -1, false, lines)
  vim.lsp.util.apply_text_edits(edits, scratch, "utf-16")
  local result = table.concat(vim.api.nvim_buf_get_lines(scratch, 0, -1, false), "\n") .. "\n"
  vim.api.nvim_buf_delete(scratch, { force = true })
  return result
end

local function get_lsp_edits(ctx)
  for _, entry in ipairs(ctx.hijack:get_formatters(ctx.bufnr)) do
    local client = vim.lsp.get_client_by_id(entry.client_id)
    if client then
      local result = client:request_sync(ctx.method, ctx.params, 5000, ctx.bufnr)
      if result and result.result and #result.result > 0 then
        return result.result
      end
    end
  end
  return nil
end

local function lsp_format(ctx, content)
  local edits = get_lsp_edits(ctx)
  if edits then
    return apply_text_edits(content, edits)
  end
  return content
end

local function run_pipeline(steps, ctx, content)
  for _, step in ipairs(steps) do
    if step.kind == "format" then
      content = lsp_format(ctx, content)
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

local function handle_format(self, method, params)
  local bufnr = vim.uri_to_bufnr(params.textDocument.uri)
  local filepath = vim.uri_to_fname(params.textDocument.uri)
  local dirname = vim.fn.fnamemodify(filepath, ":h")

  local steps = resolve_group(self.formatters_by_ft[vim.bo[bufnr].filetype] or {}, dirname)

  local ctx = {
    hijack = self.hijack,
    bufnr = bufnr,
    filepath = filepath,
    dirname = dirname,
    method = method,
    params = params,
  }

  if not steps then
    return get_lsp_edits(ctx) or {}
  end

  for _, step in ipairs(steps) do
    if step.kind == "action" then
      exec_action(bufnr, step.action)
    end
  end

  local original = table.concat(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false), "\n") .. "\n"
  local final = run_pipeline(steps, ctx, original)

  if not final or final == original then
    return {}
  end

  return compute_edits(original, final)
end

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
    names[#names + 1] = step.action or step.cmd or "lsp"
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
