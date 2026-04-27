vim.api.nvim_create_autocmd("PackChanged", {
  group = vim.api.nvim_create_augroup("pack-hooks", { clear = true }),
  callback = function(ev)
    local build = ev.data.spec.data and ev.data.spec.data.build
    if not build or ev.data.kind == "delete" then
      return
    end

    if not ev.data.active then
      vim.cmd.packadd(ev.data.spec.name)
    end

    if type(build) == "function" then
      build(ev)
    end
  end,
})
