local catppuccin = require("catppuccin.palettes").get_palette("mocha")

return {
  "sandiiarov/package-info.nvim",
  dependencies = {
    "MunifTanjim/nui.nvim",
  },
  ft = "json",
  opts = {
    autostart = false,
    colors = {
      up_to_date = catppuccin.surface1,
      outdated = catppuccin.surface1,
      invalid = catppuccin.maroon,
    },
    icons = {
      style = {
        up_to_date = "  ",
        outdated = " 󰚰 ",
        invalid = " 󰈅 ",
      },
    },
  },
  config = function(_, opts)
    require("package-info").setup(opts)

    vim.cmd([[highlight PackageInfoUpToDateVersion guifg=]] .. opts.colors.up_to_date)
    vim.cmd([[highlight PackageInfoOutdatedVersion guifg=]] .. opts.colors.outdated)

    vim.keymap.set({ "n" }, "<LEADER>ks", require("package-info").show, {
      silent = true,
      noremap = true,
      desc = "Show dependency versions",
    })
    vim.keymap.set({ "n" }, "<LEADER>kc", require("package-info").hide, {
      silent = true,
      noremap = true,
      desc = "Hide dependency versions",
    })
    vim.keymap.set({ "n" }, "<LEADER>kt", require("package-info").toggle, {
      silent = true,
      noremap = true,
      desc = "Toggle dependency versions",
    })
    vim.keymap.set({ "n" }, "<LEADER>ku", require("package-info").update, {
      silent = true,
      noremap = true,
      desc = "Update dependency on the line",
    })
    vim.keymap.set({ "n" }, "<LEADER>kd", require("package-info").delete, {
      silent = true,
      noremap = true,
      desc = "Delete dependency on the line",
    })
    vim.keymap.set({ "n" }, "<LEADER>ki", require("package-info").install, {
      silent = true,
      noremap = true,
      desc = "Install a new dependency",
    })
    vim.keymap.set({ "n" }, "<LEADER>kp", require("package-info").change_version, {
      silent = true,
      noremap = true,
      desc = "Install a different dependency version",
    })
  end,
}
