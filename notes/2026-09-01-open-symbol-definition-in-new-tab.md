# Open Symbol Definition in New Neovim Tab with `gD` ٩(◕‿◕｡)۶

*Date: 2026-09-01*

## Summary

Bound `gD` in [dot_config/nvim/lua/keybindings.lua](../dot_config/nvim/lua/keybindings.lua) to open the symbol's LSP definition directly in a new Neovim tab instead of the current buffer.

## Key Changes

1. **Keybindings ([dot_config/nvim/lua/keybindings.lua](../dot_config/nvim/lua/keybindings.lua)):**
   - Added normal mode mapping:
     ```lua
     map('n', 'gD', "<cmd>lua require('fzf-lua').lsp_definitions({ jump1_action = require('fzf-lua.actions').file_tabedit, actions = { enter = require('fzf-lua.actions').file_tabedit } })<CR>")
     ```
   - When a single definition exists, `jump1_action = actions.file_tabedit` executes immediately to open the target file and line in a new tab (`:$tabedit`).
   - If multiple definitions exist, `actions.enter = actions.file_tabedit` ensures pressing `<CR>` in the picker opens the selected match in a new tab.
   - Pairs alongside `gd` (which opens definitions in the current buffer).

2. **Living Ground Truth ([notes/SYSTEM.md](SYSTEM.md)):**
   - Documented `gd` and `gD` under Neovim keybindings in the system profile.

## Verification

1. Headless Neovim test confirmed `actions.file_tabedit` successfully opens a new tab and navigates to the target file/line.
2. Verified `fzf-lua` action normalization preserves standard secondary actions (`ctrl-t`, `ctrl-v`, `ctrl-s`, etc.).
3. `chezmoi diff` and `chezmoi apply` applied cleanly to `~/.config/nvim/lua/keybindings.lua`.
4. `nvim --headless` executed cleanly with exit code 0 and confirmed active keybinding metadata for `gD`.
