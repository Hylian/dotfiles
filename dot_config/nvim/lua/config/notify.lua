require('notify').setup({
  fps = 30,
  top_down = false,
  render = 'compact',
  stages = 'fade',
  minimum_width = 45,
  max_width = function()
    return math.min(75, math.floor(vim.o.columns * 0.6))
  end,
  max_height = function()
    return math.min(8, math.floor(vim.o.lines * 0.3))
  end,
  background_colour = 'NormalFloat',
  timeout = 3000,
})
