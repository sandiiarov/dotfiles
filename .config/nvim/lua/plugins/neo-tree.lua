return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = {
      window = {
        position = "right",
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
    },
  }
}
