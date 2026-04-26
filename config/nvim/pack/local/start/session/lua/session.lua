local M = {}

local session_dir = vim.fn.stdpath("state") .. "/sessions"

local function session_file()
  return session_dir .. "/" .. vim.fn.getcwd():gsub("/", "%%") .. ".vim"
end

local function wipe_buftypes(...)
  local types = { ... }
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(buf) and vim.list_contains(types, vim.bo[buf].buftype) then
      vim.api.nvim_buf_delete(buf, { force = true })
    end
  end
end

function M.save()
  vim.fn.mkdir(session_dir, "p")
  wipe_buftypes("quickfix")
  vim.cmd("mksession! " .. vim.fn.fnameescape(session_file()))
end

function M.load()
  local f = session_file()
  if vim.fn.filereadable(f) == 1 then
    vim.cmd("source " .. vim.fn.fnameescape(f))
  end
end

return M
