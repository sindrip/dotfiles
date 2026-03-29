vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- UI
vim.o.number = true                    -- Show line numbers
vim.o.relativenumber = true            -- Relative line numbers for easy jumping
vim.o.cursorline = true                -- Highlight the current line
vim.o.signcolumn = "no"                -- Hide sign column (signs rendered in statuscolumn)
vim.o.statuscolumn = "%!v:lua.StatusColumn()"
vim.o.laststatus = 3                   -- Single global statusline
-- vim.o.winborder = "🭽,▔,🭾,▕,🭿,▁,🭼,▏"
-- vim.o.winborder = "rounded"
vim.o.scrolloff = 8                    -- Keep 8 lines visible above/below cursor
vim.o.list = true                      -- Show whitespace characters
vim.opt.listchars = { tab = "→ ", trail = "·", nbsp = "␣" }

-- Editing
-- vim.o.clipboard = "unnamedplus"        -- Use system clipboard
vim.o.expandtab = true                 -- Spaces instead of tabs
vim.o.shiftwidth = 2                   -- 2-space indentation
vim.o.tabstop = 2                      -- 2-space tabs
vim.o.breakindent = true               -- Wrapped lines preserve indentation
vim.o.undofile = true                  -- Persist undo history across sessions
vim.o.swapfile = false                 -- No swap files
vim.o.confirm = true                   -- Prompt instead of error on :q with unsaved changes

-- Search
vim.o.ignorecase = true                -- Case-insensitive search...
vim.o.smartcase = true                 -- ...unless search contains capitals
vim.o.inccommand = "split"             -- Live preview of :s substitutions

-- Splits
vim.o.splitright = true                -- Vertical splits open to the right
vim.o.splitbelow = true                -- Horizontal splits open below

-- Folds
vim.o.foldlevelstart = 99             -- Start with all folds open
vim.o.foldtext = ""                    -- Use highlighted fold text (no summary line)
vim.o.foldnestmax = 1                  -- Only fold one level deep

-- vim.o.foldcolumn = "auto:1"
-- vim.o.fillchars = "fold: ,foldopen: ,foldclose:\u{f460},foldsep: ,foldinner: "

-- Timing
vim.o.updatetime = 250                 -- Faster CursorHold events (default 4000ms)
vim.o.timeoutlen = 300                 -- Time to wait for mapped sequence (default 1000ms)

vim.api.nvim_create_autocmd("TextYankPost", {
	callback = function() vim.hl.on_yank() end,
})

vim.api.nvim_create_autocmd("FileType", {
	callback = function() vim.opt_local.formatoptions:remove("o") end,
})

function _G.StatusColumn()
	local buf = vim.api.nvim_win_get_buf(vim.g.statusline_winid)
	local marks = vim.api.nvim_buf_get_extmarks(buf, -1, { vim.v.lnum - 1, 0 }, { vim.v.lnum - 1, -1 }, { details = true, type = "sign" })

	local diag_text, diag_hl = "", ""
	local git_text, git_hl = "", ""
	for _, mark in ipairs(marks) do
		local d = mark[4]
		local text = (d.sign_text or ""):gsub("%s", "")
		local hl = d.sign_hl_group or ""
		if hl:find("GitSigns") then
			git_text, git_hl = text, hl
		else
			diag_text, diag_hl = text, hl
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
	local num = vim.v.relnum == 0 and vim.v.lnum or vim.v.relnum
	return cell(diag_text, diag_hl, 2) .. "%=" .. num .. " " .. cell(git_text, git_hl, 2)
end

vim.diagnostic.config({
	jump = { float = true },
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = "󰅚",
			[vim.diagnostic.severity.WARN] = "󰀪",
			[vim.diagnostic.severity.INFO] = "󰋽",
			[vim.diagnostic.severity.HINT] = "󰌶",
		},
	},
	status = {
		format = {
			[vim.diagnostic.severity.ERROR] = "󰅚 ",
			[vim.diagnostic.severity.WARN] = "󰀪 ",
			[vim.diagnostic.severity.INFO] = "󰋽 ",
			[vim.diagnostic.severity.HINT] = "󰌶 ",
		},
	},
})

vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0


-- Build hooks (must be defined BEFORE vim.pack.add)

vim.api.nvim_create_autocmd("PackChanged", {
	callback = function(ev)
		if ev.data.spec.name == "nvim-treesitter" and ev.data.kind == "update" then
			if not ev.data.active then
				vim.cmd.packadd("nvim-treesitter")
			end
			vim.cmd("TSUpdate")
		end
	end,
})

-- Plugins

