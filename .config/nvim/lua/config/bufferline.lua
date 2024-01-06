require("bufferline").setup{
  options = {
    mode = "tabs",
    numbers = "ordinal",
    tab_size = 12,
    diagnostics = "coc",
    diagnostics_update_in_insert = false,
    diagnostics_indicator = function(count, level, diagnostics_dict, context)
      return "("..count..")"
    end,
    show_buffer_icons = false,
    show_buffer_close_icons = false,
    separator_style = "thin",
    offsets = {
      {
        filetype = "NvimTree",
        text = function()
          return vim.fn.getcwd()
        end,
        highlight = "Directory",
        text_align = "left"
      }
    }
  },
  highlights = {
    buffer_selected = {
      italic = false
    },
    diagnostic_selected = {
      italic = false
    },
    info_selected = {
      italic = false
    },
    info_diagnostic_selected = {
      italic = false
    },
    warning_selected = {
      italic = false
    },
    warning_diagnostic_selected = {
      italic = false
    },
    error_selected = {
      italic = false
    },
    error_diagnostic_selected = {
      italic = false
    },
    pick_selected = {
      italic = false
    },
    pick_visible = {
      italic = false
    },
    pick = {
      italic = false
    },
  },
}
