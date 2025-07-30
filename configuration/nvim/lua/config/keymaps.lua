-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Map 'kj' to escape to normal mode
vim.keymap.set("i", "kj", "<Esc>", { desc = "Exit insert mode with kj" })
