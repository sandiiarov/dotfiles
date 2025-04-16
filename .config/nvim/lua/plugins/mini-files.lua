return {
  {
    "echasnovski/mini.files",
    init = function()
      vim.api.nvim_create_autocmd("User", {
        pattern = "MiniFilesWindowOpen",
        callback = function(args)
          local win_id = args.data.win_id
          vim.api.nvim_win_set_config(win_id, { border = "rounded" })
        end,
      })

      local nsMiniFiles = vim.api.nvim_create_namespace("mini_files_git")
      local autocmd = vim.api.nvim_create_autocmd
      local _, MiniFiles = pcall(require, "mini.files")

      local gitStatusCache = {}
      local cacheTimeout = 2000
      local uv = vim.uv or vim.loop

      local function isSymlink(path)
        local stat = uv.fs_lstat(path)
        return stat and stat.type == "link"
      end

      local function mapSymbols(status, is_symlink)
        local statusMap = {
          [" M"] = { symbol = "M", hlGroup = "MiniDiffSignChange" }, -- Modified in the working directory
          ["M "] = { symbol = "M", hlGroup = "MiniDiffSignChange" }, -- modified in index
          ["MM"] = { symbol = "MM", hlGroup = "MiniDiffSignChange" }, -- modified in both working tree and index
          ["A "] = { symbol = "A", hlGroup = "MiniDiffSignAdd" }, -- Added to the staging area, new file
          ["AA"] = { symbol = "AA", hlGroup = "MiniDiffSignAdd" }, -- file is added in both working tree and index
          ["D "] = { symbol = "D", hlGroup = "MiniDiffSignDelete" }, -- Deleted from the staging area
          ["AM"] = { symbol = "AM", hlGroup = "MiniDiffSignChange" }, -- added in working tree, modified in index
          ["AD"] = { symbol = "AD", hlGroup = "MiniDiffSignChange" }, -- Added in the index and deleted in the working directory
          ["R "] = { symbol = "R", hlGroup = "MiniDiffSignChange" }, -- Renamed in the index
          ["U "] = { symbol = "U", hlGroup = "MiniDiffSignChange" }, -- Unmerged path
          ["UU"] = { symbol = "UU", hlGroup = "MiniDiffSignAdd" }, -- file is unmerged
          ["UA"] = { symbol = "UA", hlGroup = "MiniDiffSignAdd" }, -- file is unmerged and added in working tree
          ["??"] = { symbol = "??", hlGroup = "MiniDiffSignDelete" }, -- Untracked files
          ["!!"] = { symbol = "!!", hlGroup = "NonText" }, -- Ignored files
        }

        local result = statusMap[status] or { symbol = "", hlGroup = "" }
        local gitSymbol = result.symbol
        local gitHlGroup = result.hlGroup

        local symlinkSymbol = is_symlink and "↩" or ""

        local combinedSymbol = (symlinkSymbol .. gitSymbol):gsub("^%s+", ""):gsub("%s+$", "")
        local combinedHlGroup = is_symlink and "MiniDiffSignDelete" or gitHlGroup

        return combinedSymbol, combinedHlGroup
      end

      local function fetchGitStatus(cwd, callback)
        local clean_cwd = cwd:gsub("^minifiles://%d+/", "")
        local function on_exit(content)
          if content.code == 0 then
            callback(content.stdout)
          end
        end
        vim.system({ "git", "status", "--ignored", "--porcelain" }, { text = true, cwd = clean_cwd }, on_exit)
      end

      local function updateMiniWithGit(buf_id, gitStatusMap)
        vim.schedule(function()
          local nlines = vim.api.nvim_buf_line_count(buf_id)
          local cwd = vim.fn.getcwd()
          local escapedcwd = cwd and vim.pesc(cwd)
          escapedcwd = vim.fs.normalize(escapedcwd)

          for i = 1, nlines do
            local entry = MiniFiles.get_fs_entry(buf_id, i)
            if not entry then
              break
            end

            local relativePath = entry.path:gsub("^" .. escapedcwd .. "/", "")
            if entry.fs_type == "directory" then
              relativePath = relativePath .. "/"
            end
            local status = gitStatusMap[relativePath]

            if status then
              local symbol, hlGroup = mapSymbols(status, isSymlink(entry.path))
              vim.api.nvim_buf_set_extmark(buf_id, nsMiniFiles, i - 1, 0, {
                virt_text = { { symbol, hlGroup } },
                virt_text_pos = "right_align",
                hl_mode = "combine",
                priority = 2,
              })
              local line = vim.api.nvim_buf_get_lines(buf_id, i - 1, i, false)[1]
              local nameStartCol = line:find(vim.pesc(entry.name)) or 0

              if nameStartCol > 0 then
                vim.api.nvim_buf_set_extmark(buf_id, nsMiniFiles, i - 1, nameStartCol - 1, {
                  end_col = nameStartCol + #entry.name - 1,
                  hl_group = hlGroup,
                })
              end
            else
            end
          end
        end)
      end

      local function parseGitStatus(content)
        local gitStatusMap = {}
        for line in content:gmatch("[^\r\n]+") do
          local status, filePath = string.match(line, "^(..)%s+(.*)")
          gitStatusMap[filePath] = status
        end
        return gitStatusMap
      end

      local function updateGitStatus(buf_id)
        if not vim.fs.root(buf_id, ".git") then
          return
        end
        local cwd = vim.fs.root(buf_id, ".git")
        -- local cwd = vim.fn.expand("%:p:h")
        local currentTime = os.time()

        if gitStatusCache[cwd] and currentTime - gitStatusCache[cwd].time < cacheTimeout then
          updateMiniWithGit(buf_id, gitStatusCache[cwd].statusMap)
        else
          fetchGitStatus(cwd, function(content)
            local gitStatusMap = parseGitStatus(content)
            gitStatusCache[cwd] = {
              time = currentTime,
              statusMap = gitStatusMap,
            }
            updateMiniWithGit(buf_id, gitStatusMap)
          end)
        end
      end

      local function clearCache()
        gitStatusCache = {}
      end

      local function augroup(name)
        return vim.api.nvim_create_augroup("MiniFiles_" .. name, { clear = true })
      end

      autocmd("User", {
        group = augroup("start"),
        pattern = "MiniFilesExplorerOpen",
        callback = function()
          local bufnr = vim.api.nvim_get_current_buf()
          updateGitStatus(bufnr)
        end,
      })

      autocmd("User", {
        group = augroup("close"),
        pattern = "MiniFilesExplorerClose",
        callback = function()
          clearCache()
        end,
      })

      autocmd("User", {
        group = augroup("update"),
        pattern = "MiniFilesBufferUpdate",
        callback = function(args)
          local bufnr = args.data.buf_id
          local cwd = vim.fs.root(bufnr, ".git")
          if gitStatusCache[cwd] then
            updateMiniWithGit(bufnr, gitStatusCache[cwd].statusMap)
          end
        end,
      })
    end,
    opts = {
      windows = {
        preview = true,
        width_focus = 40,
        width_nofocus = 40,
        width_preview = 80,
      },
      options = {
        permanent_delete = false,
        use_as_default_explorer = true,
      },
      mappings = {
        go_in = "L",
        go_in_plus = "l",
        synchronize = "s",
      },
    },
    keys = {
      {
        "<leader>e",
        function()
          require("mini.files").open(vim.api.nvim_buf_get_name(0), true)
        end,
        desc = "Open mini.files (Directory of Current File)",
      },
      {
        "<leader>E",
        function()
          require("mini.files").open(vim.uv.cwd(), true)
        end,
        desc = "Open mini.files (cwd)",
      },
    },
  },
}
