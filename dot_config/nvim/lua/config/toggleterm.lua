require("toggleterm").setup {
  size = function(term)
    if term.direction == "horizontal" then
      return 15
    elseif term.direction == "vertical" then
      return vim.o.columns * 0.4
    end
  end,
  open_mapping = [[<A-Space>]],
  hide_numbers = true,
  shade_filetypes = {},
  shade_terminals = false,
  shading_factor = '-30',
  start_in_insert = true,
  insert_mappings = true,
  terminal_mappings = true,
  persist_size = true,
  direction = 'vertical',
  close_on_exit = true,
  shell = vim.o.shell,
  float_opts = {
    border = 'curved',
    width = 120,
    height = 60,
  },
  highlights = {
    Normal = {
      guibg = "#fffbef",
      guifg = "#333333", -- Add foreground color
    },
    NormalFloat = {
      link = 'Normal'
    },
    FloatBorder = {
      guibg = "#888888", -- Add background color for border
      guifg = "#ffffff", -- Add foreground color for border
    },
  },
}
