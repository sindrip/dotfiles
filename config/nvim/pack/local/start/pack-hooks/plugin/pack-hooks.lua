vim.api.nvim_create_user_command("Pack", function(cmd)
  local commands = {
    clean = function()
      local stale = vim
        .iter(vim.pack.get())
        :filter(function(p)
          return not p.active
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

  local sub = cmd.fargs[1]
  if commands[sub] then
    commands[sub]()
  else
    vim.notify("Pack: unknown subcommand " .. (sub or ""), vim.log.levels.ERROR)
  end
end, {
  nargs = 1,
  complete = function()
    return { "clean", "sync", "update" }
  end,
})
