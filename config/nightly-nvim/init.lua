local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out,                            "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-----------------------
-- Options
-----------------------
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Interesting thing to look at
-- vim.o.virtualedit = "block"

-- Search options
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.inccommand = "split"

-- Indentation
vim.o.shiftwidth = 4
vim.o.tabstop = 4
vim.o.expandtab = true

-- Can't live without this
vim.o.undofile = true

vim.o.number = true
vim.o.relativenumber = true
vim.o.signcolumn = "yes"
vim.o.cursorline = true
vim.o.list = true
vim.opt.listchars = {
  tab = "→ ",
  nbsp = "␣",
  trail = "·",
  -- space = "·",
  extends = "⟩",
  precedes = "⟨",
}
-- vim.o.wrap = false

-- Splits
-- vim.o.splitkeep = 'screen'
vim.o.splitbelow = true
vim.o.splitright = true

-- Status line
vim.o.laststatus = 3
vim.o.cmdheight = 1

vim.o.scrolloff = 8
vim.o.sidescrolloff = 5

-- vim.opt.completeopt = { "menu", "menuone", "noselect" }
vim.opt.completeopt = { "menu", "menuone", "noselect" }

-- vim.o.winborder = "rounded"

-- Folds
-- vim.o.foldcolumn = "1"
vim.o.foldlevel = 99
vim.o.foldnestmax = 3
vim.opt.fillchars:append({ fold = " " })
vim.o.foldtext = ""

