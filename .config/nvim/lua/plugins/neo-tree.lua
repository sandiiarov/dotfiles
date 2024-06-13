return {
  "nvim-neo-tree/neo-tree.nvim",
  opts = function()
    vim.api.nvim_set_hl(
      0,
      "NeoTreeNormal",
      { fg = vim.g.terminal_color_7, bg = vim.g.terminal_color_0 }
    )
    vim.api.nvim_set_hl(0, "NeoTreeNormalNC", { link = "NeoTreeNormal" })

    return {
      popup_border_style = "rounded",
      window = {
        position = "right",
      },
      default_component_configs = {
        git_status = {
          symbols = {
            unstaged = "",
            staged = "",
            untracked = "",
            ignored = "",
            conflict = "",
          },
        },
      },
      filesystem = {
        filtered_items = {
          visible = true,
          hide_dotfiles = false,
          hide_gitignored = false,
        },
        follow_current_file = {
          enabled = true,
          leave_dirs_open = true,
        },
      },
    }
  end,
}
