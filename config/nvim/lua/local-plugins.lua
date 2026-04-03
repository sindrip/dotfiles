-- Local plugin overrides. Prepended to runtimepath so they
-- take precedence over remote installs via vim.pack.add.

local plugins = {
  -- Add local plugin paths here.
  -- "~/projects/formatls.nvim",
}

for _, path in ipairs(plugins) do
  vim.opt.runtimepath:prepend(vim.fn.expand(path))
end
