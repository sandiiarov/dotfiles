-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
local map = LazyVim.safe_keymap_set

-- Resize window using <ctrl> arrow keys
map("n", "<C-S-k>", "<cmd>resize +2<cr>", { desc = "Increase Window Height" })
map("n", "<C-S-j>", "<cmd>resize -2<cr>", { desc = "Decrease Window Height" })
map("n", "<C-S-h>", "<cmd>vertical resize -2<cr>", { desc = "Decrease Window Width" })
map("n", "<C-S-l>", "<cmd>vertical resize +2<cr>", { desc = "Increase Window Width" })

local function get_lazy_root()
  local ok, lazy_config = pcall(require, "lazy.core.config")
  if ok and lazy_config and lazy_config.options and lazy_config.options.root then
    return lazy_config.options.root
  else
    return vim.fn.stdpath("data") .. "/lazy"
  end
end

local function get_cwd()
  return vim.loop.cwd()
end

local function expand_tilde(path)
  if path:sub(1, 1) == "~" then
    local home = vim.loop.os_homedir()
    return path:gsub("^~", home)
  end
  return path
end

local function compute_possible_paths(raw_path, lazy_root, cwd)
  local expanded_self = expand_tilde(raw_path)

  local expansions = {
    vim.fs.joinpath(lazy_root, expanded_self),
    vim.fs.joinpath(cwd, expanded_self),
    expanded_self,
  }

  -- If the path doesn't start with a slash, also try prefixing one:
  if not expanded_self:match("^/") then
    local slash_version = "/" .. expanded_self
    table.insert(expansions, slash_version)
    table.insert(expansions, vim.fs.joinpath(cwd, slash_version))
    table.insert(expansions, vim.fs.joinpath(lazy_root, slash_version))
  end

  return expansions
end

local function file_exists(path)
  local stat = vim.loop.fs_stat(path)
  return stat ~= nil and stat.type == "file"
end

local function try_trim_and_check(path)
  if file_exists(path) then
    return path
  end

  local pattern = "['\"`()%[%]{}<>,%.]"
  local start_i = 1
  local end_i = #path

  while start_i <= end_i do
    local first_char = path:sub(start_i, start_i)
    local last_char = path:sub(end_i, end_i)

    local first_is_junk = first_char:match(pattern)
    local last_is_junk = last_char:match(pattern)

    if first_is_junk then
      start_i = start_i + 1
    elseif last_is_junk then
      end_i = end_i - 1
    else
      break
    end
  end

  local trimmed = path:sub(start_i, end_i)
  if trimmed ~= "" and file_exists(trimmed) then
    return trimmed
  end
  return nil
end

local function extract_raw_paths_from_line(line)
  local path_pattern = "[~%./]?[%w%-%_%.%/:]+"
  local results = {}
  for match in line:gmatch(path_pattern) do
    table.insert(results, match)
  end
  return results
end

local function find_file_paths()
  local buf = vim.api.nvim_get_current_buf()
  local extmarks = require("snacks.picker.util.highlight").get_highlights({ buf = buf })

  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local found_paths = {}

  local lazy_root = get_lazy_root()
  local cwd = get_cwd()

  for line_nr, line in ipairs(lines) do
    local raw_paths = extract_raw_paths_from_line(line)

    for _, raw_path in ipairs(raw_paths) do
      -- 1) expansions
      local expansions = compute_possible_paths(raw_path, lazy_root, cwd)

      -- 2) "check or trim"
      local actual_path = nil
      for _, candidate in ipairs(expansions) do
        local maybe_fixed = try_trim_and_check(candidate)
        if maybe_fixed then
          actual_path = maybe_fixed
          break
        end
      end

      -- If valid, store for later
      if actual_path then
        local s, e = string.find(line, raw_path, 1, true)
        if s then
          table.insert(found_paths, {
            buf = buf,
            file = raw_path,
            text = raw_path,
            path = actual_path,
            pos = { line_nr, s },
            end_pos = { line_nr, e + 1 },
            highlights = extmarks[line_nr],
          })
        end
      end
    end
  end

  if #found_paths == 0 then
    print("No valid file paths found in current buffer")
    return nil
  end

  table.sort(found_paths, function(a, b)
    return a.path < b.path
  end)

  return found_paths
end

local function pick_file_paths()
  local paths = find_file_paths()

  if paths == nil then
    return
  end

  Snacks.picker.pick({
    source = "file_paths",
    items = paths,
    actions = {
      confirm = function(picker, item)
        picker:close()
        vim.cmd("edit " .. item.path)
      end,
    },
  })
end

map("n", "<leader>fp", pick_file_paths, { desc = "Find file paths" })
