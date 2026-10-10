-- ~/.config/nvim/lua/options.lua
-- Options the plugins rely on. Add your own general options here too.

-- disable netrw so yazi.nvim handles directories alone
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- <leader> key mapping
vim.g.mapleader = " "
vim.g.maplocalleader = " "

local o = vim.opt

-- files / undo
o.undofile = true
o.swapfile = false
o.backup = false
o.updatetime = 250

-- ui
o.number = true
o.relativenumber = true
o.signcolumn = "yes"
o.cursorline = true
o.scrolloff = 8
o.sidescrolloff = 8
o.splitright = true
o.splitbelow = true
o.termguicolors = true
o.wrap = true
o.linebreak = true
o.breakindent = true
o.showbreak = "↪ "
o.pumheight = 10
o.showmode = false
o.laststatus = 3
o.winborder = "rounded"

-- search
o.ignorecase = true
o.smartcase = true
o.hlsearch = true
o.incsearch = true
o.inccommand = "split"

-- indentation
o.expandtab = false
o.tabstop = 4
o.shiftwidth = 4
o.softtabstop = 4
o.smartindent = true

-- autocompletion
o.autocomplete = true
o.autocompletedelay = 80
o.complete = "o,.^10,w^5,b^5"

-- treesitter
o.foldlevelstart = 99

-- completion
o.completeopt = { "menu", "menuone", "noselect", "popup" }

-- clipboard
o.clipboard = "unnamedplus"

-- keyboard: us,ru is set in hyprland. this makes normal-mode commands still work while the ru layout is active.
o.langmap = "ФИСВУАПРШОЛДЬТЩЗЙКЫЕГМЦЧНЯ;ABCDEFGHIJKLMNOPQRSTUVWXYZ,фисвуапршолдьтщзйкыегмцчня;abcdefghijklmnopqrstuvwxyz"

-- trailing whitespace and tabs, visible
o.list = true
o.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

-- brief highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
	callback = function() vim.hl.on_yank() end,
})

-- diagnostics configuration
vim.diagnostic.config({
	virtual_text = { prefix = "●" },
	underline = true,
	severity_sort = true,
	float = { border = "rounded", source = true },
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = "E",
			[vim.diagnostic.severity.WARN]  = "W",
			[vim.diagnostic.severity.INFO]  = "I",
			[vim.diagnostic.severity.HINT]  = "H",
		},
	},
})
