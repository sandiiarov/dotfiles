return {
  "folke/snacks.nvim",
  opts = {
    styles = {
      zoom_indicator = {
        text = " ",
      },
    },
    indent = {
      enabled = false,
    },
    scroll = {
      enabled = true,
    },
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
        os = {
          open = '[ -z "$NVIM" ] && (nvim -- {{filename}}) || (nvim --server "$NVIM" --remote-send "q" && nvim --server "$NVIM" --remote {{filename}})',
          edit = '[ -z "$NVIM" ] && (nvim -- {{filename}}) || (nvim --server "$NVIM" --remote-send "q" && nvim --server "$NVIM" --remote {{filename}})',
          editAtLine = '[ -z "$NVIM" ] && (nvim +{{line}} -- {{filename}}) || (nvim --server $NVIM --remote-send "q" &&  nvim --server $NVIM --remote {{filename}} && nvim --server $NVIM --remote-send ":{{line}}<CR>")',
          editAtLineAndWait = "nvim +{{line}} {{filename}}",
          openDirInEditor = '[ -z "$NVIM" ] && (nvim -- {{dir}}) || (nvim --server "$NVIM" --remote-send "q" && nvim --server "$NVIM" --remote {{dir}})',
        },
      },
    },
    words = {
      debounce = 0,
      notify_end = false,
      modes = { "n" },
      -- Filter out javascript/typescript template literals
      filter = function(buf)
        -- Exit early if manually disabled
        if vim.g.snacks_words == false or vim.b[buf].snacks_words == false then
          return false
        end

        -- Exit early (enabling snacks) if filetype is not relevant or check fails
        local ft_ok, ft = pcall(function()
          return vim.bo[buf].filetype
        end)
        local relevant_fts = { javascript = true, typescript = true, javascriptreact = true, typescriptreact = true }
        if not ft_ok or not relevant_fts[ft] then
          return true
        end

        -- Perform the Treesitter check, protected by pcall
        -- This pcall checks if the cursor is currently inside a template literal
        local check_ok, is_inside = pcall(function()
          -- Ensure a parser is ready for the buffer
          local parser = vim.treesitter.get_parser(buf)
          if not parser or not parser:parse() then
            return false -- Assume not inside if parser isn't ready
          end

          local node = vim.treesitter.get_node({ bufnr = buf, ignore_hl = true })
          if not node then
            return false -- Assume not inside if no node under cursor
          end

          -- Walk up the parent tree from the current node
          while node do
            -- Safely get the node type
            local type_ok, node_type = pcall(node.type, node)
            if not type_ok then
              break -- Stop traversal if type cannot be determined
            end

            -- Check if this node is a template string/substitution
            if node_type == "template_string" or node_type == "template_substitution" then
              return true -- Yes, cursor is inside one of these types
            end

            -- Safely get the parent node
            local parent_ok, parent = pcall(node.parent, node)
            if not parent_ok or not parent or parent == node then
              break -- Stop traversal if error, no parent, or reached root
            end
            node = parent -- Move up to the parent
          end

          -- If the loop finished without finding a match, the cursor is not inside
          return false
        end)

        -- Handle the result of the Treesitter check
        if not check_ok then
          -- If the pcall itself failed, default to enabling snacks
          return true -- Enable snacks on error
        end

        -- If pcall succeeded, 'is_inside' holds true or false.
        -- We want to return 'false' (disable) if 'is_inside' is true,
        -- and return 'true' (enable) if 'is_inside' is false.
        return not is_inside
      end,
    },
  },
}
