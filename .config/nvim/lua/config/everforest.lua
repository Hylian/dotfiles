require("everforest").setup({
  -- Controls the "hardness" of the background. Options are "soft", "medium" or "hard".
  -- Default is "medium".
  background = "hard",
  -- How much of the background should be transparent. Options are 0, 1 or 2.
  -- Default is 0.
  --
  -- 2 will have more UI components be transparent (e.g. status line
  -- background).
  transparent_background_level = 2,
  -- Whether italics should be used for keywords, builtin types and more.
  italics = false,
  -- Disable italic fonts for comments. Comments are in italics by default, set
  -- this to `true` to make them _not_ italic!
  disable_italic_comments = true,
  ui_contrast = "medium",
  colours_override = function(palette)
    palette.fg = "#4b575e"
    palette.bg0 = "#fffbef"
    palette.bg1_medium = "#f4f0d9"
    --if os.getenv("SSH_TTY") == nil then
      --palette.bg0 = "#ffffff"
      --palette.fg = "#677666"
    --else
      --palette.bg0 = "#fffbef"
      --pallete.fg = "#1a1e20"
    --end
  end,
  on_highlights = function(hl, palette)
    hl.TabLineFill = { fg = palette.none, bg = palette.bg1_medium, sp = palette.red }
    hl.TabLineSep = { fg = palette.bg1_medium, bg = palette.none, sp = palette.red }
    hl.TabLineTabSep = { fg = palette.bg1_medium, bg = palette.bg1_medium, sp = palette.red }
    hl.TabLineInactiveSep = { fg = palette.blue, bg = palette.bg1_medium, sp = palette.red }
    hl.TabLineInactive = { fg = palette.bg5, bg = palette.bg4, sp = palette.red }
    hl.TabLineCurrent = { fg = palette.green, bg = palette.none, sp = palette.red }
  end,
})

require('everforest').load()
