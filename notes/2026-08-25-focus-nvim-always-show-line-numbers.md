# Always Show Line Numbers in Every Split with focus.nvim ٩(◕‿◕｡)۶

*Date: 2026-08-25*

## Summary

Updated `focus.nvim` configuration ([dot_config/nvim/lua/config/focus.lua](../dot_config/nvim/lua/config/focus.lua)) to ensure line numbers remain visible across all window splits at all times.

## Key Changes

1. **Focus UI Configuration:**
   - Changed `ui.number` from `true` to `false` in `focus.setup()`.
   - When `ui.number = true`, `focus.nvim` registers `BufLeave`/`WinLeave` autocmds that explicitly set `vim.wo.number = false` for unfocused splits.
   - Disabling `ui.number` removes this autocmd behavior, allowing Neovim's baseline `vim.opt.number = true` (from `init.lua.tmpl`) to persist across all splits.

## Verification

1. `chezmoi diff` verified clean configuration diff.
2. `chezmoi apply` deployed changes to `~/.config/nvim/lua/config/focus.lua`.
3. `nvim --headless "+qa"` executed cleanly without errors.
