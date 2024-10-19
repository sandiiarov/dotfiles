return {
  "neovim/nvim-lspconfig",
  opts = {
    inlay_hints = {
      enabled = false,
    },
    servers = {
      eslint = {
        filetypes = {
          "javascript",
          "javascriptreact",
          "typescript",
          "typescriptreact",
          "graphql",
        },
      },
      stylelint_lsp = {
        filetypes = {
          "css",
          "scss",
          "less",
          "sass",
          "vue",
          "html",
          "javascript",
          "javascriptreact",
          "typescript",
          "typescriptreact",
        },
        settings = {
          stylelintplus = {
            autoFixOnSave = true,
            autoFixOnFormat = true,
          },
        },
      },
      graphql = {
        filetypes = {
          "graphql",
          "typescript",
          "typescriptreact",
          "javascript",
          "javascriptreact",
        },
      },
    },
  },
}