-- Disable health checks for these providers
vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_python3_provider = 0
---------------------------------------------------------------------------
---------------------------------------------------------------------------
---------------------------------------------------------------------------
---------------------------------------------------------------------------
---------------------------------------------------------------------------
require("lazy").setup({
  change_detection = {
    notify = false, -- get a notification when changes are found
  },
  rocks = {
    enabled = false
  },
  spec = {
    { import = "plugins" },

    -- {
    --   "folke/noice.nvim",
    --   opts = {
    --     lsp = {
    --       -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
    --       override = {
    --         ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
    --         ["vim.lsp.util.stylize_markdown"] = true,
    --         ["cmp.entry.get_documentation"] = true, -- requires hrsh7th/nvim-cmp
    --       },
    --     },
    --     -- you can enable a preset for easier configuration
    --     presets = {
    --       bottom_search = true,         -- use a classic bottom cmdline for search
    --       command_palette = true,       -- position the cmdline and popupmenu together
    --       long_message_to_split = true, -- long messages will be sent to a split
    --       inc_rename = false,           -- enables an input dialog for inc-rename.nvim
    --       lsp_doc_border = false,       -- add a border to hover docs and signature help
    --     },
    --   }
    -- },

    "folke/tokyonight.nvim",
    {
      "EdenEast/nightfox.nvim",
      -- lazy = false,
      config = function()
        vim.cmd.colorscheme("nordfox")
      end,
    },

    {
      "stevearc/oil.nvim",
      opts = {
        columns = {
          "icon",
          -- "permissions",
          -- "size",
          -- "mtime",
        },
      },
      keys = {
        { "<leader>e",
          function() vim.cmd.Oil("--float") end, }
      }
    },

    {
      "nvim-lualine/lualine.nvim",
      opts = {
        tabline = {
          lualine_a = { "tabs" },
          lualine_b = {},
          lualine_c = {},
          lualine_x = {},
          lualine_y = {},
          lualine_z = { "buffers" }
        }
      }
    },

    {
      "nvim-mini/mini.nvim",
      version = "*",
      config = function()
        require("mini.surround").setup()
        -- require("mini.files").setup()
        require("mini.bufremove").setup()
      end
    },

    { "mason-org/mason.nvim", opts = {} },

    {
      "stevearc/quicker.nvim",
      opts = {},
      keys = {
        {
          "<leader>q",
          function()
            local q = require("quicker")
            q.toggle()
          end,
          desc = "Toggle quickfix"
        },
        -- {
        --   "<leader>qd",
        --   function()
        --     local quicker = require "quicker"
        --
        --     if quicker.is_open() then
        --       quicker.close()
        --     else
        --       vim.diagnostic.setqflist()
        --       quicker.refresh(nil, { keep_diagnostics = true })
        --     end
        --   end,
        --   desc = "Toggle Diagnostics"
        -- }
        {
          ">",
          function()
            require("quicker").expand({ before = 2, after = 2, add_to_existing = true })
          end,
          desc = "Expand quickfix context",
        },
        -- {
        --     "<",
        --     function()
        --         require("quicker").collapse()
        --     end,
        --     desc = "Collapse quickfix context",
        -- },
      }
    },

    { "folke/sidekick.nvim", opts = {} }, -- TODO

    {
      "folke/which-key.nvim",
      opts = {
        -- preset = "modern"
        preset = "helix",
        spec = {
          { "<leader>f", group = "find" },
          { "<leader>q", group = "quickfix" },
          { "<leader>t", group = "toggle" },
        }
      }
    },

    -- {
    --   "A7Lavinraj/fyler.nvim",
    --   -- dir = "~/projects/fyler.nvim",
    --   -- dependencies = { "nvim-mini/mini.icons" },
    --   -- branch = "stable", -- Use stable branch for production
    --   lazy = false, -- Necessary for `default_explorer` to work properly
    --   opts = {
    --     views = {
    --       finder = {
    --         default_explorer = true,
    --         win = {
    --           win_opts = {
    --             -- number = true
    --             cursorline = true
    --           }
    --         }
    --       }
    --     }
    --   },
    --   keys = {
    --     {
    --       "<leader>e",
    --       function()
    --         require("fyler").toggle({
    --           kind = "split_left_most",
    --         })
    --       end,
    --       desc = "Toggle fyler view"
    --     },
    --     {
    --       "<leader>-",
    --       function() require("fyler").open({ kind = "float" }) end
    --
    --     }
    --   },
    --   init = function()
    --     vim.api.nvim_create_autocmd("FileType", {
    --       group = vim.api.nvim_create_augroup("sindrip/fyler_spacing", { clear = true }),
    --       pattern = "fyler",
    --       callback = function()
    --         vim.cmd.wincmd("=")
    --       end,
    --     })
    --   end
    -- },

    -- {
    --   "ibhagwan/fzf-lua",
    --   lazy = false,
    --   keys = {
    --     { "<leader>ff", "<cmd>FzfLua files<cr>",     desc = "Find files" },
    --     { "<leader>fg", "<cmd>FzfLua live_grep<cr>", desc = "Find grep" },
    --     { "<leader>fb", "<cmd>FzfLua buffers<cr>",   desc = "Find buffers" },
    --     { "<leader>fh", "<cmd>FzfLua helptags<cr>",  desc = "Find help tags" },
    --     { "<leader>fk", "<cmd>FzfLua keymaps<cr>",   desc = "Find keymaps" },
    --     { "<leader>fp", "<cmd>FzfLua profiles<cr>",  desc = "Find profiles" },
    --     { "<leader>fu", "<cmd>FzfLua undotree<cr>",  desc = "Find undotree" },
    --   },
    --   opts = {
    --     "ivy",
    --     winopts = {
    --       border = "rounded",
    --       height = 0.75,
    --       preview = {
    --         border = "rounded",
    --         layout = "horizontal",
    --         horizontal = "right:50%",
    --       },
    --     },
    --   },
    --   config = function(_, opts)
    --     require("fzf-lua").setup(opts)
    --     require("fzf-lua").register_ui_select()
    --   end,
    -- },

    {
      "nvim-telescope/telescope.nvim",
      version = "*",
      dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-tree/nvim-web-devicons",
        -- optional but recommended
        { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
      },
      keys = {
        { "<leader>ff", "v:lua require('telescope.builtin').find_files()<cr>", desc = "Find files" },
        { "<leader>fg", "v:lua require('telescope.builtin').live_grep()<cr>",  desc = "Find grep" },
        { "<leader>fb", "v:lua require('telescope.builtin').buffers()<cr>",    desc = "Find buffers" },
        { "<leader>fh", "v:lua require('telescope.builtin').help_tags()<cr>",  desc = "Find help tags" },
        -- { "<leader>fk", "<cmd>FzfLua keymaps<cr>",                       desc = "Find keymaps" },
        -- { "<leader>fp", "<cmd>FzfLua profiles<cr>",                      desc = "Find profiles" },
        -- { "<leader>fu", "<cmd>FzfLua undotree<cr>",                      desc = "Find undotree" },
      },
    },

    {
      "folke/snacks.nvim",
      priority = 1000,
      lazy = false,
      ---@type snacks.Config
      opts = {
        -- your configuration comes here
        -- or leave it empty to use the default settings
        -- refer to the configuration section below
        -- bigfile = { enabled = true },
        -- dashboard = { enabled = true },
        -- explorer = { enabled = true },
        -- indent = { enabled = true },
        input = { enabled = true },
        picker = { enabled = true },
        -- notifier = { enabled = true },
        -- quickfile = { enabled = true },
        -- scope = { enabled = true },
        -- scroll = { enabled = true },
        -- statuscolumn = { enabled = true },
        -- words = { enabled = true },
      },
    },

    {
      "saghen/blink.cmp",
      dependencies = { "rafamadriz/friendly-snippets" },
      version = "1.*",
      ---@module 'blink.cmp'
      ---@diagnostic disable-next-line: undefined-doc-name
      ---@type blink.cmp.Config
      opts = {
        -- 'default' (recommended) for mappings similar to built-in completions (C-y to accept)
        -- C-k: Toggle signature help (if signature.enabled = true)
        keymap = { preset = "default" },
        appearance = {
          nerd_font_variant = "mono"
        },

        completion = {
          menu = { auto_show = true }, -- TODO: Add keybinding for this
          documentation = { auto_show = false },
          list = {
            selection = { preselect = false, auto_insert = false },
          },
          -- window = {
          --     completion = {
          --         border = "rounded", -- or "single", "double", etc.
          --         winhighlight =
          --         "Normal:NormalFloat,FloatBorder:NormalFloat,CursorLine:BlinkCmpMenuSelection,Search:None",
          --     },
          -- }
        },
        signature = { enabled = true },
        sources = {
          default = { "lsp", "path", "snippets", "buffer" },
        },
        fuzzy = { implementation = "prefer_rust_with_warning" }
      },
      opts_extend = { "sources.default" }
    },
  },
  -- Configure any other settings here. See the documentation for more details.
  -- colorscheme that will be used when installing plugins.
  install = { colorscheme = { "habamax" } },
  -- automatically check for plugin updates
  checker = { enabled = true, notify = false },
})
---------------------------------------------------------------------------
---------------------------------------------------------------------------
---------------------------------------------------------------------------
---------------------------------------------------------------------------
---------------------------------------------------------------------------
vim.lsp.enable({
  --     "copilot",
  "lua_ls",
  --     "rust_analyzer",
  "vtsls",
})
-- require("sidekick").setup({})


vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Scroll up and center" })
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Scroll down and center" })
vim.keymap.set("n", "n", "nzzzv", { desc = "Next search result and center" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Previous search result and center" })
vim.keymap.set("n", "<esc>", "<cmd>nohlsearch<cr>", { desc = "Clear search highlight" })
vim.keymap.set("n", "j", function() return vim.v.count > 0 and "j" or "gj" end,
  { expr = true, desc = "Easier upwards movement within wrapped lines" })
vim.keymap.set("n", "k", function() return vim.v.count > 0 and "k" or "gk" end,
  { expr = true, desc = "Easier upwards movement within wrapped lines" })

vim.api.nvim_create_user_command("RestartSession", function()
  local session = vim.fn.stdpath("state") .. "/Session.vim"
  vim.cmd.mksession({ args = { session }, bang = true })
  vim.cmd.restart({ args = { "source", session } })
end, { desc = "Reload Neovim", bang = true })

vim.api.nvim_create_user_command("ToggleInlayHints", function()
  local opts = { bufnr = 0 }
  vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled(opts), opts)
end, { desc = "Toggle InlayHints for buffer" })

vim.api.nvim_create_user_command("ToggleAutoFormat", function()
  vim.g.auto_format = not vim.g.auto_format
end, { desc = "Toggle AutoFormat globally" })

vim.keymap.set("n", "<leader>r", "<cmd>RestartSession<CR>", { desc = "Reload Neovim" })
vim.keymap.set("n", "<leader>th", "<cmd>ToggleInlayHints<cr>", { desc = "Toggle LSP inlay hints" })
vim.keymap.set("n", "<leader>tf", "<cmd>ToggleAutoFormat<cr>", { desc = "Toggle AutoFormat" })

vim.keymap.set("n", "<leader>x", "<cmd>.lua<CR>", { desc = "Execute the current line" })
vim.keymap.set("n", "<leader><leader>x", "<cmd>source %<CR>", { desc = "Execute the current file" })

-- UI related autocommands
local cursorline_group = vim.api.nvim_create_augroup("sindrip/cursorline", { clear = true })
vim.api.nvim_create_autocmd("WinEnter", {
  group = cursorline_group,
  desc = "Enable cursorline in active window",
  callback = function()
    vim.wo.cursorline = true
  end,
})
vim.api.nvim_create_autocmd("WinLeave", {
  group = cursorline_group,
  desc = "Disable cursorline when leaving",
  callback = function()
    vim.wo.cursorline = false
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("sindrip/auto_comments", { clear = true }),
  callback = function()
    vim.opt.formatoptions:remove({ "c", "r", "o" })
  end,
})

vim.api.nvim_create_autocmd("TextYankPost", {
  group = vim.api.nvim_create_augroup("sindrip/highlight_yank", { clear = true }),
  pattern = "*",
  desc = "highlight selection on yank",
  callback = function()
    vim.hl.on_yank({ timeout = 200 })
  end,
})

-- vim.lsp.config('*', {
-- 	capabilities = {
-- 		textDocument = {
-- 			semantic_tokens = nil
-- 		}
-- 	}
-- })

-- The updatetime is needed for cursorHold stuff (kind of)
vim.o.updatetime = 250
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local bufnr = args.buf
    local client = assert(vim.lsp.get_client_by_id(args.data.client_id))

    vim.keymap.set("n", "grA", function()
      vim.lsp.buf.code_action({
        ---@diagnostic disable-next-line: missing-fields
        context = { only = { "source" } },
      })
    end, { desc = "LSP: source actions", buffer = bufnr })


    if client:supports_method("textDocument/foldingRange") then
      -- local win = vim.api.nvim_get_current_win()
      -- vim.notify("Setting LSP folding _b:" .. bufnr .. ' _w: ' .. win)
      vim.wo[0][0].foldexpr = "v:lua.vim.lsp.foldexpr()"

      -- vim.wo.foldexpr = "v:lua.vim.lsp.foldexpr()"
    end

    -- Disable SemanticTokens and use built-in TreeSitter
    vim.lsp.semantic_tokens.enable(false)
    -- if client:supports_method('textDocument/semanticTokens') then
    -- vim.lsp.semantic_tokens.enable(false)
    -- end
    --
    -- if client:supports_method("textDocument/codeLens") then
    --     -- vim.notify(client.name .. " supports codeLens")
    -- end

    -- if client:supports_method("textDocument/inlayHint") then
    --     --     -- vim.defer_fn(function()
    --     --     -- print('inlay initial: ' .. tostring(vim.lsp.inlay_hint.is_enabled()))
    --     --     -- vim.lsp.inlay_hint.enable(vim.lsp.inlay_hint.is_enabled())
    --     -- vim.lsp.inlay_hint.enable(true)
    --     --     -- Set this client to the global state.
    --     --     -- vim.lsp.inlay_hint.enable(vim.lsp.inlay_hint.is_enabled())
    --     --     -- end, 100)
    -- end

    local enable_cursor_highlight = false
    if client:supports_method("textDocument/documentHighlight") and enable_cursor_highlight then
      local under_cursor_highlights_group =
          vim.api.nvim_create_augroup("mariasolos/cursor_highlights", { clear = false })
      vim.api.nvim_create_autocmd({ "CursorHold", "InsertLeave" }, {
        group = under_cursor_highlights_group,
        desc = "Highlight references under the cursor",
        buffer = bufnr,
        callback = vim.lsp.buf.document_highlight,
      })
      vim.api.nvim_create_autocmd({ "CursorMoved", "InsertEnter", "BufLeave" }, {
        group = under_cursor_highlights_group,
        desc = "Clear highlight references",
        buffer = bufnr,
        callback = vim.lsp.buf.clear_references,
      })
    end

    -- if client:supports_method("textDocument/completion") then
    --     -- Optional: trigger autocompletion on EVERY keypress. May be slow!
    --     local chars = {}
    --     for i = 32, 126 do
    --         table.insert(chars, string.char(i))
    --     end
    --     client.server_capabilities.completionProvider.triggerCharacters = chars
    --
    --     vim.lsp.completion.enable(true, client.id, args.buf, { autotrigger = true })
    -- end
    --
    if client:supports_method("textDocument/documentColor") then
      vim.lsp.document_color.enable(true, bufnr, { style = "background" })
      -- vim.lsp.document_color.enable(true, bufnr, { style = "virtual" })
      -- vim.lsp.document_color.
    end

    if client:supports_method("textDocument/formatting") then
      vim.keymap.set("n", "<leader>cf", function()
        vim.lsp.buf.format({ bufnr = bufnr })
      end, { desc = "LSP: format document", buffer = bufnr })
    end

    -- if client:supports_method('textDocument/inlineCompletion', bufnr) then
    if client:supports_method(vim.lsp.protocol.Methods.textDocument_inlineCompletion, bufnr) then
      vim.lsp.inline_completion.enable(true, { bufnr = bufnr })
      vim.keymap.set(
        "i",
        "<C-F>",
        vim.lsp.inline_completion.get,
        { desc = "LSP: accept inline completion", buffer = bufnr }
      )
      vim.keymap.set(
        "i",
        "<C-G>",
        vim.lsp.inline_completion.select,
        { desc = "LSP: switch inline completion", buffer = bufnr }
      )
    end
  end,
})

