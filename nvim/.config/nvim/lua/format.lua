-- ~/.config/nvim/lua/format.lua
-- prettier for web files + autosave for HTML live preview

local web = { "*.html", "*.css", "*.scss", "*.js", "*.ts", "*.jsx", "*.tsx", "*.json" }

if vim.fn.executable("prettier") == 1 then
	vim.api.nvim_create_autocmd("BufWritePre", {
		group = vim.api.nvim_create_augroup("user.prettier", {}),
		pattern = web,
		callback = function(ev)
		local lines = vim.api.nvim_buf_get_lines(ev.buf, 0, -1, false)
		local out = vim.system(
			{ "prettier", "--stdin-filepath", vim.api.nvim_buf_get_name(ev.buf) },
			{ stdin = table.concat(lines, "\n") .. "\n", text = true }
		):wait()

		if out.code ~= 0 then
			return vim.notify("prettier: " .. (out.stderr or ""), vim.log.levels.WARN)
		end

		local new = vim.split(out.stdout:gsub("\n$", ""), "\n", { plain = true })
		if not vim.deep_equal(lines, new) then -- don't touch the buffer if nothing changed
			local view = vim.fn.winsaveview()
			vim.api.nvim_buf_set_lines(ev.buf, 0, -1, false, new)
			vim.fn.winrestview(view)
		end
	end,
	})
end

-- live-preview only refreshes HTML on save: autosave when leaving Insert mode
vim.api.nvim_create_autocmd("InsertLeave", {
	group = vim.api.nvim_create_augroup("user.autosave", {}),
	pattern = { "*.html", "*.css", "*.js" },
	callback = function(ev)
	if vim.bo[ev.buf].modified and vim.bo[ev.buf].modifiable then
		vim.cmd("silent! write")
	end
end,
})
