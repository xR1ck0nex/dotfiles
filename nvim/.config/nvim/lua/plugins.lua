-- ~/.config/nvim/lua/plugins.lua

vim.pack.add({
	{ src = "https://github.com/rose-pine/neovim",        name = "rose-pine" },
	{ src = "https://github.com/nvim-lua/plenary.nvim"},
	{ src = "https://github.com/stevearc/oil.nvim" },
	{ src = "https://github.com/mikavilpas/yazi.nvim" },
	{ src = "https://github.com/ibhagwan/fzf-lua" },
	{ src = "https://github.com/lewis6991/gitsigns.nvim" },
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter" },
	{ src = "https://github.com/nvim-tree/nvim-web-devicons" },
})

--------------------------------------------------------------------
-- colourscheme
--------------------------------------------------------------------
require("rose-pine").setup({
	variant = "main",          -- main | moon | dawn
	dark_variant = "main",
	styles = {
		bold = true,
		italic = false,        -- JetBrainsMono italics read poorly in a terminal
		transparency = false,
	},
})
vim.cmd.colorscheme("rose-pine")

--------------------------------------------------------------------
-- oil: edit the filesystem as a buffer
--------------------------------------------------------------------
require("oil").setup({
	default_file_explorer = true,   -- replaces netrw
	view_options = { show_hidden = true },
	delete_to_trash = true,
	skip_confirm_for_simple_edits = true,
	keymaps = {
		["<C-h>"] = false,
		["<C-l>"] = false,
		["q"] = "actions.close",
	},
})

--------------------------------------------------------------------
-- yazi: the system file manager, opened at the current file
--------------------------------------------------------------------
require("yazi").setup({
	open_for_directories = false,
	floating_window_scaling_factor = 0.85,
	yazi_floating_window_border = "rounded",
})

--------------------------------------------------------------------
-- fzf-lua: uses the fzf binary already installed
--------------------------------------------------------------------
require("fzf-lua").setup({
	"default-title",
	winopts = {
		height = 0.85,
		width = 0.85,
		preview = { default = "bat" },
	},
})

--------------------------------------------------------------------
-- gitsigns
--------------------------------------------------------------------
require("gitsigns").setup({
	signs = {
		add          = { text = "+" },
		change       = { text = "~" },
		delete       = { text = "_" },
		topdelete    = { text = "‾" },
		changedelete = { text = "~" },
	},
	current_line_blame = false,
})

--------------------------------------------------------------------
-- treesitter
--------------------------------------------------------------------
require("nvim-treesitter").setup()
vim.api.nvim_create_autocmd("FileType", {
	pattern = { "lua", "c", "cpp", "python", "bash", "json", "toml", "yaml", "markdown" },
	callback = function() pcall(vim.treesitter.start) end,
})
