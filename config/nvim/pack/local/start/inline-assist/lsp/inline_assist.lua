local adapter = require("inline-assist.adapter")

local config = {
  cmd = { "copilot-language-server", "--stdio" },
}

config.handlers = {
  ["didChangeStatus"] = function(_, result)
    local bufnr = vim.api.nvim_get_current_buf()
    if result.busy then
      adapter.show_pending(bufnr)
    else
      adapter.clear_pending(bufnr)
    end
  end,
}

config.root_markers = { ".git" }

config.init_options = {
  editorInfo = {
    name = "Neovim",
    version = tostring(vim.version()),
  },
  editorPluginInfo = {
    name = "inline-assist",
    version = "0.1.0",
  },
}

return config
