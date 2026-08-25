# Bind Leader Notification Shortcuts in Neovim ٩(◕‿◕｡)۶

*Date: 2026-08-25*

## Summary

Added leader keybindings in [dot_config/nvim/lua/keybindings.lua](../dot_config/nvim/lua/keybindings.lua) to quickly view message history, recall the last notification, view errors, and dismiss popups via `<leader>n*` (where `<leader>` is `;`).

## Key Changes

1. **Keybindings ([dot_config/nvim/lua/keybindings.lua](../dot_config/nvim/lua/keybindings.lua)):**
   - `;nh` (`<leader>nh`): `<cmd>Noice history<CR>` — opens a scrollable split of message/notification history.
   - `;nl` (`<leader>nl`): `<cmd>Noice last<CR>` — re-displays the most recent notification popup.
   - `;ne` (`<leader>ne`): `<cmd>Noice errors<CR>` — filters and displays recent error messages.
   - `;nd` (`<leader>nd`): `<cmd>Noice dismiss<CR>` — dismisses all currently active notification popups.

2. **Lazy Loading Spec ([dot_config/nvim/lua/plugins/init.lua](../dot_config/nvim/lua/plugins/init.lua)):**
   - Added `cmd = { "Noice" }` trigger to ensure `folke/noice.nvim` loads immediately if any `Noice` command is dispatched.

3. **Ground Truth Update ([notes/SYSTEM.md](SYSTEM.md)):**
   - Added leader mappings to the standard Neovim keybindings reference.

## Verification

1. `chezmoi diff` verified template and lua modifications.
2. `chezmoi apply` deployed changes to `~/.config/nvim/`.
3. `nvim --headless "+qa"` executed cleanly without errors.
