return {
  "petertriho/nvim-scrollbar",
  event = "BufReadPost",
  config = function()
    require("scrollbar").setup({
      handlers = {
        cursor = false,
        diagnostic = true,
        gitsigns = true,
        handle = false,
        search = false,
        ale = false,
      },
    })
  end,
}
