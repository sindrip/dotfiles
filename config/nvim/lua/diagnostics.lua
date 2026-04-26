local severity = vim.diagnostic.severity

local signs = {
  [severity.ERROR] = "",
  [severity.WARN] = "",
  [severity.INFO] = "",
  [severity.HINT] = "",
}

vim.diagnostic.config({
  severity_sort = true,
  update_in_insert = false,
  float = {
    source = "if_many",
  },
  jump = {
    on_jump = function(diagnostic, bufnr)
      if diagnostic then
        vim.diagnostic.open_float({
          bufnr = bufnr,
          scope = "cursor",
          focus = false,
        })
      end
    end,
  },
  signs = {
    text = signs,
  },
  virtual_text = {
    current_line = true,
    source = "if_many",
    spacing = 2,
    prefix = function(diagnostic)
      return signs[diagnostic.severity]
    end,
  },
})
