return {
  "folke/snacks.nvim",
  opts = {
    styles = {
      zoom_indicator = {
        text = " ",
      },
    },
    indent = { enabled = false },
    scroll = { enabled = false },
    terminal = {
      win = {
        wo = {
          winbar = "",
        },
      },
    },
    notifier = {
      top_down = false,
    },
    dashboard = {
      preset = {
        header = [[
                                                                   
      ████ ██████           █████      ██                    
     ███████████             █████                            
     █████████ ███████████████████ ███   ███████████  
    █████████  ███    █████████████ █████ ██████████████  
   █████████ ██████████ █████████ █████ █████ ████ █████  
 ███████████ ███    ███ █████████ █████ █████ ████ █████ 
██████  █████████████████████ ████ █████ █████ ████ ██████
]],
      },
    },
    zen = {
      on_open = function()
        require("incline").disable()
      end,
      on_close = function()
        require("incline").enable()
      end,
    },
  },
}
