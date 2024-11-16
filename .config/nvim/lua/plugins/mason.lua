return {
  "williamboman/mason.nvim",
  opts = {
    ensure_installed = {
      "css-lsp",
      "stylelint-lsp",
      "graphql-language-service-cli",
      "typos-lsp",
    },
    ui = {
      border = "rounded",
    },
  },
}
