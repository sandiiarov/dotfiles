return {
  "nvim-neotest/neotest",
  dependencies = {
    "nvim-neotest/neotest-jest",
    "marilari88/neotest-vitest",
  },
  opts = {
    adapters = {
      ["neotest-jest"] = {
        env = { CI = true },
        cwd = function(path)
          local root_path = require("lspconfig").util.root_pattern("package.json")(path)
          return root_path or vim.fn.getcwd()
        end,
      },
      ["neotest-vitest"] = {
        cwd = function(path)
          local root_path = require("lspconfig").util.root_pattern("package.json")(path)
          return root_path or vim.fn.getcwd()
        end,
      },
    },
  },
}
