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

1. **Keep `render-markdown.nvim` Active Across Modes (`render_modes = true`):**
   - Configured `MeanderingProgrammer/render-markdown.nvim` in
     [dot_config/nvim/lua/plugins/init.lua](../dot_config/nvim/lua/plugins/init.lua)
     with `opts = { render_modes = true }`.
   - Section icons (`󰫎 `) and document rendering now remain visible in Insert
     and Visual modes, while `anti_conceal` (enabled by default with
     `ignore = { sign = true, ... }`) automatically unconceals the active cursor
     line for raw Markdown editing without hiding its gutter sign.
2. **Pin `vim.opt.signcolumn = 'yes'`:**
   - Set `vim.opt.signcolumn = 'yes'` in
     [dot_config/nvim/init.lua.tmpl](../dot_config/nvim/init.lua.tmpl) so the
     sign column is permanently reserved across all buffers even when zero signs
     are present.
