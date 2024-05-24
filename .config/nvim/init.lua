if vim.g.neovide then
  vim.o.guifont = "JetBrainsMono Nerd Font:h12"
  vim.g.neovide_input_ime = true
  vim.g.neovide_input_macos_option_key_is_meta = "both"
  vim.g.neovide_fullscreen = true
  vim.g.neovide_refresh_rate = 144
  vim.g.neovide_cursor_vfx_mode = "ripple"
  vim.g.neovide_cursor_animation_length = 0.03
  vim.g.neovide_cursor_trail_size = 0.9

  vim.api.nvim_set_var("terminal_color_0", "#11111b")
  vim.api.nvim_set_var("terminal_color_1", "#f38ba8")
  vim.api.nvim_set_var("terminal_color_2", "#a6e3a1")
  vim.api.nvim_set_var("terminal_color_3", "#f9e2af")
  vim.api.nvim_set_var("terminal_color_4", "#89b4fa")
  vim.api.nvim_set_var("terminal_color_5", "#cba6f7")
  vim.api.nvim_set_var("terminal_color_6", "#94e2d5")
  vim.api.nvim_set_var("terminal_color_7", "#f5e0dc")
  vim.api.nvim_set_var("terminal_color_8", "#313244")
  vim.api.nvim_set_var("terminal_color_9", "#fab387")
  vim.api.nvim_set_var("terminal_color_10", "#a6e3a1")
  vim.api.nvim_set_var("terminal_color_11", "#f2cdcd")
  vim.api.nvim_set_var("terminal_color_12", "#89dceb")
  vim.api.nvim_set_var("terminal_color_13", "#f5c2e7")
  vim.api.nvim_set_var("terminal_color_14", "#b4befe")
  vim.api.nvim_set_var("terminal_color_15", "#eba0ac")
end

-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")
