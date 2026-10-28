# Neovim Diffview Delta-Style Highlights & Split Auto-Resize

*Date: 2026-10-28*

## Context & Problem

1. **Diff Visual Styling:**
   - `neanias/everforest-nvim` defaults `DiffText` (and Neovim 0.12's linked
     `DiffTextAdd`) to `{ fg = palette.bg0, bg = palette.blue }` (`#fffbef` white
     text on `#3a94c5` opaque blue in `everforest-light`). With Neovim 0.12's
     default `inline:char` in `diffopt`, every modified word/character span on
     both sides of a diff was painted with an opaque blue block and white text,
     wiping out Treesitter syntax highlighting and making both old (left) and
     new (right) panes look identical in color on modified lines.
   - `vim.opt.fillchars` did not set `diff`, leaving Neovim's default `-`
     (`--------`) dash lines across empty filler blocks opposite added/deleted
     hunks.
2. **Diff Splits Not Auto-Resizing:**
   - When the terminal window or Zellij pane was resized (`VimResized`), Neovim's
     built-in window resize logic saw `winfixwidth = true` on `Diffview`'s panel
     window and gave 100% of the added/removed columns to only the rightmost
     diff split (leaving the left diff split frozen at its previous width).
   - Additionally, in [dot_config/nvim/lua/config/focus.lua](../dot_config/nvim/lua/config/focus.lua),
     the `FocusDisable` `WinEnter` autocmd was registered *after*
     `require("focus").setup()`, causing `focus.resize()` to execute first on
     newly split windows before `vim.w.focus_disable` was set and crushing
     `DiffviewOpen` splits on viewports narrower than `equalise_min_cols` (166).

## Solution

1. **Delta-Style Side-by-Side Highlights Preserving Treesitter Syntax:**
   - Updated [dot_config/nvim/lua/config/everforest.lua.tmpl](../dot_config/nvim/lua/config/everforest.lua.tmpl)
     (`on_highlights`) to use the active colorscheme's `diff_add`,
     `diff_add_emph`, `diff_del`, `diff_del_emph`, and `grey2` tokens from
     [.chezmoidata.toml](../.chezmoidata.toml) with `fg = palette.none` so
     Treesitter syntax colors remain intact across full lines and inline spans.
   - Configured `hooks.view_post_layout` in
     [dot_config/nvim/lua/config/diffview.lua](../dot_config/nvim/lua/config/diffview.lua)
     so `diff2` maps the left ("old") split (`a`) to soft red
     (`DiffviewDiffChangeDelete` = `diff_del`) with deeper red inline emphasis
     (`DiffviewDiffTextDelete` = `diff_del_emph` for `DiffText` and
     `DiffTextAdd`), and the right ("new") split (`b`) to soft green
     (`DiffviewDiffChangeAdd` = `diff_add`) with deeper green inline emphasis
     (`DiffviewDiffTextAdd` = `diff_add_emph`).
2. **Diagonal Hatch Filler Lines & Histogram Linematch:**
   - Added `vim.opt.fillchars:append({ diff = '╱', foldopen = '', foldclose = '', foldsep = ' ' })`
     and upgraded `vim.opt.diffopt` with `algorithm:histogram` and
     `linematch:60` in [dot_config/nvim/init.lua.tmpl](../dot_config/nvim/init.lua.tmpl).
3. **Automatic 50/50 Split Rebalancing on Resize & `focus.nvim` Guard:**
   - Added a `VimResized` autocmd in [dot_config/nvim/init.lua.tmpl](../dot_config/nvim/init.lua.tmpl)
     that re-applies `view.panel:resize()` (if a Diffview panel is open) and
     executes `wincmd =` across tabpages so the two diff splits always stay
     evenly balanced 50/50 when resizing Ghostty or Zellij panes.
   - Moved the `FocusDisable` augroup registration before `require("focus").setup()`
     in [dot_config/nvim/lua/config/focus.lua](../dot_config/nvim/lua/config/focus.lua)
     and disabled `focus.nvim` whenever a Diffview tabpage (`vim.t.diffview_view_initialized`
     or `diffview.lib.get_current_view()`) or diff window (`vim.wo.diff`) is active.
4. **Compact File History Panel (`height = 10`):**
   - Set `file_history_panel.win_config = { position = "bottom", height = 10 }`
     (down from the default 16 rows) in
     [dot_config/nvim/lua/config/diffview.lua](../dot_config/nvim/lua/config/diffview.lua)
     so side-by-side diffs get 6 extra rows of vertical breathing room.
