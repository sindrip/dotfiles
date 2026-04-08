vim.g.mapleader = " "
vim.g.maplocalleader = " "

require("local-plugins")

vim.cmd.packadd("nvim.undotree")
vim.cmd.packadd("nvim.difftool")

-- UI
vim.o.number = true -- Show line numbers
vim.o.relativenumber = true -- Relative line numbers for easy jumping
vim.o.cursorline = true -- Highlight the current line

vim.api.nvim_create_autocmd("WinEnter", {
  callback = function()
    vim.wo.cursorline = true
  end,
})
vim.api.nvim_create_autocmd("FocusGained", {
  callback = function()
    vim.wo.cursorline = true
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      local buf = vim.api.nvim_win_get_buf(win)
      local ft = vim.bo[buf].filetype
      if ft == "NvimTree" or ft == "fyler" then
        vim.wo[win].cursorline = true
      end
    end
  end,
})
vim.api.nvim_create_autocmd("WinLeave", {
  callback = function()
    if vim.bo.filetype == "NvimTree" or vim.bo.filetype == "fyler" then
      return
    end
    vim.wo.cursorline = false
  end,
})
vim.api.nvim_create_autocmd("FocusLost", {
  callback = function()
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      vim.wo[win].cursorline = false
    end
  end,
})
vim.o.signcolumn = "no" -- Hide sign column (signs rendered in statuscolumn)
vim.o.statuscolumn = "%!v:lua.StatusColumn()"
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

vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function()
    vim.hl.on_yank()
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  callback = function()
    vim.opt_local.formatoptions:remove("o")
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "NvimTree",
  callback = function()
    vim.schedule(function()
      vim.wo.winhighlight = ""
    end)
  end,
})

function _G.StatusColumn()
  local buf = vim.api.nvim_win_get_buf(vim.g.statusline_winid)
  local marks = vim.api.nvim_buf_get_extmarks(
    buf,
    -1,
    { vim.v.lnum - 1, 0 },
    { vim.v.lnum - 1, -1 },
    { details = true, type = "sign" }
  )

  local diag_text, diag_hl = "", ""
  local git_text, git_hl = "", ""
  for _, mark in ipairs(marks) do
    local d = mark[4]
    if d then
      local text = (d.sign_text or ""):gsub("%s", "")
      local hl = d.sign_hl_group or ""
      if hl:find("GitSigns") then
        git_text, git_hl = text, hl
      else
        diag_text, diag_hl = text, hl
      end
    end
  end

  local mark_text, mark_hl = "", ""
  for _, m in ipairs(vim.fn.getmarklist(buf)) do
    if m.pos[2] == vim.v.lnum and m.mark:match("^'[a-zA-Z]$") then
      mark_text, mark_hl = m.mark:sub(2, 2), "DiagnosticSignHint"
      break
    end
  end
  if mark_text == "" then
    for _, m in ipairs(vim.fn.getmarklist()) do
      if m.pos[1] == buf and m.pos[2] == vim.v.lnum and m.mark:match("^'[A-Z]$") then
        mark_text, mark_hl = m.mark:sub(2, 2), "DiagnosticSignHint"
        break
      end
    end
  end
  local function cell(text, hl, width)
    local dw = vim.fn.strdisplaywidth(text)
    local pad = string.rep(" ", math.max(0, width - dw))
    if hl ~= "" then
      return "%#" .. hl .. "#" .. text .. "%*" .. pad
    end
    return pad
  end

  if vim.v.virtnum ~= 0 then
    return cell("", "", 2) .. "%=" .. "  " .. cell("", "", 2)
  end
  local win = vim.g.statusline_winid
  local nu = vim.wo[win].number
  local rnu = vim.wo[win].relativenumber
  if not nu and not rnu then
    return ""
  end
  local left_text = diag_text ~= "" and diag_text or mark_text
  local left_hl = diag_text ~= "" and diag_hl or mark_hl
  local num = ""
  if nu or rnu then
    num = vim.v.relnum == 0 and vim.v.lnum or vim.v.relnum
  end
  return cell(left_text, left_hl, 2) .. "%=" .. num .. " " .. cell(git_text, git_hl, 2)
end

