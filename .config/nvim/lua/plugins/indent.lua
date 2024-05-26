return {
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    event = "LazyFile",
    dependencies = { "hiphish/rainbow-delimiters.nvim" },
    opts = function()
      local hooks = require("ibl.hooks")
      local mocha = require("catppuccin.palettes").get_palette("mocha")

      hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
        vim.api.nvim_set_hl(0, "RainbowMauve", { fg = mocha.mauve })
        vim.api.nvim_set_hl(0, "RainbowRed", { fg = mocha.red })
        vim.api.nvim_set_hl(0, "RainbowBlue", { fg = mocha.blue })
        vim.api.nvim_set_hl(0, "RainbowPeach", { fg = mocha.peach })
        vim.api.nvim_set_hl(0, "RainbowSky", { fg = mocha.sky })
        vim.api.nvim_set_hl(0, "RainbowYellow", { fg = mocha.yellow })
        vim.api.nvim_set_hl(0, "RainbowGreen", { fg = mocha.green })

        vim.api.nvim_set_hl(0, "Indent", { fg = mocha.surface0 })
        vim.api.nvim_set_hl(0, "MiniIndentscopeSymbol", { fg = mocha.overlay0 })
      end)

      vim.g.rainbow_delimiters = {
        query = {
          javascript = "rainbow-parens",
          tsx = "rainbow-parens",
        },
        highlight = {
          "RainbowMauve",
          "RainbowRed",
          "RainbowBlue",
          "RainbowPeach",
          "RainbowSky",
          "RainbowYellow",
          "RainbowGreen",
        },
      }

      hooks.register(
        hooks.type.SCOPE_HIGHLIGHT,
        hooks.builtin.scope_highlight_from_extmark
      )

      return {
        indent = {
          highlight = {
            "Indent",
          },
          repeat_linebreak = false,
          smart_indent_cap = false,
          char = "│",
        },
        scope = {
          enabled = false,
        },
      }
    end,
  },
  {
    "echasnovski/mini.indentscope",
    opts = {
      symbol = "│",
      draw = {
        delay = 0,
        animation = require("mini.indentscope").gen_animation.none(),
      },
      options = {
        indent_at_cursor = false,
      },
    },
  },
}
