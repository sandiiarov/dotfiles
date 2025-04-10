local mocha = require("catppuccin.palettes").get_palette("mocha")

return {
  "sphamba/smear-cursor.nvim",
  opts = {
    transparent_bg_fallback_color = mocha.base,
    cursor_color = mocha.surface0,
    stiffness = 0.8,
    trailing_stiffness = 0.5,
    trailing_exponent = 1,
    hide_target_hack = true,
    gamma = 1,
  },
}
