local configuration = vim.fn['everforest#get_configuration']()
local palette = vim.fn['everforest#get_palette'](configuration.background, configuration.colors_override)

if configuration.transparent_background == 2 then
  palette.bg1 = palette.none
end

vim.api.nvim_set_hl(0, 'DiffviewDiffAddAsDelete', { bg = palette.bg_blue[0] })
vim.api.nvim_set_hl(0, 'DiffviewDiffDelete', { bg = palette.bg_blue[0] })

vim.api.nvim_set_hl(0, 'DiffText', { bg = palette.bg_yellow[0] })
vim.api.nvim_set_hl(0, 'DiffChange', { bg = palette.bg_blue[0] })
vim.api.nvim_set_hl(0, 'DiffDelete', { bg = palette.bg_red[0] })
vim.api.nvim_set_hl(0, 'DiffAdd', { bg = palette.bg_green[0] })

local _M = {
    bg = palette.statusline1[0],
    fg = palette.bg0[0],
    yellow = palette.yellow[0],
    cyan = palette.aqua[0],
    darkblue = palette.blue[0],
    green = palette.green[0],
    orange = palette.orange[0],
    violet = palette.purple[0],
    magenta = palette.red[0],
    blue = palette.blue[0],
    red = palette.red[0]
}

return _M
