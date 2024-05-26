-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

if vim.g.neovide then
  vim.o.guifont = "JetBrainsMono Nerd Font:h13"
  vim.g.neovide_input_ime = true
  vim.g.neovide_input_macos_option_key_is_meta = "both"
  vim.g.neovide_fullscreen = true
  vim.g.neovide_refresh_rate = 144
  vim.g.neovide_cursor_vfx_mode = "ripple"
  vim.g.neovide_cursor_animation_length = 0.03
  vim.g.neovide_cursor_trail_size = 0.9
end
