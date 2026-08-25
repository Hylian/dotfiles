# Sync Neovim Focus Configuration & Split Keybindings ٩(◕‿◕｡)۶

*Date: 2026-08-25*

## Summary

Synced local Neovim configuration changes from `~/.config/nvim/lua/config/focus.lua` and `~/.config/nvim/lua/keybindings.lua` into the chezmoi source tree:

1. **Focus Configuration ([dot_config/nvim/lua/config/focus.lua](../dot_config/nvim/lua/config/focus.lua)):**
   - Adjusted `autoresize.minwidth` from 40 to 10 columns for unfocused splits.
   - Configured `focusedwindow_minwidth = 84` and `focusedwindow_minheight = 0` to preserve comfortable reading width in the active pane.
   - Set `equalise_min_cols = 166` threshold for auto-equalizing split columns.
   - Set `ui.number = true` to display line numbers specifically in the focused window.

2. **Split & Maximize Keybindings ([dot_config/nvim/lua/keybindings.lua](../dot_config/nvim/lua/keybindings.lua)):**
   - `<A-S-s>`: `focus.split_command('l')` (split window to the right).
   - `<A-S-e>`: `focus.focus_equalise()` (equalize split window dimensions).
   - `<A-S-r>`: `focus.focus_autoresize()` (manually trigger focus auto-resize).
   - `<A-S-f>`: `maximize.toggle()` (toggle maximize current window).

## Verification

- `chezmoi diff` verified clean (source repo matches destination files).
- `nvim --headless "+qa"` executed cleanly without Lua syntax or startup errors.
