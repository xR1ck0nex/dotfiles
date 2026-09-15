-- ~/.config/nvim/lua/keymaps.lua
--
local map = vim.keymap.set

-- clear search highlight
map("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- window navigation, same directions as the hyprland binds
map("n", "<C-h>", "<C-w>h")
map("n", "<C-j>", "<C-w>j")
map("n", "<C-k>", "<C-w>k")
map("n", "<C-l>", "<C-w>l")

-- buffers
map("n", "<leader>bd", "<cmd>bdelete<CR>", { desc = "Delete buffer" })
map("n", "<S-h>", "<cmd>bprevious<CR>", { desc = "Previous buffer" })
map("n", "<S-l>", "<cmd>bnext<CR>", { desc = "Next buffer" })

-- move selected lines
map("v", "J", ":m '>+1<CR>gv=gv")
map("v", "K", ":m '<-2<CR>gv=gv")

-- keep the cursor centred when jumping
map("n", "<C-d>", "<C-d>zz")
map("n", "<C-u>", "<C-u>zz")
map("n", "n", "nzzzv")
map("n", "N", "Nzzzv")

-- paste over a selection without clobbering the register
map("x", "<leader>p", [["_dP]], { desc = "Paste without yanking" })

-- diagnostics
map("n", "<leader>e", vim.diagnostic.open_float, { desc = "Line diagnostics" })
map("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Diagnostics to loclist" })

-- terminal escape
map("t", "<Esc><Esc>", "<C-\\><C-n>")

-- files: oil for editing the tree as a buffer, yazi for browsing
map("n", "-", "<cmd>Oil<CR>", { desc = "Open parent directory (oil)" })
map("n", "<leader>fy", "<cmd>Yazi<CR>", { desc = "Yazi at current file" })
map("n", "<leader>fY", "<cmd>Yazi cwd<CR>", { desc = "Yazi at cwd" })

-- fzf-lua
map("n", "<leader>ff", "<cmd>FzfLua files<CR>", { desc = "Find files" })
map("n", "<leader>fg", "<cmd>FzfLua live_grep<CR>", { desc = "Live grep" })
map("n", "<leader>fb", "<cmd>FzfLua buffers<CR>", { desc = "Buffers" })
map("n", "<leader>fh", "<cmd>FzfLua helptags<CR>", { desc = "Help" })
map("n", "<leader>fd", "<cmd>FzfLua diagnostics_document<CR>", { desc = "Diagnostics" })
