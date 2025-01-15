-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
local map = LazyVim.safe_keymap_set

-- Resize window using <ctrl> arrow keys
map("n", "<C-S-k>", "<cmd>resize +2<cr>", { desc = "Increase Window Height" })
map("n", "<C-S-j>", "<cmd>resize -2<cr>", { desc = "Decrease Window Height" })
map("n", "<C-S-h>", "<cmd>vertical resize -2<cr>", { desc = "Decrease Window Width" })
map("n", "<C-S-l>", "<cmd>vertical resize +2<cr>", { desc = "Increase Window Width" })

--------------------------------------------------------------------------------
-- Helpers
--------------------------------------------------------------------------------

local function get_lazy_root()
  local ok, lazy_config = pcall(require, "lazy.core.config")
  if ok and lazy_config and lazy_config.options and lazy_config.options.root then
    return lazy_config.options.root
  else
    return vim.fn.stdpath("data") .. "/lazy"
  end
end

local function get_cwd()
  return vim.loop.cwd() -- or vim.fn.getcwd()
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

--------------------------------------------------------------------------------
--  "check or trim"
--------------------------------------------------------------------------------
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

--------------------------------------------------------------------------------
--  Regex/pattern for raw paths in lines
--------------------------------------------------------------------------------
local function extract_raw_paths_from_line(line)
  local path_pattern = "[~%./]?[%w%-%_%.%/:]+"
  local results = {}
  for match in line:gmatch(path_pattern) do
    table.insert(results, match)
  end
  return results
end

--------------------------------------------------------------------------------
--  Find file paths
--  Returns: { { match, path_to_open, line_nr, start_col, end_col }, ... }
--------------------------------------------------------------------------------
local function find_file_paths()
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
            match = raw_path,
            path_to_open = actual_path,
            line_nr = line_nr - 1, -- 0-based
            start_col = s - 1, -- 0-based
            end_col = e, -- for highlight
          })
        end
      end
    end
  end

  if #found_paths == 0 then
    print("No valid file paths found in current buffer")
    return nil
  end

  return found_paths
end

--------------------------------------------------------------------------------
--  Quick-Open Mode
--  (Label only unique paths, but don't skip duplicates => same label for dups)
--------------------------------------------------------------------------------

local function quick_open_mode(found_paths)
  local ns_id = vim.api.nvim_create_namespace("QuickOpenPathsNS")
  local label_map = {} -- label -> path
  local path_label_map = {} -- path -> label
  local label_counter = 1 -- to assign 'a', 'b', 'c', etc.

  -- 1) Highlight each path
  for _, entry in ipairs(found_paths) do
    vim.api.nvim_buf_add_highlight(0, ns_id, "String", entry.line_nr, entry.start_col, entry.end_col)
  end

  -- 2) Assign letters to each unique path & add extmarks for each occurrence
  for _, entry in ipairs(found_paths) do
    local path = entry.path_to_open
    local label = path_label_map[path]

    -- If this is a new (unique) path, assign a new letter
    if not label then
      -- Only handle up to 26 unique paths
      if label_counter > 26 then
        break
      end
      label = string.char(96 + label_counter) -- 1->'a', 2->'b', ...
      label_counter = label_counter + 1

      path_label_map[path] = label
      label_map[label] = path
    end

    -- Now place the label right before the path text using an extmark
    vim.api.nvim_buf_set_extmark(0, ns_id, entry.line_nr, entry.start_col, {
      virt_text = { { label, "Search" } },
      virt_text_pos = "overlay",
    })
  end

  -- 3) "Open path" function
  local function open_path(path)
    vim.cmd("edit " .. vim.fn.fnameescape(path))
  end

  -- 4) Create a keymap for each label => open file
  for label, path in pairs(label_map) do
    vim.keymap.set("n", label, function()
      open_path(path)
      -- If you want to exit mode immediately after opening a path, you could:
      -- exit_quick_open_mode()
    end, {
      buffer = 0,
      nowait = true,
      silent = true,
      desc = "Quick open: " .. path,
    })
  end

  -- 5) <Esc> to exit quick-open mode: clear highlights, unmap
  local function exit_quick_open_mode()
    vim.api.nvim_buf_clear_namespace(0, ns_id, 0, -1)

    -- Remove all letter keymaps
    for label, _ in pairs(label_map) do
      pcall(vim.api.nvim_buf_del_keymap, 0, "n", label)
    end
    -- Also remove <Esc> keymap
    pcall(vim.api.nvim_buf_del_keymap, 0, "n", "<Esc>")

    print("Exited find file paths mode")
  end

  vim.keymap.set("n", "<Esc>", exit_quick_open_mode, { buffer = 0, desc = "Exit find file paths mode" })
end

--------------------------------------------------------------------------------
--  Main function: find paths & start quick-open mode
--------------------------------------------------------------------------------

local function find_paths_and_quick_open()
  local found_paths = find_file_paths()
  if not found_paths or #found_paths == 0 then
    return
  end
  quick_open_mode(found_paths)
end

map("n", "<leader>fp", find_paths_and_quick_open, { desc = "Find file paths" })
