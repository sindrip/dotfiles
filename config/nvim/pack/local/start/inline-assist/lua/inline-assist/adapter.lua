local M = {}

local inline_completion = vim.lsp.inline_completion

-- vim.lsp._capability: no public API exists to trigger inline completion
-- requests or suppress automatic ones. inline_completion.enable() bundles
-- rendering with automatic TextChangedI requests and there is no
-- autotrigger=false option yet. This prototype override + reads of
-- capability.active are the minimum private surface needed until that
-- lands upstream.
local capability = require("vim.lsp._capability").all.inline_completion

local _automatic_request = capability.automatic_request

function capability:automatic_request()
  for client_id in pairs(self.client_state) do
    local client = vim.lsp.get_client_by_id(client_id)

    if client and client.name == "inline_assist" then
      self:abort()
      M.clear_pending(vim.api.nvim_get_current_buf())
      return
    end
  end

  _automatic_request(self)
end

--- Trigger an inline completion request.
function M.request(bufnr)
  local completor = capability.active[bufnr]

  if not completor then
    return
  end

  completor:request(vim.lsp.protocol.InlineCompletionTriggerKind.Invoked)
end

--- Dismiss the current inline completion suggestion.
function M.dismiss(bufnr)
  local completor = capability.active[bufnr]

  if not completor then
    return
  end

  completor:abort()
  M.clear_pending(bufnr)
end

--- Accept the current inline completion suggestion.
--- Returns true if a suggestion was accepted, false otherwise.
function M.accept(bufnr)
  return inline_completion.get({ bufnr = bufnr })
end

--- Cycle to the next inline completion suggestion.
function M.select(bufnr)
  inline_completion.select({ bufnr = bufnr })
end

--- Check whether an inline completion suggestion is currently showing.
function M.is_active(bufnr)
  local completor = capability.active[bufnr]
  return completor ~= nil and completor.current ~= nil
end

local ns = vim.api.nvim_create_namespace("inline-assist.pending")
local pending_timer = nil

function M.is_pending()
  return pending_timer ~= nil
end

function M.show_pending(bufnr)
  M.clear_pending(bufnr)

  local frames = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }
  local idx = 0

  local function render()
    if not vim.api.nvim_buf_is_valid(bufnr) then
      M.clear_pending(bufnr)
      return
    end

    vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
    idx = idx % #frames + 1
    local cursor = vim.api.nvim_win_get_cursor(0)
    vim.api.nvim_buf_set_extmark(bufnr, ns, cursor[1] - 1, 0, {
      virt_text = { { " " .. frames[idx], "Comment" } },
      virt_text_pos = "eol",
      hl_mode = "combine",
      cursorline_hl_group = "",
    })
  end

  render()
  pending_timer = vim.uv.new_timer()
  pending_timer:start(80, 80, vim.schedule_wrap(render))
end

function M.clear_pending(bufnr)
  if pending_timer then
    pending_timer:stop()
    pending_timer:close()
    pending_timer = nil
  end
  vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
end

return M
