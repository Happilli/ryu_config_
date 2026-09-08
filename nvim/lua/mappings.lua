require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set
local api = require "nvim-tree.api"
map("i", "jk", "<ESC>")
map("n", "+", api.tree.change_root_to_node)
map("n", ";", ":", { desc = "CMD enter command mode" })
map("n", "<A-j>", "<cmd>m .+1<cr>==", { desc = "Move line down" })
map("n", "<A-k>", "<cmd>m .-2<cr>==", { desc = "Move line up" })
map("i", "<A-j>", "<esc><cmd>m .+1<cr>==gi", { desc = "Move line down" })
map("i", "<A-k>", "<esc><cmd>m .-2<cr>==gi", { desc = "Move line up" })
map("v", "<A-j>", ":m '>+1<cr>gv=gv", { desc = "Move selection down" })
map("v", "<A-k>", ":m '<-2<cr>gv=gv", { desc = "Move selection up" })

-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")
