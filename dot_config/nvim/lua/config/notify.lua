require('notify').setup({
    fps = 30,
    render = "minimal",
    max_width = function()
        return math.max(60, math.floor(vim.o.columns * 0.75))
    end,
    minimum_width = 15,
    stages = "fade",
    timeout = 3000,
})