vim.diagnostic.config({
  -- jump = { on_jump = function() vim.diagnostic.open_float() end },
  jump = { float = true },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "",
      [vim.diagnostic.severity.WARN] = "",
      [vim.diagnostic.severity.INFO] = "",
      [vim.diagnostic.severity.HINT] = "",
    },
  },
  virtual_text = { current_line = true },
  -- virtual_text = true,
  status = {
    format = function(counts)
      local signs = vim.diagnostic.config().signs.text
      local hl_map = {
        [vim.diagnostic.severity.ERROR] = "DiagnosticSignError",
        [vim.diagnostic.severity.WARN] = "DiagnosticSignWarn",
        [vim.diagnostic.severity.INFO] = "DiagnosticSignInfo",
        [vim.diagnostic.severity.HINT] = "DiagnosticSignHint",
      }
      local items = {}
      for level, _ in ipairs(vim.diagnostic.severity) do
        local count = counts[level] or 0
        if count > 0 then
          table.insert(items, ("%%#%s#%s %s"):format(hl_map[level], signs[level], count))
        end
      end
      return table.concat(items, " ")
    end,
  },
})

vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0

-- Plugins

local pack = require("pack-specs")
pack.register_commands()

pack.add({
  {
    "https://github.com/nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
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
    end,
  },
  { "https://github.com/mason-org/mason.nvim", opts = {} },
  {
    "https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim",
    opts = {
      ensure_installed = {
        "lua-language-server",
        "stylua",
        "vtsls",
        "copilot-language-server",
      },
    },
  },
  { "https://github.com/folke/lazydev.nvim", opts = {} },
  {
    "https://github.com/A7Lavinraj/fyler.nvim",
    branch = "stable",
    opts = {
      views = {
        finder = {
          close_on_select = false,
          columns = {
            permission = { enabled = false },
            size = { enabled = false },
            link = { enabled = false },
            git = {
              symbols = {
                Untracked = "󰐕",
                Added = "󰐕",
                Modified = "󰦒",
                Deleted = "󰍴",
                Renamed = "󰑕",
                Copied = "󰆏",
                Conflict = "󰅗",
                Ignored = "",
              },
            },
            diagnostic = {
              symbols = {
                Error = "E",
                Warn = "W",
                Info = "I",
                Hint = "H",
              },
            },
          },
          follow_current_file = true,
          watcher = { enabled = true },
          win = {
            kinds = {
              split_left_most = { width = "20%" },
            },
          },
        },
      },
    },
  },
  {
    "https://github.com/nvim-tree/nvim-tree.lua",
    module = "nvim-tree",
    opts = {
      renderer = {
        -- root_folder_label = false,
        group_empty = true,
        indent_markers = { enable = true },
        -- highlight_opened_files = "name",
        -- highlight_git = "name",
        icons = {
          git_placement = "after",
          show = { folder_arrow = false },
          glyphs = {
            git = {
              unstaged = "󰦒",
              staged = "󰐕",
              untracked = "󰐕",
              deleted = "󰍴",
              renamed = "󰑕",
              ignored = "",
            },
          },
        },
      },
      view = { signcolumn = "no", width = 40 },
      update_focused_file = { enable = true },
      filters = { dotfiles = false, git_ignored = false, custom = { "node_modules" } },
    },
  },
  {
    "https://github.com/catppuccin/nvim",
    config = function()
      require("catppuccin").setup({
        transparent_background = true,
        dim_inactive = {
          enabled = true,
          shade = "dark",
          percentage = 0.15,
        },
      })
      vim.cmd.colorscheme("catppuccin-frappe")
    end,
  },
  { "https://github.com/folke/which-key.nvim", opts = {} },
  -- "https://github.com/b0o/SchemaStore.nvim",
  {
    "https://github.com/saghen/blink.cmp",
    version = vim.version.range("1"),
    opts = {
      keymap = { preset = "default" },
      appearance = { nerd_font_variant = "mono" },
      completion = { documentation = { auto_show = true } },
      sources = { default = { "lsp", "path", "snippets", "buffer" } },
      fuzzy = {
        implementation = "prefer_rust",
        prebuilt_binaries = { force_version = "v1.*" },
      },
    },
  },
  {
    "https://github.com/echasnovski/mini.icons",
    config = function()
      require("mini.icons").setup()
      MiniIcons.mock_nvim_web_devicons()
    end,
  },
  -- {
  --   "https://github.com/echasnovski/mini.notify",
  --   opts = {
  --     window = {
  --       config = { border = "rounded" },
  --       winblend = 75,
  --     },
  --   },
  -- },
  {
    "https://github.com/lewis6991/gitsigns.nvim",
    opts = {
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
    },
  },
  "https://github.com/sindrets/diffview.nvim",
  "https://github.com/neovim/nvim-lspconfig",
  "https://github.com/sindrip/formatls.nvim",
  "https://github.com/sindrip/todocomments-ls.nvim",
  "https://github.com/sindrip/fixpoint.nvim",
  "https://github.com/MeanderingProgrammer/render-markdown.nvim",
  { "https://github.com/folke/trouble.nvim", opts = {} },
  {
    "https://github.com/ibhagwan/fzf-lua",
    config = function()
      require("fzf-lua").register_ui_select()
    end,
  },
  {
    "https://github.com/nvim-lualine/lualine.nvim",
    config = function()
      local icon_copilot = string.char(0xEF, 0x92, 0xB8)
      local icon_copilot_err = string.char(0xEF, 0x92, 0xB9)
      local icon_check = string.char(0xEF, 0x80, 0x8C)

      local function copilot_status()
        for _, client in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
          if client.name == "copilot" then
            return icon_copilot
          end
        end
        return icon_copilot_err
      end

      local function copilot_color()
        for _, client in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
          if client.name == "copilot" then
            return nil
          end
        end
        return { fg = "#737994" }
      end

      local function copilot_click()
        local clients = vim.lsp.get_clients({ name = "copilot" })
        if #clients > 0 then
          for _, client in ipairs(clients) do
            client:stop()
          end
        else
          vim.lsp.enable("copilot")
        end
        vim.cmd.redrawstatus()
      end

      local function formatter_status()
        for _, client in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
          if client.name == "formatls" then
            return icon_check .. " formatls"
          end
        end
        return ""
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
            { "lsp_status", ignore_lsp = { "copilot", "fixpoint_fswatcher", "formatls", "todocomments-ls" } },
          },
          lualine_y = { "progress", "location" },
          lualine_z = { "branch" },
        },
      })
    end,
  },
  {
    "https://github.com/rachartier/tiny-cmdline.nvim",
    config = function()
      vim.o.cmdheight = 0
      require("tiny-cmdline").setup()
    end,
  },
  -- { "https://github.com/Cannon07/claude-preview.nvim", opts = {} },
  {
    "https://github.com/akinsho/toggleterm.nvim",
    opts = {
      open_mapping = [[<C-\>]],
      direction = "horizontal",
      size = 20,
    },
  },
})

