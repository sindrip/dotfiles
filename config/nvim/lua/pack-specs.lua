local M = {}

local function to_spec(raw)
  if type(raw) == "string" then
    raw = { raw }
  end
  local src = raw[1]
  local name = src:match("[^/]+$")
  return {
    src = src,
    version = raw.version or raw.branch,
    data = {
      module = raw.module or name:gsub("%.nvim$", ""),
      opts = raw.opts,
      config = raw.config,
      build = raw.build,
    },
  }
end

local function on_pack_changed(ev)
  local build = ev.data.spec.data and ev.data.spec.data.build
  if not build then
    return
  end

  if not ev.data.active then
    vim.cmd.packadd(ev.data.spec.name)
  end

  if type(build) == "function" then
    build()
  elseif type(build) == "string" and build:sub(1, 1) == ":" then
    vim.cmd(build:sub(2))
  end
end

local function on_load(plug)
  vim.cmd.packadd(plug.spec.name)

  local data = plug.spec.data or {}

  if data.config then
    data.config(data.opts)
  else
    local ok, mod = pcall(require, data.module)
    if ok and mod.setup then
      mod.setup(data.opts or {})
    end
  end
end

function M.add(specs)
  local native = vim.iter(specs):map(to_spec):totable()
  M._known = vim.iter(native):fold({}, function(acc, s)
    acc[s.src:match("[^/]+$")] = true
    return acc
  end)

  vim.api.nvim_create_autocmd("PackChanged", {
    group = vim.api.nvim_create_augroup("PackSpec", { clear = true }),
    callback = on_pack_changed,
  })

  vim.pack.add(native, { confirm = false, load = on_load })
end

M.commands = {
  clean = function()
    local known = M._known or {}
    local stale = vim
      .iter(vim.pack.get())
      :filter(function(p)
        return not p.active and not known[p.spec.name]
      end)
      :map(function(p)
        return p.spec.name
      end)
      :totable()
    if #stale > 0 then
      vim.pack.del(stale)
    end
  end,
  sync = function()
    vim.pack.update(nil, { offline = true })
  end,
  update = function()
    vim.pack.update()
  end,
}

function M.register_commands()
  vim.api.nvim_create_user_command("Pack", function(cmd)
    local sub = cmd.fargs[1]
    if M.commands[sub] then
      M.commands[sub]()
    else
      vim.notify("Pack: unknown subcommand " .. (sub or ""), vim.log.levels.ERROR)
    end
  end, {
    nargs = 1,
    complete = function()
      return vim.tbl_keys(M.commands)
    end,
  })
end

return M
