local catppuccin = require("catppuccin.palettes").get_palette("mocha")

return {
  "sandiiarov/package-info.nvim",
  dependencies = {
    "MunifTanjim/nui.nvim",
  },
  ft = "json",
  opts = {
    colors = {
      up_to_date = catppuccin.teal,
      outdated = catppuccin.maroon,
    },
  },
  config = function(_, opts)
    require("package-info").setup(opts)

    vim.cmd([[highlight PackageInfoUpToDateVersion guifg=]] .. opts.colors.up_to_date)
    vim.cmd([[highlight PackageInfoOutdatedVersion guifg=]] .. opts.colors.outdated)
  end,
}
