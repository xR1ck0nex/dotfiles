-- ~/.config/nvim/lua/lsp.lua
-- Servers come from pacman/AUR. nvim-lspconfig provides the base configs; the tables below are merged on top of them.

--------------------------------------------------------------------
-- Per-server overrides
--------------------------------------------------------------------
vim.lsp.config("lua_ls", {
	settings = {
		Lua = {
		runtime = { version = "LuaJIT" },
		workspace = { checkThirdParty = false, library = { vim.env.VIMRUNTIME } },
		},
	},
})

vim.lsp.config("clangd", {
	cmd = { "clangd", "--background-index", "--clang-tidy", "--header-insertion=never" },
})

vim.lsp.config("pyright", {
	settings = {
		pyright = { disableOrganizeImports = true }, -- ruff does imports
		python = { analysis = { typeCheckingMode = "standard" } },
	},
})

vim.lsp.config("tinymist", {
	settings = { formatterMode = "typstyle", exportPdf = "onSave" },
})

-- Arch binary names differ from what nvim-lspconfig expects
vim.lsp.config("html", {
	cmd = { "vscode-html-languageserver", "--stdio" },
	filetypes = { "html", "php" },
})
vim.lsp.config("cssls", { cmd = { "vscode-css-languageserver", "--stdio" } })
vim.lsp.config("jsonls", { cmd = { "vscode-json-languageserver", "--stdio" } })

--------------------------------------------------------------------
-- Enable only servers whose binary is installed
--------------------------------------------------------------------
local servers = {
	"clangd", "pyright", "ruff", "lua_ls", "bashls", "texlab", "tinymist", "marksman", "html", "cssls", "jsonls", "phpactor",
}

for _, name in ipairs(servers) do
	local cfg = vim.lsp.config[name]
	local cmd = cfg and cfg.cmd
	if type(cmd) ~= "table" or vim.fn.executable(cmd[1]) == 1 then
		vim.lsp.enable(name)
	end
end

--------------------------------------------------------------------
-- Diagnostics look
--------------------------------------------------------------------
vim.diagnostic.config({
	virtual_text = true,
	severity_sort = true,
	float = { source = true },
})

--------------------------------------------------------------------
-- On attach: completion, format-on-save, extra keys
--------------------------------------------------------------------
-- formatted by prettier (format.lua) instead of the server, if prettier exists
local prettier_handles = vim.fn.executable("prettier") == 1
	and { html = true, cssls = true, jsonls = true, ts_ls = true }
	or {}

vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("user.lsp", {}),
	callback = function(ev)
	local client = assert(vim.lsp.get_client_by_id(ev.data.client_id))
	local buf = ev.buf

	-- completion menu while typing
	if client:supports_method("textDocument/completion") then
		vim.lsp.completion.enable(true, client.id, buf, { autotrigger = false })
		vim.keymap.set("i", "<C-Space>", vim.lsp.completion.get, { buffer = buf, desc = "Trigger completion" })
	end

	-- format on save
	if client:supports_method("textDocument/formatting") and not prettier_handles[client.name] then
		vim.api.nvim_create_autocmd("BufWritePre", {
			group = vim.api.nvim_create_augroup(("user.lsp.fmt.%d.%d"):format(buf, client.id), {}),
			buffer = buf,
			callback = function()
				vim.lsp.buf.format({ bufnr = buf, id = client.id, timeout_ms = 2000 })
			end,
		})
	end

	vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = buf, desc = "Go to definition" })
	vim.keymap.set("n", "gD", vim.lsp.buf.declaration, { buffer = buf, desc = "Go to declaration" })
	end,
})
