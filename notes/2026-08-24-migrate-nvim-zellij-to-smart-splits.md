# Migrating Neovim ↔ Zellij Integration to `smart-splits.nvim` & Async CLI Actions (｡•̀ᴗ-)✧

*Date: 2026-08-24*

## Motivation & Architecture Shift

Our Neovim configuration previously relied on `fresh2dev/zellij.vim` (an older Vimscript port of `vim-tmux-navigator`) for directional window-edge navigation into Zellij panes, paired with synchronous subshell calls (`vim.fn.system("zellij action ...")`) for all other multiplexer actions like tab switching, pane reordering, and layout swaps.

We migrated to a cleaner, modern Lua architecture with two key upgrades:

1. **`mrjones2014/smart-splits.nvim` for Navigation & Resizing:**
   - Swapped out `fresh2dev/zellij.vim` in [dot_config/nvim/lua/plugins/init.lua](../dot_config/nvim/lua/plugins/init.lua).
   - Rebound `<A-h/j/k/l>` in [dot_config/nvim/lua/keybindings.lua](../dot_config/nvim/lua/keybindings.lua) to `require('smart-splits').move_cursor_left/down/up/right()`.
   - Added directional split resizing across Neovim splits and Zellij panes via `<A-C-h/j/k/l>` mapped to `require('smart-splits').resize_left/down/up/right()`.
   - `smart-splits.nvim` natively detects `$ZELLIJ` when running inside a Zellij session, seamlessly crossing pane boundaries without extra configuration.

2. **Non-Blocking Async CLI Helper for Zellij Actions:**
   - Replaced all 20+ synchronous `vim.fn.system("zellij action ...")` calls with a lightweight local Lua helper in [dot_config/nvim/lua/keybindings.lua](../dot_config/nvim/lua/keybindings.lua):
     ```lua
     local function zellij(...)
       vim.system({ 'zellij', 'action', ... })
     end
     ```
   - Calling `vim.system()` without `:wait()` executes the `zellij` CLI client asynchronously via libuv in the background, completely eliminating editor UI thread stutter when switching tabs (`<A-1..0>`, `<A-Left/Right>`), moving panes (`<A-S-h/j/k/l>`), swapping layouts (`<A-S-[/]>`), or toggling fullscreen (`<A-f>`).
   - Pane and tab spawning (`<A-s>` and `<A-n>`) now pass `--cwd` resolved dynamically via `vim.fn.getcwd()`, ensuring new Zellij tabs and vertical splits open in the active Neovim project root even after `:cd` or `:tcd`.
