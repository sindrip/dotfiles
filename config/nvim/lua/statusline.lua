local M = {}

function M.setup()
  local icon_copilot = string.char(0xEF, 0x92, 0xB8)
  local icon_copilot_err = string.char(0xEF, 0x92, 0xB9)

  local function copilot_status()
    for _, client in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
      if client.name == "copilot" and vim.lsp.is_enabled("copilot") then
        return icon_copilot
      end
    end

    return icon_copilot_err
  end

  local function copilot_color()
    for _, client in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
      if client.name == "copilot" and vim.lsp.is_enabled("copilot") then
        return nil
      end
    end
    return { fg = "#737994" }
  end

  local function copilot_click()
    vim.cmd.CopilotToggle()
  end

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
        { copilot_status, color = copilot_color, on_click = copilot_click, padding = { left = 1, right = 2 } },
        { "lsp_status", ignore_lsp = { "copilot" } },
      },
      lualine_y = { "progress", "location" },
      lualine_z = { "branch" },
    },
  })
end

return M
