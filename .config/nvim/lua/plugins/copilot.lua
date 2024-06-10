return {
  "zbirenbaum/copilot.lua",
  event = "InsertEnter",
  opts = {
    suggestion = {
      enabled = true,
      auto_trigger = true,
      debounce = 0,
    },
    filetypes = {
      ["*"] = true,
    },
  },
}
