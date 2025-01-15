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
    lazygit = {
      config = {
        gui = {
          nerdFontsVersion = "3",
        },
        os = {
          open = '[ -z "$NVIM" ] && (nvim -- {{filename}}) || (nvim --server "$NVIM" --remote-send "q" && nvim --server "$NVIM" --remote {{filename}})',
          edit = '[ -z "$NVIM" ] && (nvim -- {{filename}}) || (nvim --server "$NVIM" --remote-send "q" && nvim --server "$NVIM" --remote {{filename}})',
          editAtLine = '[ -z "$NVIM" ] && (nvim +{{line}} -- {{filename}}) || (nvim --server $NVIM --remote-send "q" &&  nvim --server $NVIM --remote {{filename}} && nvim --server $NVIM --remote-send ":{{line}}<CR>")',
          editAtLineAndWait = "nvim +{{line}} {{filename}}",
          openDirInEditor = '[ -z "$NVIM" ] && (nvim -- {{dir}}) || (nvim --server "$NVIM" --remote-send "q" && nvim --server "$NVIM" --remote {{dir}})',
        },
        git = {
          -- branchPrefix = "blabla",
          -- git:
          --   paging:
          --     colorArg: always
          --     pager: delta --dark --paging=never
          -- paging = {
          --   useConfig = true,
          -- },
        },
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
