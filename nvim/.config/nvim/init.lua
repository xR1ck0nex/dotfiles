-- ~/.config/nvim/init.lua
--
-- Requires Nvim 0.12+ (vim.pack, the builtin plugin manager).
-- On 0.11 you'd need lazy.nvim instead; everything else here still applies.

require("options")
require("keymaps")
require("plugins")

--------------------------------------------------------------------
-- LSP
--------------------------------------------------------------------
vim.lsp.enable({
	"lua_ls",
	"clangd",
})

vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(args)
		local client = vim.lsp.get_client_by_id(args.data.client_id)
		if not client then return end

		-- native completion, no cmp plugin required (0.11+)
		if client:supports_method("textDocument/completion") then
			vim.lsp.completion.enable(true, client.id, args.buf, { autotrigger = true })
		end

		-- inlay hints where the server offers them
		if client:supports_method("textDocument/inlayHint") then
			vim.lsp.inlay_hint.enable(true, { bufnr = args.buf })
		end
	end,
})

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
