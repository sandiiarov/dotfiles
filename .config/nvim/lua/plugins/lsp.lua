return {
  {
    "neovim/nvim-lspconfig",
    inlay_hints = {
      enabled = false,
    },
    opts = {
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
          settings = {
            stylelintplus = {
              autoFixOnSave = true,
              autoFixOnFormat = true,
            },
          },
        },
      },
      diagnostics = {
        virtual_text = {
          spacing = 2,
          prefix = "",
        },
      },
    },
  }
}
