# Remove Obsolete `yadm` Field from Gitsigns Configuration ٩(◕‿◕｡)۶

*Date: 2026-08-25*

## Summary

Removed the obsolete `yadm` configuration block from [dot_config/nvim/lua/config/gitsigns.lua](../dot_config/nvim/lua/config/gitsigns.lua) to eliminate the startup warning `gitsigns: Ignoring invalid configuration field 'yadm'`.

## Key Changes

1. **Gitsigns Setup ([dot_config/nvim/lua/config/gitsigns.lua](../dot_config/nvim/lua/config/gitsigns.lua)):**
   - Removed `yadm = { enable = false }` which was deprecated and removed from upstream `gitsigns.nvim`.

## Verification

1. `chezmoi diff` verified configuration diff.
2. `chezmoi apply` deployed changes to `~/.config/nvim/lua/config/gitsigns.lua`.
3. Validated clean plugin load via `nvim --headless -c "lua require('lazy').load({ plugins = { 'gitsigns.nvim' } })" -c "qa"` with zero warnings or errors.
