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
