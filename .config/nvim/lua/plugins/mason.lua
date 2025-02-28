return {
  "williamboman/mason.nvim",
  opts = {
    ensure_installed = {
      "css-lsp",
      "stylelint-lsp",
      "cssmodules-language-server",
      "graphql-language-service-cli",
      "typos-lsp",
    },
    ui = {
      border = "rounded",
    },
  },
}