vim.pack.add({
	"https://github.com/catppuccin/nvim",
	"https://github.com/folke/which-key.nvim",
	"https://github.com/nvim-treesitter/nvim-treesitter",
	-- "https://github.com/b0o/SchemaStore.nvim",
	{ src = "https://github.com/saghen/blink.cmp", version = vim.version.range("1.0") },
	"https://github.com/mason-org/mason.nvim",
	{ src = "https://github.com/A7Lavinraj/fyler.nvim", branch = "stable" },
	"https://github.com/echasnovski/mini.icons",
	"https://github.com/echasnovski/mini.notify",
	"https://github.com/lewis6991/gitsigns.nvim",
	"https://github.com/sindrets/diffview.nvim",
	"https://github.com/folke/trouble.nvim",
	"https://github.com/ibhagwan/fzf-lua",
	"https://github.com/Cannon07/claude-preview.nvim",
	"https://github.com/stevearc/conform.nvim",
}, { confirm = false })

local function pack_clean()
	local stale = vim.iter(vim.pack.get())
		:filter(function(p) return not p.active end)
		:map(function(p) return p.spec.name end)
		:totable()
	if #stale > 0 then
		vim.pack.del(stale)
	end
end

-- pack_clean()
vim.api.nvim_create_user_command("PackClean", pack_clean, {})

-- Colorscheme

vim.cmd.colorscheme("catppuccin-frappe")

-- Treesitter

