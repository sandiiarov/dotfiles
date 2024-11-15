return {
  "yetone/avante.nvim",
  event = "VeryLazy",
  lazy = false,
  version = false,
  build = "make",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "stevearc/dressing.nvim",
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    "nvim-tree/nvim-web-devicons",
    "zbirenbaum/copilot.lua",
    {
      "HakonHarnes/img-clip.nvim",
      event = "VeryLazy",
      opts = {
        default = {
          embed_image_as_base64 = false,
          prompt_for_file_name = false,
          drag_and_drop = {
            insert_mode = true,
          },
          use_absolute_path = true,
        },
      },
    },
    {
      "MeanderingProgrammer/render-markdown.nvim",
      opts = {
        file_types = { "markdown", "Avante" },
      },
      ft = { "markdown", "Avante" },
    },
  },
  opts = {
    provider = "dev-gpt",
    auto_suggestions_provider = "dev-gpt",
    behaviour = {
      auto_suggestions = true,
      auto_set_highlight_group = true,
      auto_set_keymaps = true,
      auto_apply_diff_after_generation = false,
      support_paste_from_clipboard = false,
    },
    vendors = {
      ["dev-gpt"] = {
        endpoint = "https://devgptexp.awmai.prod.aws.jpmchase.net/gdevgpt/v1",
        model = "gpt-4",
        api_key_name = "DEVGPT_API_KEY",
        parse_curl_args = function(opts, code_opts)
          return {
            url = opts.endpoint .. "/gpt_plugin_stream?sse=true",
            headers = {
              ["Accept"] = "application/json",
              ["Authorization"] = "Bearer" .. opts.parse_api_key(),
              ["Content-Type"] = "application/json",
              ["x-request-id"] = os.time() * 1000,
            },
            body = {
              model = opts.model,
              messages = require("avante.providers").copilot.parse_message(code_opts),
              max_tokens = 2048,
              stream = true,
            },
          }
        end,
        -- parse_response = function(data_stream, event_state, opts) end,
        -- parse_stream_data = function(data, handler_opts) end,
      },
    },
  },
}
