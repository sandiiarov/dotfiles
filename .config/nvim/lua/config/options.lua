-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.g.root_spec = { ".git" }

vim.o.pumblend = 0
vim.o.winblend = 0

if vim.g.neovide then
  local alpha = function()
    return string.format("%x", math.floor(255 * (vim.g.transparency or 0.9)))
  end

  vim.o.guifont = "JetBrainsMono Nerd Font:h14"
  vim.g.neovide_input_ime = true
  vim.g.neovide_input_macos_option_key_is_meta = "both"
  vim.g.neovide_fullscreen = true
  vim.g.neovide_transparency = 0.0
  vim.g.transparency = 0.9
  vim.g.neovide_background_color = "#1e1e2e" .. alpha()
  vim.g.neovide_window_blurred = true
  vim.g.neovide_refresh_rate = 144
  vim.g.neovide_cursor_vfx_mode = "ripple"
  vim.g.neovide_cursor_animation_length = 0.03
  vim.g.neovide_cursor_trail_size = 0.9
end
