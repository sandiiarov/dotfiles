return {
  "mg979/vim-visual-multi",
  lazy = false,
  priority = 100,
  init = function()
    vim.g.VM_maps = {
      ["Find Under"] = "<C-d>",
    }
  end,
}
