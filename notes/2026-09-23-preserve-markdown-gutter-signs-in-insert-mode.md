# Preserve Markdown Gutter Signs and Column Width in Insert Mode

**Date:** 2026-09-23  
**Context:** When editing Markdown files in Neovim, switching from Normal mode
to Insert mode caused the section icons (`󰫎 `) in the signcolumn gutter to
disappear and the entire buffer text to shift left by one column.

## Root Cause

1. **`render-markdown.nvim` Default `render_modes`:**
   - `MeanderingProgrammer/render-markdown.nvim` defaults to
     `render_modes = { 'n', 'c', 't' }`.
   - Upon entering Insert mode (`'i'`), `Updater:run()` saw that `'i'` was not
     in `render_modes` and invoked `Updater:clear()`, deleting all extmarks in
     the `render-markdown.nvim` namespace—including the heading (`󰫎 `) and
     fenced code block icons placed in the sign column.
2. **Neovim Default `signcolumn = 'auto'`:**
   - Because `vim.opt.signcolumn` was not explicitly configured in
     [dot_config/nvim/init.lua.tmpl](../dot_config/nvim/init.lua.tmpl), Neovim
     defaulted to `signcolumn = 'auto'`.
   - Whenever a Markdown file had no other active signs (e.g. no git hunk or
     diagnostic signs), clearing `render-markdown.nvim`'s section signs on
     `InsertEnter` caused Neovim to collapse the sign column completely,
     shifting all buffer text horizontally by one column.

## Fix

1. **Keep `render-markdown.nvim` Active Across Modes & Conceal Cursor Line in Normal Mode:**
   - Configured `MeanderingProgrammer/render-markdown.nvim` in
     [dot_config/nvim/lua/plugins/init.lua](../dot_config/nvim/lua/plugins/init.lua)
     with `render_modes = true`, `anti_conceal = { disabled_modes = { 'n' } }`,
     and `win_options = { concealcursor = { rendered = 'nc' } }`.
   - In Normal mode (`'n'`), both `render-markdown.nvim`'s `anti_conceal` and
     Neovim's window `concealcursor` keep the active cursor line completely
     rendered (no raw Markdown syntax revealed when moving the cursor).
   - In Insert mode (`'i'`), `anti_conceal` unconceals only the active cursor
     line for raw Markdown editing while keeping section icons (`󰫎 `) in the
     gutter and all other lines rendered.
2. **Pin `vim.opt.signcolumn = 'yes'`:**
   - Set `vim.opt.signcolumn = 'yes'` in
     [dot_config/nvim/init.lua.tmpl](../dot_config/nvim/init.lua.tmpl) so the
     sign column is permanently reserved across all buffers even when zero signs
     are present.
3. **Restore Native Visual `r` Character Replacement (`v_r`):**
   - Removed legacy `map('v', 'r', '"_dp')` from
     [dot_config/nvim/lua/keybindings.lua](../dot_config/nvim/lua/keybindings.lua),
     which was deleting the visual selection to the black-hole register and
     pasting the clipboard the instant `r` was pressed.
   - `r<char>` in visual/block mode now restores native Vim character
     replacement (`v_r`), while built-in visual `P` (`v_P`) provides native
     register-preserving paste over visual selections.