vim.lsp.config.vtsls = {
  settings = {
    typescript = {
      inlayHints = {
        parameterNames = { enabled = "literals" },
        parameterTypes = { enabled = true },
        variableTypes = { enabled = true },
        propertyDeclarationTypes = { enabled = true },
        functionLikeReturnTypes = { enabled = true },
        enumMemberValues = { enabled = true },
      },
    },
  },
}

vim.lsp.enable("fixpoint_fswatcher")
vim.lsp.enable("todocomments-ls")
vim.lsp.enable("formatls")

vim.lsp.enable("copilot")
vim.lsp.enable("vtsls")
vim.lsp.enable("lua_ls")
vim.lsp.enable("rust_analyzer")
vim.lsp.enable("gopls")

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

vim.api.nvim_create_autocmd("UIEnter", {
  once = true,
  callback = function()
    require("vim._core.ui2").enable({})
  end,
})
-- vim.o.diffopt = vim.o.diffopt .. ",inline:word"  -- word-level inline diff highlighting

vim.g.auto_format = true

vim.api.nvim_create_autocmd("BufWritePre", {
  callback = function(args)
    if not vim.g.auto_format then
      return
    end
    vim.lsp.buf.format({ bufnr = args.buf, timeout_ms = 500 })
  end,
})

vim.api.nvim_create_user_command("LspLog", function()
  vim.cmd.edit(vim.lsp.log.get_filename())
end, { desc = "Open LSP log file" })

-- Keymaps

