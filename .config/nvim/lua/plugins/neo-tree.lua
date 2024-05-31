return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = function()
      vim.api.nvim_set_hl(0, "NeoTreeNormal", { fg = vim.g.terminal_color_7, bg = vim.g.terminal_color_0 })
      vim.api.nvim_set_hl(0, "NeoTreeNormalNC", { link = "NeoTreeNormal" })
      vim.api.nvim_set_hl(0, "FloatBorder", { link = "NeoTreeNormal" })
      vim.api.nvim_set_hl(0, "NeoTreeFloatBorder", { link = "FloatBorder" })
      vim.api.nvim_set_hl(0, "FloatTitle", { link = "NeoTreeNormal" })
      vim.api.nvim_set_hl(0, "NeoTreeFloatTitle", { link = "FloatTitle" })

      return {
        popup_border_style = "rounded",
        window = {
          position = "float",
        },
        default_component_configs = {
          indent = {
            with_expanders = false,
          },
          git_status = {
            symbols = {
              unstaged  = "",
              staged    = "",
              untracked = "",
              ignored   = "",
              conflict  = "",
            },
          },
        },
        filesystem = {
          bind_to_cwd = true,
          filtered_items = {
            visible = true,
            hide_dotfiles = false,
            hide_gitignored = false,
          }
        },
      }
    end
  }
}
