local inline_completion = vim.lsp.inline_completion
local inline_completion_capability = require("vim.lsp._capability").all.inline_completion

function inline_completion_capability:automatic_request()
  self:abort()
end

local function request_inline_completion(bufnr)
  local completor = inline_completion_capability.active[bufnr]
  if completor then
    completor:request(vim.lsp.protocol.InlineCompletionTriggerKind.Invoked)
  end
end

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("copilot.keymaps", { clear = true }),
  callback = function(args)
    local bufnr = args.buf
    local client = assert(vim.lsp.get_client_by_id(args.data.client_id))
    local method = vim.lsp.protocol.Methods.textDocument_inlineCompletion

    if not client:supports_method(method, bufnr) then
      return
    end

    inline_completion.enable(true, { bufnr = bufnr })

    vim.keymap.set("i", "<C-y>", function()
      local accepted = inline_completion.get({
        on_accept = function(item)
          vim.defer_fn(function()
            request_inline_completion(bufnr)
          end, 10)
          return item
        end,
      })

      if not accepted then
        return "<C-y>"
      end
    end, { buffer = bufnr, expr = true, desc = "Accept inline completion" })

    vim.keymap.set("i", "<C-e>", function()
      if vim.fn.pumvisible() == 1 then
        return "<C-e>"
      end
      local completor = inline_completion_capability.active[bufnr]
      if completor and completor.current then
        inline_completion.select({ bufnr = bufnr })
      else
        request_inline_completion(bufnr)
      end
    end, { buffer = bufnr, expr = true, desc = "Request inline completion" })
  end,
})

vim.lsp.enable("copilot")
