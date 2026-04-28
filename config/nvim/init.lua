vim.g.mapleader = " "
vim.g.maplocalleader = " "

require("local-plugins")

-- UI
vim.o.number = true -- Show line numbers
vim.o.relativenumber = true -- Relative line numbers for easy jumping
vim.o.smoothscroll = true

vim.o.laststatus = 3 -- Single global statusline
-- vim.o.winborder = "🭽,▔,🭾,▕,🭿,▁,🭼,▏"
-- vim.o.winborder = "rounded"
vim.o.colorcolumn = "100" -- Highlight column 100
vim.o.scrolloff = 8 -- Keep 8 lines visible above/below cursor
vim.o.list = true -- Show whitespace characters
vim.opt.listchars = { tab = "→ ", trail = "·", nbsp = "␣" }

-- Editing
vim.o.expandtab = true -- Spaces instead of tabs
vim.o.shiftwidth = 2 -- 2-space indentation
vim.o.tabstop = 2 -- 2-space tabs
vim.o.breakindent = true -- Wrapped lines preserve indentation
vim.o.undofile = true -- Persist undo history across sessions
vim.o.swapfile = false -- No swap files
vim.o.confirm = true -- Prompt instead of error on :q with unsaved changes

-- Search
vim.o.ignorecase = true -- Case-insensitive search...
vim.o.smartcase = true -- ...unless search contains capitals
vim.o.inccommand = "split" -- Live preview of :s substitutions

-- Splits
vim.o.splitright = true -- Vertical splits open to the right
vim.o.splitbelow = true -- Horizontal splits open below

-- Folds
vim.o.foldlevelstart = 99 -- Start with all folds open
vim.o.foldtext = "" -- Use highlighted fold text (no summary line)
vim.o.foldnestmax = 3

-- Timing
vim.o.updatetime = 250 -- Faster CursorHold events (default 4000ms)
vim.o.timeoutlen = 300 -- Time to wait for mapped sequence (default 1000ms)

vim.api.nvim_create_autocmd("FileType", {
  callback = function()
    vim.opt_local.formatoptions:remove("o")
  end,
})

require("diagnostics")

vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0

-- Plugins

require("pack-hooks")

-- Built-in plugins that are disabled by default
vim.cmd.packadd("nvim.undotree")
vim.cmd.packadd("nvim.difftool")

-- External plugins
vim.pack.add({
  "https://github.com/saghen/blink.download",
  "https://github.com/sindrets/diffview.nvim",
  "https://github.com/neovim/nvim-lspconfig",
  "https://github.com/sindrip/fixpoint.nvim",
  "https://github.com/MeanderingProgrammer/render-markdown.nvim",
  "https://github.com/stevearc/conform.nvim",
  "https://github.com/nvim-lualine/lualine.nvim",
  "https://github.com/folke/which-key.nvim",
  "https://github.com/mason-org/mason.nvim",
  "https://github.com/folke/lazydev.nvim",
  {
    src = "https://github.com/nvim-treesitter/nvim-treesitter",
    data = {
      build = function()
        vim.cmd("TSUpdate")
      end,
    },
  },
  { src = "https://github.com/saghen/blink.pairs", version = "v0.5.0" },
  "https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim",
  "https://github.com/folke/snacks.nvim",
  "https://github.com/catppuccin/nvim",
  { src = "https://github.com/saghen/blink.cmp", version = vim.version.range("1") },
  "https://github.com/echasnovski/mini.icons",
  "https://github.com/lewis6991/gitsigns.nvim",
  "https://github.com/stevearc/quicker.nvim",
  "https://github.com/rachartier/tiny-cmdline.nvim",
}, { confirm = false })

require("formatter").setup()
require("statusline").setup()
require("which-key").setup({})
require("mason").setup({})
require("lazydev").setup({})
require("blink.pairs").setup({})

local ts = require("nvim-treesitter")

