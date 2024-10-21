-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- floating terminal
-- slightly modified https://github.com/LazyVim/LazyVim/blob/v10.9.1/lua/lazyvim/config/keymaps.lua#L141-L146
-- in order to add a border to the floating terminal
local Util = require("lazyvim.util")
local lazyterm = function()
  Util.terminal(nil, {
    cwd = Util.root(),
    -- possible border options: https://github.com/folke/lazy.nvim/blob/v10.16.0/lua/lazy/view/float.lua#L12
    border = "rounded",
  })
end
vim.keymap.set("n", "<leader>ft", lazyterm, { desc = "Terminal (root dir)" })
vim.keymap.set("n", "<leader>fT", function()
  Util.terminal(nil, {
    border = "rounded",
  })
end, { desc = "Terminal (cwd)" })
vim.keymap.set("n", "<c-/>", lazyterm, { desc = "Terminal (root dir)" })
vim.keymap.set("n", "<c-_>", lazyterm, { desc = "which_key_ignore" })
