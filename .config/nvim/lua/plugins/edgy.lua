return {
  "folke/edgy.nvim",
  opts = {
    animate = {
      enabled = false
    },
    wo = {
      winbar = false,
      winfixwidth = true,
      winfixheight = true,
      winhighlight = "",
      spell = false,
      signcolumn = "no",
      statuscolumn = "",
      number = false,
      relativenumber = false,
    },
    left = {
      {
        ft = "neotest-summary",
        size = { height = 0.5, width = 0.2 },
      },
    },
    right = {
      {
        ft = "neo-tree",
        filter = function(buf)
          return vim.b[buf].neo_tree_source == "filesystem"
        end,
        open = function()
          require("neo-tree.command").execute({ dir = LazyVim.root() })
        end,
        size = { height = 0.5, width = 0.2 },
      },
    },
  }
}
