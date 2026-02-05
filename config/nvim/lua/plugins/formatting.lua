local CreateToggleModule = function(name)
  local M = {}

  M[name] = true

  M.toggle = function()
    M[name] = not M[name]
    if M[name] then
      vim.notify("Enabled " .. name .. " (Global)")
    else
      vim.notify("Disabled " .. name .. " (Global)")
    end
  end

  M.is_enabled = function()
    return M[name]
  end

  M.icon = function()
    local icon = M[name] and " " or " "
    local color = M[name] and "green" or "yellow"
    return {
      icon = icon,
      color = color,
    }
  end

  M.desc = function()
    return M[name] and "Disable " .. name or "Enable " .. name
  end

  return M
end

local autoformat = CreateToggleModule("Auto Format")

return {
  {
    "stevearc/conform.nvim",
    opts = {
      format_on_save = function()
        if autoformat.is_enabled() then
          return {
            timeout_ms = 1000,
            lsp_format = "fallback",
          }
        else
          return nil
        end
      end,
      formatters_by_ft = {
        -- lua = { "stylua" },
        -- javascript = { "prettierd" },
        typescript = { "prettier" },
        -- html = { "prettierd" },
        -- css = { "prettierd" },
        json = { "prettier" },
      },
    },
  },
  {
    "folke/which-key.nvim",
    opts = {
      spec = {
        { "<leader>u", group = "+ui" },
        {
          "<leader>uf",
          autoformat.toggle,
          icon = autoformat.icon,
          desc = autoformat.desc,
        },
      },
    },
  },
}
