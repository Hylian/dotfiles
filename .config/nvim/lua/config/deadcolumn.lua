require('deadcolumn').setup({
    scope = 'line', ---@type string|fun(): integer
    ---@type string[]|fun(mode: string): boolean
    modes = function(mode)
        return mode:find('^[ictRss\x13]') ~= nil
    end,
    blending = {
        threshold = 0.75,
        colorcode = '#fffbef',
        hlgroup = { 'Normal', 'bg' },
    },
    warning = {
        alpha = 0.4,
        offset = 0,
        colorcode = '#bec5b2',
        hlgroup = { 'Error', 'bg' },
    },
    extra = {
        ---@type string?
        follow_tw = nil,
    },
})