vim.keymap.set("n", "<leader>r", function()
  -- Close plugin buffers before saving session (plugin state isn't serialisable)
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    local ft = vim.bo[buf].filetype
    if ft == "fyler" or ft == "NvimTree" then
      vim.api.nvim_buf_delete(buf, { force = true })
    end
  end
  local session = vim.fn.stdpath("state") .. "/restart.vim"
  vim.cmd.mksession({ args = { session }, bang = true })
  vim.cmd.restart({ args = { "source", session } })
end, { desc = "Restart nvim with session" })

vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<cr>", { desc = "Clear search highlight" })

vim.keymap.set("n", "<leader>u", "<cmd>Undotree<cr>", { desc = "Undotree" })
vim.keymap.set("n", "<leader>x", "<cmd>Trouble diagnostics toggle<cr>", { desc = "Diagnostics (Trouble)" })

vim.keymap.set("n", "<leader>ff", "<cmd>FzfLua files<cr>", { desc = "Find files" })
vim.keymap.set("n", "<leader>fg", "<cmd>FzfLua live_grep<cr>", { desc = "Live grep" })
vim.keymap.set("n", "<leader>fh", "<cmd>FzfLua helptags<cr>", { desc = "Help tags" })

vim.keymap.set({ "n", "x" }, "j", function()
  return vim.v.count == 0 and "gj" or "j"
end, { expr = true })
vim.keymap.set({ "n", "x" }, "k", function()
  return vim.v.count == 0 and "gk" or "k"
end, { expr = true })

vim.keymap.set("n", "grA", function()
  vim.lsp.buf.code_action({ context = { only = { "source" }, diagnostics = {} } })
end, { desc = "Source actions" })

vim.keymap.set("n", "<leader>e", function()
  require("fyler").toggle({ kind = "split_left_most" })
end, { desc = "Toggle fyler" })
vim.keymap.set("n", "<leader>E", "<cmd>NvimTreeToggle<cr>", { desc = "Toggle nvim-tree" })

vim.keymap.set("n", "<leader>th", function()
  local enabled = not vim.lsp.inlay_hint.is_enabled()
  vim.lsp.inlay_hint.enable(enabled)
  vim.notify("Inlay hints: " .. (enabled and "on" or "off"))
end, { desc = "Toggle inlay hints" })

local Terminal = require("toggleterm.terminal").Terminal

local lazygit = Terminal:new({
  cmd = "lazygit",
  dir = "git_dir",
  direction = "float",
  float_opts = {
    border = "rounded",
    width = function()
      return math.floor(vim.o.columns * 0.9)
    end,
    height = function()
      return math.floor(vim.o.lines * 0.9)
    end,
  },
  on_open = function(term)
    vim.cmd("startinsert!")
    vim.keymap.set("t", "<Esc>", "<Esc>", { buffer = term.bufnr })
  end,
  on_close = function(term)
    vim.cmd("startinsert!")
  end,
})

local lazydocker = Terminal:new({
  cmd = "lazydocker",
  direction = "float",
  float_opts = {
    border = "rounded",
  },
})

vim.keymap.set("n", "<leader>gg", function()
  lazygit:toggle()
end, { desc = "Lazygit" })
vim.keymap.set("n", "<leader>gd", function()
  lazydocker:toggle()
end, { desc = "Lazydocker" })

-- vim.keymap.set("n", "<leader>gg", function()
--   require("toggleterm.terminal").Terminal
--     :new({
--       cmd = "lazygit",
--       direction = "float",
--       float_opts = {
--         width = math.floor(vim.o.columns * 0.9),
--         height = math.floor(vim.o.lines * 0.9),
--         -- width = vim.o.columns,
--         -- height = vim.o.lines,
--       },
--     })
--     :toggle()
-- end, { desc = "Lazygit" })

vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
vim.keymap.set("t", "<C-h>", function()
  vim.cmd.wincmd("h")
end, { desc = "Move to left split" })
vim.keymap.set("t", "<C-j>", function()
  vim.cmd.wincmd("j")
end, { desc = "Move to below split" })
vim.keymap.set("t", "<C-k>", function()
  vim.cmd.wincmd("k")
end, { desc = "Move to above split" })
vim.keymap.set("t", "<C-l>", function()
  vim.cmd.wincmd("l")
end, { desc = "Move to right split" })

vim.keymap.set("n", "<leader>tf", function()
  vim.g.auto_format = not vim.g.auto_format
  vim.notify("Auto format: " .. (vim.g.auto_format and "on" or "off"))
end, { desc = "Toggle auto format" })

vim.keymap.set("n", "<leader>tc", function()
  local enabled = not vim.lsp.inline_completion.is_enabled()
  vim.lsp.inline_completion.enable(enabled)
  vim.notify("Copilot inline completion: " .. (enabled and "on" or "off"))
end, { desc = "Toggle Copilot inline completion" })
