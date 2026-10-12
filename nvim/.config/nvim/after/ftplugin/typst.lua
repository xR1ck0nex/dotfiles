-- ~/.config/nvim/after/ftplugin/typst.lua

-- prose-friendly editing
vim.opt_local.wrap = true
vim.opt_local.linebreak = true
vim.opt_local.breakindent = true

local buf = vim.api.nvim_get_current_buf()
local function map(lhs, rhs, desc)
	vim.keymap.set("n", lhs, rhs, { buffer = buf, desc = desc })
end

-- same <leader>m keys as Markdown, but Typst-aware in this buffer
map("<leader>mp", "<cmd>TypstPreviewToggle<CR>", "Typst preview (browser)")
map("<leader>mc", "<cmd>TypstPreviewStop<CR>", "Stop Typst preview")
map("<leader>ms", "<cmd>TypstPreviewSyncCursor<CR>", "Sync preview to cursor")
map("<leader>mF", "<cmd>TypstPreviewFollowCursorToggle<CR>", "Toggle follow cursor")

-- open the exported PDF (written on save by tinymist) in xdg-open
map("<leader>mo", function()
	local pdf = vim.api.nvim_buf_get_name(buf):gsub("%.typ$", ".pdf")
	if vim.uv.fs_stat(pdf) == nil then
		return vim.notify("No PDF yet: save the file first (:w)", vim.log.levels.WARN)
	end
	vim.system({ "xdg-open", pdf }, { detach = true })
end, "Open PDF in xdg-open")

-- multi-file projects: tell tinymist which file is the entry point
local function tinymist()
	return vim.lsp.get_clients({ bufnr = buf, name = "tinymist" })[1]
end

map("<leader>mm", function()
	local c = tinymist()
	if not c then return vim.notify("tinymist not attached", vim.log.levels.WARN) end
	c:exec_cmd({ title = "pin", command = "tinymist.pinMain", arguments = { vim.api.nvim_buf_get_name(buf) } },
		{ bufnr = buf })
	vim.notify("Pinned main file: " .. vim.fn.expand("%:t"))
end, "Pin this file as main")

map("<leader>mu", function()
	local c = tinymist()
	if not c then return end
	c:exec_cmd({ title = "unpin", command = "tinymist.pinMain", arguments = { vim.v.null } }, { bufnr = buf })
	vim.notify("Unpinned main file")
end, "Unpin main file")
