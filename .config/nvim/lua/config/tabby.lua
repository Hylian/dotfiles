local theme = {
  fill = 'TabLineFill',
  head = 'TabLineSep',
  sep = 'TabLineSep',
  tabsep = 'TabLineTabSep',
  current_tab = 'TabLineCurrent',
  inactive_tab = 'TabLineInactive',
  inactive_tab_sep = 'TabLineInactiveSep',
  tab = 'TabLine',
  win = 'TabLine',
  tail = 'TabLineSep',
}

local function no_nvimtree(win)
  return not string.match(win.buf_name(), 'NvimTree')
end

require('tabby').setup({
  line = function(line)
    return {
      {
        { '', hl = theme.head },
        { ' ', hl = theme.fill },
      },
      line.tabs().foreach(function(tab)
        if tab.is_current() then
          return {
            line.sep('', theme.tabsep, theme.current_tab),
            tab.in_jump_mode() and tab.jump_key() or tab.number(),
            tab.name(),
            line.sep('', theme.tabsep, theme.current_tab),
            hl = theme.current_tab,
            margin = ' ',
          }
        else
          return {
            line.sep('', theme.inactive_tab, theme.inactive_tab_sep),
            tab.in_jump_mode() and tab.jump_key() or tab.number(),
            tab.name(),
            line.sep('', theme.inactive_tab, theme.inactive_tab_sep),
            hl = theme.inactive_tab,
            margin = ' ',
          }
        end
      end),
      line.spacer(),
      line.wins_in_tab(line.api.get_current_tab()).filter(no_nvimtree).foreach(function(win)
        if win.is_current() then
          return {
            line.sep('', theme.tabsep, theme.current_tab),
            win.buf_name(),
            line.sep('', theme.tabsep, theme.current_tab),
            hl = theme.current_tab,
            margin = ' ',
          }
        else
          return {
            line.sep('', theme.inactive_tab, theme.inactive_tab_sep),
            win.buf_name(),
            line.sep('', theme.inactive_tab, theme.inactive_tab_sep),
            hl = theme.inactive_tab,
            margin = ' ',
          }
        end
      end),
      {
        { ' ', hl = theme.fill },
        { '', hl = theme.head },
      },
      hl = theme.fill,
    }
  end,
  -- option = {}, -- setup modules' option,
})
