local bufferline = require("bufferline")

return {
  "akinsho/bufferline.nvim",
  opts = {
    options = {
      always_show_bufferline = true,
      show_buffer_close_icons = false,
      show_close_icon = false,
      separator_style = { "", "" },
      indicator = {
        style = "underline",
      },
      modified_icon = "",
      style_preset = {
        bufferline.style_preset.no_italic,
        bufferline.style_preset.no_bold,
      },
    },
    highlights = {},
  },
}
