local function getLazyGitConfig()
  local function parse_yaml(content)
    local result = {}
    local current_section

    for line in content:gmatch("[^\r\n]+") do
      -- Ignore comments and empty lines
      if not line:match("^%s*#") and line:match("%S") then
        local key, value = line:match("^%s*([%w_]+):%s*(.-)%s*$")
        if key and value then
          -- Handle nested keys (simple case for nested objects)
          if value == "" then
            current_section = key
            result[current_section] = {}
          else
            if current_section then
              result[current_section][key] = value
            else
              result[key] = value
            end
          end
        elseif current_section then
          -- Handle nested values (indented lines under a section)
          local nested_key, nested_value = line:match("^%s+([%w_]+):%s*(.-)%s*$")
          if nested_key and nested_value then
            result[current_section][nested_key] = nested_value
          end
        end
      end
    end

    return result
  end

  local config = {
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
  }

  -- Find the repository root
  local repo_root = vim.fs.find(".git", { upward = true, type = "directory" })[1]

  if repo_root then
    -- Get repository root directory
    repo_root = vim.fn.fnamemodify(repo_root, ":h")
    local lazygit_config_path = repo_root .. "/.git/lazygit.yml"

    -- Check if the file exists
    local file = io.open(lazygit_config_path, "r")
    print(file)
    if file then
      local content = file:read("*all")
      file:close()

      -- Parse YAML content
      local parsed = parse_yaml(content)

      print(vim.inspect(parsed))

      -- if parsed and parsed.git then
      --   config.git.branchPrefix = parsed.git.branchPrefix or ""
      --   config.git.commitPrefix.pattern = parsed.git.commitPrefix and parsed.git.commitPrefix.pattern or ""
      --   config.git.commitPrefix.replace = parsed.git.commitPrefix and parsed.git.commitPrefix.replace or ""
      -- end

      -- if parsed and parsed.customCommands then
      --   config.customCommands = parsed.customCommands
      -- end
    end
  end

  return config
end

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
      config = getLazyGitConfig(),
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
