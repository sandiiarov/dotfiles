-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
local map = LazyVim.safe_keymap_set

-- Resize window using <ctrl> arrow keys
map("n", "<C-S-k>", "<cmd>resize +2<cr>", { desc = "Increase Window Height" })
map("n", "<C-S-j>", "<cmd>resize -2<cr>", { desc = "Decrease Window Height" })
map("n", "<C-S-h>", "<cmd>vertical resize -2<cr>", { desc = "Decrease Window Width" })
map("n", "<C-S-l>", "<cmd>vertical resize +2<cr>", { desc = "Increase Window Width" })

-- Restart LSP
map("n", "<leader>cq", "<cmd>LspRestart<cr>", { desc = "Lsp Restart" })

-- Jump to next/previous definition
map("n", "<S-n>", function()
  Snacks.words.jump(vim.v.count1, true)
end)
map("n", "<S-p>", function()
  Snacks.words.jump(-vim.v.count1, true)
end)