local ts_ok, ts = pcall(require, "nvim-treesitter")
if ts_ok then
	ts.install({ "typescript", "tsx", "javascript", "rust" })

	vim.api.nvim_create_autocmd("FileType", {
		callback = function(args)
			local lang = vim.treesitter.language.get_lang(args.match)
			if not lang then return end
			if not vim.treesitter.language.add(lang) then return end

			vim.treesitter.start(args.buf, lang)
			vim.wo[0][0].foldmethod = "expr"
			vim.wo[0][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
			vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
		end,
	})
end

-- Auto-reload files changed outside of Neovim

-- vim.api.nvim_create_autocmd({ "FocusGained", "CursorHold" }, {
-- 	callback = function() vim.cmd("checktime") end,
-- })

local w = vim.uv.new_fs_event()
w:start(vim.fn.getcwd(), { recursive = true }, vim.schedule_wrap(function()
	vim.cmd("checktime")
end))

-- Auto-reload without W12 confirm prompt
-- vim.api.nvim_create_autocmd("FileChangedShell", {
-- 	callback = function() return "reload" end,
-- })

-- Completion (blink.cmp)

require("blink.cmp").setup({
	keymap = { preset = "default" },
	appearance = { nerd_font_variant = "mono" },
	completion = { documentation = { auto_show = true } },
	sources = { default = { "lsp", "path", "snippets", "buffer" } },
	fuzzy = {
		implementation = "prefer_rust",
		prebuilt_binaries = { force_version = "v1.*" },
	},
})

-- Git signs

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

-- Mason (LSP/tool installer, :MasonInstall to add servers)

require("mason").setup()

-- LSP: tsgo (diagnostics only) + vtsls (everything else)

local ts_filetypes = { "typescript", "typescriptreact", "javascript", "javascriptreact" }
local ts_root_markers = { "tsconfig.json", "package.json", ".git" }

vim.lsp.config.tsgo = {
	cmd = { "tsgo", "--lsp", "--stdio" },
	filetypes = ts_filetypes,
	root_markers = ts_root_markers,
	handlers = {
		["$/progress"] = function() end,
	},
	on_init = function(client)
		-- Diagnostics are push-based (textDocument/publishDiagnostics), no capability needed.
		-- Clear everything else so vtsls handles completions, hover, go-to-def, etc.
		local caps = client.server_capabilities
		caps.completionProvider = nil
		caps.hoverProvider = nil
		caps.signatureHelpProvider = nil
		caps.definitionProvider = nil
		caps.typeDefinitionProvider = nil
		caps.implementationProvider = nil
		caps.referencesProvider = nil
		caps.documentHighlightProvider = nil
		caps.documentSymbolProvider = nil
		caps.workspaceSymbolProvider = nil
		caps.codeActionProvider = nil
		caps.codeLensProvider = nil
		caps.documentFormattingProvider = nil
		caps.documentRangeFormattingProvider = nil
		caps.renameProvider = nil
		caps.inlayHintProvider = nil
		caps.semanticTokensProvider = nil
		caps.declarationProvider = nil
		caps.callHierarchyProvider = nil
		caps.selectionRangeProvider = nil
	end,
}

vim.lsp.config.vtsls = {
	cmd = { "vtsls", "--stdio" },
	filetypes = ts_filetypes,
	root_markers = ts_root_markers,
	init_options = { hostInfo = "neovim" },
	handlers = {
		["textDocument/publishDiagnostics"] = function() end,
	},
}

vim.lsp.config.lua_ls = {
	cmd = { "lua-language-server" },
	filetypes = { "lua" },
	root_markers = {
		".luarc.json", ".luarc.jsonc", ".emmyrc.json",
		".luacheckrc", ".stylua.toml", "stylua.toml", "selene.toml",
		".git",
	},
	on_init = function(client)
		-- Only inject Neovim runtime when the project has no .luarc.json
		if client.workspace_folders then
			local path = client.workspace_folders[1].name
			if
				path ~= vim.fn.stdpath("config")
				and (vim.uv.fs_stat(path .. "/.luarc.json") or vim.uv.fs_stat(path .. "/.luarc.jsonc"))
			then
				return
			end
		end
		client.config.settings.Lua = vim.tbl_deep_extend("force", client.config.settings.Lua, {
			runtime = {
				version = "LuaJIT",
				path = { "lua/?.lua", "lua/?/init.lua" }
			},
			workspace = {
				checkThirdParty = false,
				library = { vim.env.VIMRUNTIME },
			},
		})
	end,
	settings = { Lua = {} },
}

vim.lsp.enable({ "tsgo", "vtsls", "lua_ls" })

-- Code Lens (0.12: renders as virtual lines, grx to run actions)
vim.lsp.codelens.enable(true)

-- 0.12 features that activate automatically when the LSP server supports them:
-- • documentColor        – inline color swatches (CSS, etc.)
-- • linkedEditingRange   – edit matching HTML tags simultaneously
-- • onTypeFormatting     – auto-format as you type
-- • selectionRange       – incremental selection (an/in in visual mode)
-- • inlineCompletion     – ghost-text style completions

-- 0.12 features that can be enabled manually:
if not pcall(function() require('vim._core.ui2').enable({}) end) then
	vim.notify("vim._core.ui2 unavailable — experimental cmdline UI disabled", vim.log.levels.WARN)
end
-- vim.o.diffopt = vim.o.diffopt .. ",inline:word"  -- word-level inline diff highlighting

-- File tree

require("mini.icons").setup()
require("mini.notify").setup({
	window = {
		config = {
			border = "rounded",
		},
		winblend = 75,
	},
})
require("fyler").setup({
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
})

vim.g.auto_format = true

-- Formatting (conform.nvim)

local web_formatters = { "biome", "prettierd", "prettier", stop_after_first = true }

require("conform").setup({
	formatters_by_ft = {
		javascript = web_formatters,
		javascriptreact = web_formatters,
		typescript = web_formatters,
		typescriptreact = web_formatters,
		json = web_formatters,
		css = web_formatters,
		lua = { "stylua" },
		rust = { lsp_format = "prefer" },
	},
	formatters = {
		prettierd = { require_cwd = true },
		prettier = { require_cwd = true },
	},
	format_on_save = function()
		if not vim.g.auto_format then return end
		return { timeout_ms = 500, lsp_format = "never" }
	end,
})

-- Keymaps

vim.keymap.set("n", "<leader>r", function()
	-- Close fyler before saving session (plugin state isn't serialisable)
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if vim.bo[buf].filetype == "fyler" then
			vim.api.nvim_buf_delete(buf, { force = true })
		end
	end
	local session = vim.fn.stdpath("state") .. "/restart.vim"
	vim.cmd.mksession({ args = { session }, bang = true })
	vim.cmd.restart({ args = { "source", session } })
end, { desc = "Restart nvim with session" })

require("trouble").setup()

vim.keymap.set("n", "<leader>x", "<cmd>Trouble diagnostics toggle<cr>", { desc = "Diagnostics (Trouble)" })

require("fzf-lua").register_ui_select()
require("claude-preview").setup()

vim.keymap.set("n", "<leader>ff", "<cmd>FzfLua files<cr>", { desc = "Find files" })
vim.keymap.set("n", "<leader>fg", "<cmd>FzfLua live_grep<cr>", { desc = "Live grep" })
vim.keymap.set("n", "<leader>fh", "<cmd>FzfLua helptags<cr>", { desc = "Live grep" })

vim.keymap.set({ "n", "x" }, "j", function() return vim.v.count == 0 and "gj" or "j" end, { expr = true })
vim.keymap.set({ "n", "x" }, "k", function() return vim.v.count == 0 and "gk" or "k" end, { expr = true })

vim.keymap.set("n", "<leader>e", function()
	require("fyler").toggle({ kind = "split_left_most" })
end, { desc = "Toggle file tree" })

vim.keymap.set("n", "<leader>th", function()
	local enabled = not vim.lsp.inlay_hint.is_enabled()
	vim.lsp.inlay_hint.enable(enabled)
	vim.notify("Inlay hints: " .. (enabled and "on" or "off"))
end, { desc = "Toggle inlay hints" })

vim.keymap.set("n", "<leader>tf", function()
	vim.g.auto_format = not vim.g.auto_format
	vim.notify("Auto format: " .. (vim.g.auto_format and "on" or "off"))
end, { desc = "Toggle auto format" })


