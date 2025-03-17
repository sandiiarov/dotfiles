local catppuccin = require("catppuccin.palettes").get_palette()

return {
  "vuki656/package-info.nvim",
  dependencies = {
    "MunifTanjim/nui.nvim",
  },
  ft = "json",
  opts = {
    colors = {
      up_to_date = catppuccin.green,
      outdated = catppuccin.red,
    },
  },
  config = function(_, opts)
    require("package-info").setup(opts)

    vim.cmd([[highlight PackageInfoUpToDateVersion guifg=]] .. opts.colors.up_to_date)
    vim.cmd([[highlight PackageInfoOutdatedVersion guifg=]] .. opts.colors.outdated)
  end,
}
