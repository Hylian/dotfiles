require('trim').setup({
  -- if you want to ignore markdown file.
  -- you can specify filetypes.
  ft_blocklist = {"markdown"},

  patterns = {},

  -- if you want to disable trim on write by default
  trim_on_write = true,

  -- highlight trailing spaces
  highlight = false,
  highlight_bg = '#ffe7de',
  highlight_ctermbg = 'red',
})
