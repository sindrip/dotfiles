vim.o.completeopt = "menuone,noselect,popup,fuzzy"
vim.o.pumheight = 10
vim.opt.shortmess:append("c") -- silence "match X of N", "Pattern not found"

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)

    if not client or not client:supports_method("textDocument/completion") then
      return
    end

    vim.lsp.completion.enable(true, client.id, ev.buf, {
      autotrigger = false,
      convert = function(item)
        local kind = vim.lsp.protocol.CompletionItemKind[item.kind] or "Text"
        local icon, hl = require("mini.icons").get("lsp", kind)
        if kind == "Function" then
          icon = "\u{f0295}"
        end
        return {
          kind = icon,
          kind_hlgroup = hl,
          menu = kind,
        }
      end,
    })
  end,
})
