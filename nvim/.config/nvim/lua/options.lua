-- ~/.config/nvim/lua/options.lua

local o = vim.opt

vim.g.mapleader = " "
vim.g.maplocalleader = " "

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
o.wrap = false
o.splitright = true
o.splitbelow = true
o.termguicolors = true
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

-- completion
o.completeopt = { "menuone", "noselect", "popup" }

-- clipboard
o.clipboard = "unnamedplus"

-- keyboard: us,ru is set in hyprland. this makes normal-mode commands still
-- work while the ru layout is active.
o.langmap = "ФИСВУАПРШОЛДЬТЩЗЙКЫЕГМЦЧНЯ;ABCDEFGHIJKLMNOPQRSTUVWXYZ,фисвуапршолдьтщзйкыегмцчня;abcdefghijklmnopqrstuvwxyz"

-- trailing whitespace and tabs, visible
o.list = true
o.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

-- brief highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
	callback = function() vim.hl.on_yank() end,
})
