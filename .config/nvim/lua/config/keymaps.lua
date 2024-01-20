-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.keymap.del("n", "<leader>|")
vim.keymap.del("n", "<leader>-")
vim.keymap.del("n", "<leader>l")

vim.keymap.set("n", "Y", "yy")
vim.keymap.set("n", "<leader>pl", "<cmd>Lazy<cr>", { desc = "Lazy" })
vim.keymap.set("n", "<leader>pm", "<cmd>Mason<cr>", { desc = "Mason" })
vim.keymap.set("n", "<leader>pt", "<cmd>TSInstallInfo<cr>", { desc = "Treesitter Install info" })
vim.keymap.set("n", "<leader>cn", "<cmd>Navbuddy<cr>", { desc = "Navbuddy" })
vim.keymap.set("n", "<leader>rn", "<cmd>lua vim.lsp.buf.rename()<cr>", { desc = "Rename" })
