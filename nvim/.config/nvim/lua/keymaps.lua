-- ~/.config/nvim/lua/keymaps.lua

local map = vim.keymap.set

-- clear search highlight
map("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight" })

-- terminal escape
map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- window navigation
map("n", "<C-h>", "<C-w>h", { desc = "Window left" })
map("n", "<C-j>", "<C-w>j", { desc = "Window down" })
map("n", "<C-k>", "<C-w>k", { desc = "Window up" })
map("n", "<C-l>", "<C-w>l", { desc = "Window right" })

-- buffers
map("n", "<leader>bd", "<cmd>bdelete<CR>", { desc = "Delete buffer" })
map("n", "<S-h>", "<cmd>bprevious<CR>", { desc = "Previous buffer" })
map("n", "<S-l>", "<cmd>bnext<CR>", { desc = "Next buffer" })

-- move selected lines
map("x", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
map("x", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

-- move by screen line on wrapped text (a count like 5j still uses real lines)
map({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, desc = "Down (screen line)" })
map({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, desc = "Up (screen line)" })

-- keep the cursor centred when jumping
map("n", "<C-d>", "<C-d>zz", { desc = "Half page down (centred)" })
map("n", "<C-u>", "<C-u>zz", { desc = "Half page up (centred)" })
map("n", "n", "nzzzv", { desc = "Next match (centred)" })
map("n", "N", "Nzzzv", { desc = "Previous match (centred)" })

-- paste over a selection without clobbering the register
map("x", "<leader>p", [["_dP]], { desc = "Paste without yanking" })

-- diagnostics
map("n", "<leader>e", vim.diagnostic.open_float, { desc = "Line diagnostics" })
map("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Diagnostics to loclist" })

-- yazi
map("n", "<leader>fy", "<cmd>Yazi<CR>", { desc = "Yazi at current file" })
map("n", "<leader>fY", "<cmd>Yazi cwd<CR>", { desc = "Yazi at cwd" })
map("n", "<leader>fr", "<cmd>Yazi toggle<CR>", { desc = "Resume last yazi session" })

-- fzf-lua
map("n", "<leader>ff", "<cmd>FzfLua files<CR>", { desc = "Find files" })
map("n", "<leader>fg", "<cmd>FzfLua live_grep<CR>", { desc = "Live grep" })
map("n", "<leader>fb", "<cmd>FzfLua buffers<CR>", { desc = "Buffers" })
map("n", "<leader>fh", "<cmd>FzfLua helptags<CR>", { desc = "Help" })
map("n", "<leader>fd", "<cmd>FzfLua diagnostics_document<CR>", { desc = "Diagnostics" })
map("n", "<leader>fo", "<cmd>FzfLua oldfiles<CR>", { desc = "Recent files" })
map("n", "<leader>fk", "<cmd>FzfLua keymaps<CR>", { desc = "Search keymaps" })
map("n", "<leader>fs", "<cmd>FzfLua lsp_document_symbols<CR>", { desc = "Symbols (LSP)" })

-- markdown / web preview
map("n", "<leader>mp", "<cmd>LivePreview start<CR>", { desc = "Preview in browser" })
map("n", "<leader>mc", "<cmd>LivePreview close<CR>", { desc = "Stop preview" })
map("n", "<leader>mf", "<cmd>LivePreview pick<CR>", { desc = "Pick file to preview" })
map("n", "<leader>mr", "<cmd>RenderMarkdown toggle<CR>", { desc = "Toggle in-editor render" })

-- which-key: group names + buffer-local help
local wk = require("which-key")
wk.add({
  { "<leader>f", group = "find" },
  { "<leader>b", group = "buffer" },
  { "<leader>h", group = "git hunk" },
  { "<leader>m", group = "markdown/preview" },
  { "<leader>t", group = "toggle" },
  { "<leader>?", function() wk.show({ global = false }) end, desc = "Buffer-local keymaps" },
})
