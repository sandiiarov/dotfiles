return {
  "petertriho/nvim-scrollbar",
  event = "BufReadPost",
  config = function()
    require("scrollbar").setup({
      show_in_active_only = true,
      handlers = {
        cursor = false,
        diagnostic = true,
        gitsigns = false,
        handle = false,
        search = false,
        ale = false,
      },
    })
  end,
}
