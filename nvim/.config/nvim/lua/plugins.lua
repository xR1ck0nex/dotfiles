-- ~/.config/nvim/lua/plugins.lua

--------------------------------------------------------------------
-- Treesitter parsers update
--------------------------------------------------------------------
vim.api.nvim_create_autocmd("PackChanged", {
	callback = function(ev)
		if ev.data.spec.name == "nvim-treesitter"
			and (ev.data.kind == "install" or ev.data.kind == "update") then
			if not ev.data.active then vim.cmd.packadd("nvim-treesitter") end
			vim.cmd("TSUpdate")
		end
	end,
})

--------------------------------------------------------------------
-- Plugins add
--------------------------------------------------------------------
vim.pack.add({
	{ src = "https://github.com/rose-pine/neovim",        name = "rose-pine" },
	{ src = "https://github.com/nvim-lua/plenary.nvim"},
	{ src = "https://github.com/mikavilpas/yazi.nvim" },
	{ src = "https://github.com/ibhagwan/fzf-lua" },
	{ src = "https://github.com/lewis6991/gitsigns.nvim" },
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter" },
	{ src = "https://github.com/nvim-tree/nvim-web-devicons" },
	{ src = "https://github.com/nvim-lualine/lualine.nvim" },
	{ src = "https://github.com/folke/which-key.nvim" },
	{ src = "https://github.com/brianhuster/live-preview.nvim" },
	{ src = "https://github.com/MeanderingProgrammer/render-markdown.nvim" },
})

--------------------------------------------------------------------
-- Colorscheme
--------------------------------------------------------------------
require("rose-pine").setup({
	variant = "main",          -- main | moon | dawn
	dark_variant = "main",
	styles = {
		bold = true,
		italic = false,
		transparency = false,
	},
})
vim.cmd.colorscheme("rose-pine")

--------------------------------------------------------------------
-- yazi.nvim
--------------------------------------------------------------------
require("yazi").setup({
	open_for_directories = true,
	floating_window_scaling_factor = 0.85,
	yazi_floating_window_border = "rounded",
	integrations = {
		grep_in_directory = "fzf-lua",
		grep_in_selected_files = "fzf-lua",
	},
	keymaps = { replace_in_directory = false },
})

--------------------------------------------------------------------
-- fzf-lua.nvim
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
-- gitsigns.nvim
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

	on_attach = function(buf)
	local gs = require("gitsigns")
	local function map(mode, lhs, rhs, desc)
		vim.keymap.set(mode, lhs, rhs, { buffer = buf, desc = desc })
	end

    -- hunk navigation (falls back to built-in ]c/[c in diff mode)
	map("n", "]c", function()
		if vim.wo.diff then vim.cmd.normal({ "]c", bang = true }) else gs.nav_hunk("next") end
	end, "Next hunk")
	map("n", "[c", function()
		if vim.wo.diff then vim.cmd.normal({ "[c", bang = true }) else gs.nav_hunk("prev") end
	end, "Previous hunk")

		map("n", "<leader>hs", gs.stage_hunk, "Stage hunk")
    	map("n", "<leader>hr", gs.reset_hunk, "Reset hunk")
    	map("n", "<leader>hp", gs.preview_hunk, "Preview hunk")
    	map("n", "<leader>hb", function() gs.blame_line({ full = true }) end, "Blame line")
    	map("n", "<leader>hd", gs.diffthis, "Diff against index")
    	map("n", "<leader>tb", gs.toggle_current_line_blame, "Toggle inline blame")
	end,
})

--------------------------------------------------------------------
-- treesitter.nvim
--------------------------------------------------------------------

require("nvim-treesitter").install({
  "c", "cpp", "python", "lua", "vim", "vimdoc", "query", "bash", "latex", "typst", "markdown", "markdown_inline", "yaml", "html", "css", "scss", "javascript", "typescript", "json", "php", "phpdoc",
})

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("user.treesitter", {}),
  callback = function(ev)
    -- start highlighting if a parser exists for this filetype; silently skip otherwise
    if pcall(vim.treesitter.start, ev.buf) then
      vim.wo[0][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
      vim.wo[0][0].foldmethod = "expr"
    end
  end,
})

--------------------------------------------------------------------
-- lualine.nvim
--------------------------------------------------------------------
require("lualine").setup({
	options = {
		theme = "auto",
		globalstatus = true,      -- one bar at the bottom instead of one per split
		section_separators = { left = "", right = "" },
    	component_separators = { left = "│", right = "│" },
	},
	sections = {
		lualine_a = { "mode" },
    	lualine_b = {
			{ "b:gitsigns_head", icon = "" },           -- branch, from gitsigns
			{
				"diff",
				source = function()                         -- +added ~changed -removed, from gitsigns
					local g = vim.b.gitsigns_status_dict
					if g then return { added = g.added, modified = g.changed, removed = g.removed } end
				end,
			},
			"diagnostics",
		},
		lualine_c = { { "filename", path = 1 } },       -- path relative to cwd
    	lualine_x = { "searchcount", "lsp_status", "filetype" },
    	lualine_y = { "progress" },
    	lualine_z = { "location" },
	},
	extensions = { "quickfix", "fzf" },
})

--------------------------------------------------------------------
-- which-key
--------------------------------------------------------------------
local wk = require("which-key")

wk.setup({
	preset = "modern",   -- "classic" | "modern" | "helix"
	delay = 300,         -- ms before the popup appears
})

-- name the prefix groups so the popup shows "+find" instead of a bare "f"
wk.add({
	{ "<leader>f", group = "find" },
	{ "<leader>b", group = "buffer" },
	{ "<leader>?", function() wk.show({ global = false }) end, desc = "Buffer-local keymaps" },
})

--------------------------------------------------------------------
-- live-preview.nvim
--------------------------------------------------------------------
require("livepreview.config").set({
  browser = "librewolf",
  picker = "fzf-lua",
  sync_scroll = true,
  port = 5500,
})

--------------------------------------------------------------------
-- render-markdown.nvim
--------------------------------------------------------------------
require("render-markdown").setup({
  completions = { lsp = { enabled = true } },
})

--------------------------------------------------------------------
-- :PackClean -> delete plugins no longer listed in vim.pack.add()
--------------------------------------------------------------------
vim.api.nvim_create_user_command("PackClean", function()
  local stale = vim.iter(vim.pack.get())
    :filter(function(p) return not p.active end)
    :map(function(p) return p.spec.name end)
    :totable()
  if #stale == 0 then return vim.notify("Nothing to clean") end
  vim.pack.del(stale)
  vim.notify("Removed: " .. table.concat(stale, ", "))
end, { desc = "Delete plugins no longer in vim.pack.add()" })