vim.api.nvim_create_autocmd("FileType", {
  callback = function(args)
    local lang = vim.treesitter.language.get_lang(args.match)
    if not lang then
      return
    end
    if not vim.treesitter.language.add(lang) then
      if vim.list_contains(ts.get_available(), lang) then
        ts.install(lang)
      end
      return
    end

    vim.treesitter.start(args.buf, lang)
    vim.wo[0][0].foldmethod = "expr"
    vim.wo[0][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
    vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
  end,
})

require("mason-tool-installer").setup({
  ensure_installed = {
    "copilot-language-server",
    "gopls",
    "lua-language-server",
    "prettier",
    "shfmt",
    "stylua",
    "tsgo",
    "vtsls",
  },
})

require("snacks").setup({
  bigfile = { enabled = true },
  bufdelete = { enabled = true },
  explorer = { enabled = true },
  lazygit = {
    configure = false,
    win = { width = 0.95, height = 0.95 },
  },
  picker = {
    enabled = true,
    sources = {
      explorer = {
        hidden = true,
        ignored = true,
        exclude = { ".git", "node_modules" },
      },
    },
  },
  statuscolumn = { enabled = true },
})

require("catppuccin").setup({
  transparent_background = true,
  float = { transparent = true, solid = false },
  dim_inactive = {
    enabled = true,
    shade = "dark",
    percentage = 0.15,
  },
  custom_highlights = function(C)
    return {
      BlinkPairsOrange = { fg = C.peach },
      BlinkPairsPurple = { fg = C.mauve },
      BlinkPairsBlue = { fg = C.blue },
      BlinkPairsUnmatched = { fg = C.red },
    }
  end,
})
vim.cmd.colorscheme("catppuccin-frappe")

require("blink.cmp").setup({
  keymap = {
    preset = "default",
    ["<M-.>"] = { "show", "show_documentation", "hide_documentation" },
  },
  appearance = { nerd_font_variant = "mono" },
  completion = {
    documentation = { auto_show = true },
    menu = { auto_show = false },
  },
  sources = { default = { "lsp", "path", "snippets", "buffer" } },
  signature = { enabled = true },
  fuzzy = {
    implementation = "prefer_rust",
    prebuilt_binaries = { force_version = "v1.*" },
  },
})

local MiniIcons = require("mini.icons")
MiniIcons.setup()
MiniIcons.mock_nvim_web_devicons()

require("gitsigns").setup({
  signs = {
    add = { text = "▎" },
    change = { text = "▎" },
    delete = { text = "_" },
    topdelete = { text = "‾" },
    changedelete = { text = "▎" },
    untracked = { text = "▎" },
  },
  signs_staged = {
    add = { text = "▎" },
    change = { text = "▎" },
    delete = { text = "_" },
    topdelete = { text = "‾" },
    changedelete = { text = "▎" },
  },
})

require("quicker").setup({
  keys = {
    {
      ">",
      function()
        require("quicker").expand({ add_to_existing = true })
      end,
      desc = "Expand quickfix context",
    },
    {
      "<",
      function()
        require("quicker").collapse()
      end,
      desc = "Collapse quickfix context",
    },
  },
})

---@diagnostic disable-next-line: missing-fields
require("tiny-cmdline").setup({
  on_reposition = require("tiny-cmdline").adapters.blink,
})

vim.lsp.config("tsgo", {
  capabilities = {
    general = {
      -- Match vtsls/Copilot so attached TS clients agree on LSP offsets.
      positionEncodings = { "utf-16" },
    },
  },
})

vim.lsp.enable("copilot")
vim.lsp.enable("lua_ls")
vim.lsp.enable("rust_analyzer")
vim.lsp.enable("gopls")
vim.lsp.enable("tsgo")
vim.lsp.enable("vtsls")

-- Code Lens (0.12: renders as virtual lines, grx to run actions)
-- vim.lsp.codelens.enable(true)

-- 0.12 features that activate automatically when the LSP server supports them:
-- • documentColor        – inline color swatches (CSS, etc.)
-- • linkedEditingRange   – edit matching HTML tags simultaneously
-- • onTypeFormatting     – auto-format as you type
-- • selectionRange       – incremental selection (an/in in visual mode)
-- • inlineCompletion     – ghost-text style completions
-- 0.12 features that can be enabled manually:
vim.lsp.inline_completion.enable()

vim.keymap.set("i", "<Tab>", function()
  if not vim.lsp.inline_completion.get() then
    return "<Tab>"
  end
end, { expr = true, desc = "Accept inline completion" })

vim.keymap.set("i", "<C-e>", function()
  vim.lsp.inline_completion.select()
end, { desc = "Next inline completion" })

-- vim.o.diffopt = vim.o.diffopt .. ",inline:word"  -- word-level inline diff highlighting

vim.api.nvim_create_user_command("LspLog", function()
  vim.cmd.edit(vim.lsp.log.get_filename())
end, { desc = "Open LSP log file" })

vim.api.nvim_create_user_command("LspInfo", function()
  vim.cmd.checkhealth("vim.lsp")
end, { desc = "Show LSP info" })

vim.api.nvim_create_user_command("LspRestart", function()
  for _, c in ipairs(vim.lsp.get_clients()) do
    c:_restart()
  end
end, { desc = "Restart LSP clients" })

-- Keymaps

vim.keymap.set("n", "<leader>r", function()
  require("session").save()
  vim.cmd.restart()
end, { desc = "Restart nvim" })

vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<cr>", { desc = "Clear search highlight" })

vim.keymap.set("n", "<leader>u", "<cmd>Undotree<cr>", { desc = "Undotree" })

vim.keymap.set("n", "grq", function()
  vim.diagnostic.setqflist()
end, { desc = "Diagnostics to quickfix" })

vim.keymap.set("n", "<leader>q", function()
  require("quicker").toggle()
end, { desc = "Toggle quickfix" })

vim.keymap.set("n", "<leader>l", function()
  require("quicker").toggle({ loclist = true })
end, { desc = "Toggle loclist" })

vim.keymap.set("n", "<leader>bd", function()
  require("snacks").bufdelete()
end, { desc = "Delete buffer (keep window)" })

vim.keymap.set("n", "<leader>ff", function()
  require("snacks").picker.files()
end, { desc = "Find files" })
vim.keymap.set("n", "<leader>fg", function()
  require("snacks").picker.grep()
end, { desc = "Live grep" })
vim.keymap.set("n", "<leader>fh", function()
  require("snacks").picker.help()
end, { desc = "Help tags" })
vim.keymap.set("n", "<leader>fb", function()
  require("snacks").picker.buffers()
end, { desc = "Buffers" })

vim.keymap.set("n", "<leader>e", function()
  require("snacks").explorer()
end, { desc = "Toggle snacks explorer" })

vim.keymap.set({ "n", "x" }, "j", function()
  return vim.v.count == 0 and "gj" or "j"
end, { expr = true })
vim.keymap.set({ "n", "x" }, "k", function()
  return vim.v.count == 0 and "gk" or "k"
end, { expr = true })

vim.keymap.set("n", "grA", function()
  vim.lsp.buf.code_action({ context = { only = { "source" }, diagnostics = {} } })
end, { desc = "Source actions" })

vim.keymap.set("n", "<leader>th", function()
  local enabled = not vim.lsp.inlay_hint.is_enabled()
  vim.lsp.inlay_hint.enable(enabled)
  vim.notify("Inlay hints: " .. (enabled and "on" or "off"))
end, { desc = "Toggle inlay hints" })

vim.keymap.set("n", "<leader>gg", function()
  require("snacks").lazygit()
end, { desc = "Lazygit" })

vim.keymap.set({ "n", "t" }, "<C-\\>", function()
  require("snacks").terminal.toggle(nil, { win = { position = "bottom", height = 0.3 } })
end, { desc = "Toggle terminal" })

vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
vim.keymap.set({ "n", "t" }, "<C-h>", function()
  vim.cmd.wincmd("h")
end, { desc = "Move to left split" })
vim.keymap.set({ "n", "t" }, "<C-j>", function()
  vim.cmd.wincmd("j")
end, { desc = "Move to below split" })
vim.keymap.set({ "n", "t" }, "<C-k>", function()
  vim.cmd.wincmd("k")
end, { desc = "Move to above split" })
vim.keymap.set({ "n", "t" }, "<C-l>", function()
  vim.cmd.wincmd("l")
end, { desc = "Move to right split" })

vim.keymap.set("n", "<leader>tf", function()
  require("formatter").toggle()
end, { desc = "Toggle auto format" })

vim.keymap.set("n", "<leader>tc", function()
  local enabled = not vim.lsp.inline_completion.is_enabled()
  vim.lsp.inline_completion.enable(enabled)
  vim.notify("Copilot inline completion: " .. (enabled and "on" or "off"))
end, { desc = "Toggle Copilot inline completion" })
