-- ~/.config/nvim/lsp/clangd.lua

return {
	cmd = {
		"clangd",
		"--background-index",
		"--clang-tidy",
		"--header-insertion=iwyu",
		"--completion-style=detailed",
		"--fallback-style=llvm",
	},
	filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
	root_markers = {
		".clangd", ".clang-tidy", ".clang-format",
		"compile_commands.json", "compile_flags.txt",
		"configure.ac", ".git",
	},
}
