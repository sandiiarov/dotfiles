return {
  "petertriho/nvim-scrollbar",
  event = "BufReadPost",
  opts = {
    throttle_ms = 0,
    handlers = {
      cursor = false,
      diagnostic = true,
      gitsigns = false,
      handle = false,
      search = false,
      ale = false,
    },
  },
}
