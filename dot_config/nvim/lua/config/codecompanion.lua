require("codecompanion").setup({
  strategies = {
    chat = {
      adapter = "anthropic",
      keymaps = {
        hide = {
          modes = {
            n = "}"
          },
          callback = function(chat)
            chat.ui:hide()
          end,
          description = "Hide the chat buffer",
        }
      },
    },
    inline = {
      adapter = "anthropic",
    },
  },
  display = {
    action_palette = {
      provider = "telescope"
    },
    diff = {
      provider = "mini_diff",
    },
  },
  opts = {
    --log_level = "TRACE",
  },
  adapters = {
    anthropic = function()
      return require("codecompanion.adapters").extend("anthropic", {
        schema = {
          model = {
            default = "claude-3-opus-latest",
          },
        },
        env = {
          api_key = "cmd:cat ~/.anthropic",
        },
      })
    end,
    gemini = function()
      return require("codecompanion.adapters").extend("gemini", {
        schema = {
          model = {
            --default = "gemini-2.0-flash-exp",
            default = "gemini-1.5-pro"
          },
        },
        env = {
          api_key = "cmd:cat ~/.gemini",
        },
        handlers = {
          form_parameters = function(self, params, messages)
            return {
              tools = {google_search = {}}
            }
          end,
        }
      })
    end,
  },
})

vim.cmd([[cab cc CodeCompanion]])
