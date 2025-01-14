-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
local map = LazyVim.safe_keymap_set

-- Resize window using <ctrl> arrow keys
map("n", "<C-S-k>", "<cmd>resize +2<cr>", { desc = "Increase Window Height" })
map("n", "<C-S-j>", "<cmd>resize -2<cr>", { desc = "Decrease Window Height" })
map("n", "<C-S-h>", "<cmd>vertical resize -2<cr>", { desc = "Decrease Window Width" })
map("n", "<C-S-l>", "<cmd>vertical resize +2<cr>", { desc = "Increase Window Width" })

local Path = require("plenary.path")

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

local function expand_path(raw)
  return Path:new(raw):expand()
end

local function file_exists(path_str)
  local p = Path:new(path_str)
  return p:exists() and p:is_file()
end

local function try_trim_and_check(path_str)
  if file_exists(path_str) then
    return path_str
  end
  local pattern = "['\"`()%[%]{}<>,%.]"
  local start_i = 1
  local end_i = #path_str
  while start_i <= end_i do
    local first_char = path_str:sub(start_i, start_i)
    local last_char = path_str:sub(end_i, end_i)
    if first_char:match(pattern) then
      start_i = start_i + 1
    elseif last_char:match(pattern) then
      end_i = end_i - 1
    else
      break
    end
  end
  local trimmed = path_str:sub(start_i, end_i)
  if trimmed ~= "" and file_exists(trimmed) then
    return trimmed
  end
  return nil
end

local function compute_possible_paths(raw_path, lazy_root, cwd)
  local expanded_self = expand_path(raw_path)
  local expansions = {
    Path:new(lazy_root, expanded_self):expand(),
    Path:new(cwd, expanded_self):expand(),
    expanded_self,
  }
  if not expanded_self:match("^/") then
    local slash_version = "/" .. expanded_self
    table.insert(expansions, slash_version)
    table.insert(expansions, Path:new(cwd, slash_version):expand())
    table.insert(expansions, Path:new(lazy_root, slash_version):expand())
  end
  return expansions
end

local function extract_tokens_from_line(line)
  local results = {}
  for token in line:gmatch("%S+") do
    table.insert(results, token)
  end
  return results
end

local function find_file_paths()
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local found_paths = {}
  local lazy_root = get_lazy_root()
  local cwd = get_cwd()
  for line_nr, line in ipairs(lines) do
    local tokens = extract_tokens_from_line(line)
    local search_start = 1
    for _, token in ipairs(tokens) do
      local s, e = string.find(line, token, search_start, true)
      if s and e then
        search_start = e + 1
      else
        s, e = 1, 1
      end
      local expansions = compute_possible_paths(token, lazy_root, cwd)
      local actual_path = nil
      for _, candidate in ipairs(expansions) do
        local maybe_fixed = try_trim_and_check(candidate)
        if maybe_fixed then
          actual_path = maybe_fixed
          break
        end
      end
      if actual_path then
        table.insert(found_paths, {
          match = token,
          path_to_open = actual_path,
          line_nr = line_nr - 1,
          start_col = s - 1,
          end_col = e,
        })
      end
    end
  end
  if #found_paths == 0 then
    print("No valid file paths found in current buffer.")
    return
  end
  print("Found paths that exist:")
  for _, entry in ipairs(found_paths) do
    print(("%s -> %s (line %d, col %d)"):format(entry.match, entry.path_to_open, entry.line_nr, entry.start_col))
  end
  return found_paths
end

local function exit_search_mode(ns_id, augroup)
  vim.api.nvim_buf_clear_namespace(0, ns_id, 0, -1)
  for _, key in ipairs({ "n", "N", "<Esc>" }) do
    pcall(vim.api.nvim_buf_del_keymap, 0, "n", key)
  end
  if augroup then
    pcall(vim.api.nvim_clear_autocmds, { group = augroup })
  end
  print("Exited path search mode.")
end

local function attach_mode_changed_autocmd(ns_id, augroup)
  vim.api.nvim_create_autocmd("ModeChanged", {
    group = augroup,
    pattern = "*",
    callback = function()
      local m = vim.api.nvim_get_mode().mode
      if not m:match("^n") then
        exit_search_mode(ns_id, augroup)
      end
    end,
  })
end

local function enter_search_mode(found_paths, ns_id)
  if not found_paths or #found_paths == 0 then
    return
  end
  local current_idx = 1
  local function jump_to_path(p)
    if not p then
      return
    end
    vim.api.nvim_win_set_cursor(0, { p.line_nr + 1, p.start_col })
  end
  jump_to_path(found_paths[current_idx])
  local function jump_next()
    current_idx = current_idx % #found_paths + 1
    jump_to_path(found_paths[current_idx])
  end
  local function jump_prev()
    current_idx = (current_idx - 2) % #found_paths + 1
    jump_to_path(found_paths[current_idx])
  end
  local augroup = vim.api.nvim_create_augroup("FilePathSearchMode", { clear = true })
  attach_mode_changed_autocmd(ns_id, augroup)
  vim.keymap.set("n", "n", jump_next, { buffer = 0 })
  vim.keymap.set("n", "N", jump_prev, { buffer = 0 })
  vim.keymap.set("n", "<Esc>", function()
    exit_search_mode(ns_id, augroup)
  end, { buffer = 0 })
end

local function find_and_dim_others()
  local found_paths = find_file_paths()
  if not found_paths or #found_paths == 0 then
    return
  end
  local ns_id = vim.api.nvim_create_namespace("DimFilePathsNS")
  for _, entry in ipairs(found_paths) do
    vim.api.nvim_buf_add_highlight(0, ns_id, "Search", entry.line_nr, entry.start_col, entry.end_col)
    vim.api.nvim_buf_add_highlight(0, ns_id, "Underlined", entry.line_nr, entry.start_col, entry.end_col)
  end
  enter_search_mode(found_paths, ns_id)
end

vim.keymap.set("n", "<leader>fp", find_and_dim_others, {})

-- Finally, bind the main function to <leader>fp
map("n", "<leader>fp", find_and_dim_others, { desc = "Find file paths in buffer and enter search mode" })