local original_handler = vim.lsp.handlers["$/progress"]
vim.lsp.handlers["$/progress"] = function(err, result, ctx, config)
  -- Call original handler first
  if original_handler then
    original_handler(err, result, ctx, config)
  end

  -- -- vim.notify(err)
  -- if result.value.kind == "begin" then
  --     -- vim.notify("begin")
  --     -- vim.lsp.inlay_hint.enable(vim.g.enable_inlay_hints)
  -- end
end

vim.diagnostic.config({
  -- virtual_text = true,
  virtual_text = { current_line = true },
  severity_sort = true,
  -- virtual_lines = {
  --   current_line = false
  -- }
})
-- The default keybindings don't open the float like they used to do.
vim.keymap.set("n", "[d", function() vim.diagnostic.jump({ count = -1, float = true }) end,
  { desc = "Go to previous diagnostic" })
vim.keymap.set("n", "]d", function() vim.diagnostic.jump({ count = 1, float = true }) end,
  { desc = "Go to next diagnostic" })

-- -- Quickfix
-- vim.keymap.set("n", "<leader>qd", function()
--     -- vim.cmd.cclose()
--     vim.diagnostic.setqflist()
--     -- vim.cmd.copen()
-- end, { desc = "Open quickfix with diagnostics" })

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "nvim-undotree", "help" },
  group = vim.api.nvim_create_augroup("sindrip/easy_close", { clear = true }),
  desc = "Easily close special buffers",
  callback = function(_args)
    -- vim.api.nvim_buf_set_keymap(args.buf, "n", "<esc>", "<cmd>close<cr>", { desc = "Close buffer" })
  end
})


require("vim._extui").enable({
  enable = true, -- Whether to enable or disable the UI.
  msg = {        -- Options related to the message module.
    ---@type 'cmd'|'msg' Where to place regular messages, either in the
    ---cmdline or in a separate ephemeral message window.
    -- target = "cmd",
    target = "cmd",
    timeout = 4000, -- Time a message is visible in the message window.
  },
})

vim.cmd.packadd("nvim.undotree")
