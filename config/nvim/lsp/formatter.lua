-- Format buffers on save using external formatters.

local formatters = {
  biome = {
    cmd = "biome",
    args = function(path)
      return { "format", "--stdin-file-path", path }
    end,
    config_files = { "biome.json", "biome.jsonc" },
  },
  prettier = {
    cmd = "prettier",
    args = function(path)
      return { "--stdin-filepath", path }
    end,
    config_files = {
      ".prettierrc",
      ".prettierrc.json",
      ".prettierrc.yml",
      ".prettierrc.yaml",
      ".prettierrc.js",
      ".prettierrc.cjs",
      ".prettierrc.mjs",
      ".prettierrc.toml",
      "prettier.config.js",
      "prettier.config.cjs",
      "prettier.config.mjs",
    },
  },
  stylua = {
    cmd = "stylua",
    args = function(path)
      return {
        "--search-parent-directories",
        "--respect-ignores",
        "--stdin-filepath",
        path,
        "-",
      }
    end,
  },
}

local formatters_by_ft = {
  javascript = { "biome", "prettier" },
  javascriptreact = { "biome", "prettier" },
  typescript = { "biome", "prettier" },
  typescriptreact = { "biome", "prettier" },
  json = { "biome", "prettier" },
  css = { "biome", "prettier" },
  lua = { "stylua" },
}

local function has_config(config_files)
  return #vim.fs.find(config_files, { upward = true, path = vim.fn.getcwd(), limit = 1 }) > 0
end

local function resolve_formatter(filetype)
  local chain = formatters_by_ft[filetype]
  if not chain then
    return nil
  end
  for _, name in ipairs(chain) do
    local spec = formatters[name]
    if vim.fn.executable(spec.cmd) == 1 then
      if not spec.config_files or has_config(spec.config_files) then
        return spec
      end
    end
  end
  return nil
end

local function run_formatter(spec, filepath, content)
  local args = spec.args(filepath)
  local cmd = { spec.cmd, unpack(args) }
  local result = vim.system(cmd, { stdin = content }):wait(5000)
  if result.code ~= 0 then
    return nil, result.stderr or (spec.cmd .. " exited with code " .. result.code)
  end
  if not result.stdout or result.stdout == "" then
    return nil, spec.cmd .. " produced no output"
  end
  return result.stdout
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

    local function progress(value)
      dispatchers.notification("$/progress", { token = token, value = value })
    end

    return {
      request = function(method, params, callback)
        request_id = request_id + 1

        if method == "initialize" then
          callback(nil, {
            capabilities = {
              documentFormattingProvider = true,
              textDocumentSync = { openClose = true },
            },
            serverInfo = { name = "formatter" },
          })
        elseif method == "textDocument/formatting" then
          local uri = params.textDocument.uri
          local bufnr = vim.uri_to_bufnr(uri)
          local filetype = vim.bo[bufnr].filetype

          local spec = resolve_formatter(filetype)
          if not spec then
            callback(nil, {})
            return true, request_id
          end

          local filepath = vim.uri_to_fname(uri)
          local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
          local content = table.concat(lines, "\n") .. "\n"

          local output, err = run_formatter(spec, filepath, content)
          if err then
            callback({ code = -32603, message = err }, nil)
            return true, request_id
          end

          if output == content then
            callback(nil, {})
            return true, request_id
          end

          callback(nil, compute_edits(content, output))
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
            local spec = resolve_formatter(ft)
            if spec then
              progress({ kind = "begin", title = spec.cmd })
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

  filetypes = {
    "javascript",
    "javascriptreact",
    "typescript",
    "typescriptreact",
    "json",
    "css",
    "lua",
  },

  root_markers = { ".git" },
  single_file_support = true,
}
