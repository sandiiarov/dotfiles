return {
  "nvim-lualine/lualine.nvim",
  opts = {
    options = {
      component_separators = "",
      section_separators = { left = "", right = "" },
    },
    sections = {
      lualine_a = {
        "mode",
        {
          function()
            return vim.b.snacks_terminal and " " .. vim.b.snacks_terminal.id or ""
          end,
          separator = "",
          padding = { left = 0, right = 1 },
        },
      },
    },
  },
}
