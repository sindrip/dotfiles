local M = {}

function M.setup()
  vim.o.showmode = false
  require("lualine").setup({
    options = {
      theme = "auto",
      component_separators = { left = "", right = "\u{e0b3}" },
      section_separators = { left = "\u{e0b0}", right = "\u{e0b2}" },
      refresh = { statusline = 100 },
    },
    sections = {
      lualine_a = { "mode" },
      lualine_b = {
        { "filetype", icon_only = true, colored = true, padding = { left = 1, right = 0 } },
        { "filename", padding = { left = 0, right = 1 } },
      },
      lualine_c = {
        "diagnostics",
      },
      lualine_x = {
        "lsp_status",
      },
      lualine_y = { "progress", "location" },
      lualine_z = { "branch" },
    },
  })
end

return M
