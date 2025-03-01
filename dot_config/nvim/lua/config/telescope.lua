require('telescope').setup {
  defaults = {
    mappings = {
      n = {
        ["<C-j>"] = "move_selection_next",
        ["<C-k>"] = "move_selection_previous",
      },
      i = {
        ["<C-j>"] = "move_selection_next",
        ["<C-k>"] = "move_selection_previous",
      }
    },
  },
  pickers = {
    find_files = {
      theme = "dropdown",
    },
    codecompanion = {
      theme = "ivy",
    },
  },
}

require('telescope').load_extension('fzf')
