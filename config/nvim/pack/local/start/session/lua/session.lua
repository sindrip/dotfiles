local M = {}

local session_dir = vim.fn.stdpath("state") .. "/sessions"

local function session_file()
  return session_dir .. "/" .. vim.fn.getcwd():gsub("/", "%%") .. ".vim"
end

function M.save()
  vim.fn.mkdir(session_dir, "p")
  vim.cmd("mksession! " .. vim.fn.fnameescape(session_file()))
end

function M.load()
  local f = session_file()
  if vim.fn.filereadable(f) == 1 then
    vim.cmd("source " .. vim.fn.fnameescape(f))
  end
end

return M
