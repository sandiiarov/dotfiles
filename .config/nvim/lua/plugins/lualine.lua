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
            local zoom_mode_on = Snacks.zen.win and Snacks.zen.win:valid() or false

            if zoom_mode_on then
              return "󱏘"
            end

            return vim.b.snacks_terminal and " " .. vim.b.snacks_terminal.id or ""
          end,
          separator = "",
          padding = { left = 0, right = 1 },
        },
      },
    },
  },
}
