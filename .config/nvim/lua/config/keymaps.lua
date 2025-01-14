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
--  This is the new function to "check or trim"
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
--  Regex (or pattern) to find raw paths in lines
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
--  The main function: find file paths
--------------------------------------------------------------------------------
local function find_file_paths()
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local found_paths = {}

  local lazy_root = get_lazy_root()
  local cwd = get_cwd()

  for line_nr, line in ipairs(lines) do
    local raw_paths = extract_raw_paths_from_line(line)

    for _, raw_path in ipairs(raw_paths) do
      -- Step 1: generate expansions
      local expansions = compute_possible_paths(raw_path, lazy_root, cwd)

      -- Step 2: for each expansion, "check or trim"
      local actual_path = nil
      for _, candidate in ipairs(expansions) do
        local maybe_fixed = try_trim_and_check(candidate)
        if maybe_fixed then
          actual_path = maybe_fixed
          break
        end
      end

      -- If we got a valid path, highlight it
      if actual_path then
        -- find the substring in the line (for highlight positions)
        local s, e = string.find(line, raw_path, 1, true)
        if s then
          table.insert(found_paths, {
            match = raw_path,
            path_to_open = actual_path,
            line_nr = line_nr - 1,
            start_col = s - 1,
            end_col = e,
          })
        end
      end
    end
  end

  if #found_paths == 0 then
    print("No valid file paths found in current buffer.")
    return
  end

  -- Print summary
  print("Found paths that exist:")
  for _, entry in ipairs(found_paths) do
    print(("%s -> %s (line %s, col %s)"):format(entry.match, entry.path_to_open, entry.line_nr, entry.start_col))
  end

  return found_paths
end

--------------------------------------------------------------------------------
--  The highlight/dim part
--------------------------------------------------------------------------------
local function find_and_dim_others()
  local found_paths = find_file_paths()
  if not found_paths or #found_paths == 0 then
    return
  end

  local ns_id = vim.api.nvim_create_namespace("DimFilePathsNS")
  local line_count = vim.api.nvim_buf_line_count(0)

  -- Dim entire buffer
  for line_idx = 0, line_count - 1 do
    vim.api.nvim_buf_add_highlight(0, ns_id, "Conceal", line_idx, 0, -1)
  end

  -- Highlight recognized paths
  for _, entry in ipairs(found_paths) do
    vim.api.nvim_buf_add_highlight(0, ns_id, "Search", entry.line_nr, entry.start_col, entry.end_col)
  end
end

--------------------------------------------------------------------------------
-- Insert a small label at the beginning of each path, highlight that label
--------------------------------------------------------------------------------
local function label_and_highlight_paths()
  local found_paths = find_file_paths()
  if not found_paths or #found_paths == 0 then
    print("No paths found.")
    return
  end

  -- We create a namespace for these highlights, so we can clear them if desired
  local ns_id = vim.api.nvim_create_namespace("LabelFilePathsNS")

  -- 1) Sort matches in descending order of line_nr, then start_col
  table.sort(found_paths, function(a, b)
    if a.line_nr == b.line_nr then
      return a.start_col > b.start_col
    else
      return a.line_nr > b.line_nr
    end
  end)

  -- 2) Insert label + highlight. We'll just use the same label "[ab]" for all,
  --    but you could generate unique labels per path if you like.
  local label = "ab" -- or generate dynamically like "[aa]", "[ab]", "[ac]" ...
  for _, match in ipairs(found_paths) do
    -- Insert the label text at (line_nr, start_col)
    -- This does not delete any existing text, it just adds our label
    vim.api.nvim_buf_set_text(0, match.line_nr, match.start_col, match.line_nr, match.start_col, { label })

    -- Now highlight the label region using "Search"
    -- The label is exactly #label characters long, starting at start_col
    vim.api.nvim_buf_add_highlight(0, ns_id, "FlashLabel", match.line_nr, match.start_col, match.start_col + #label)
  end

  print("Done labeling paths!")
end

map("n", "<leader>fp", label_and_highlight_paths, { desc = "Find file path in buffer" })
