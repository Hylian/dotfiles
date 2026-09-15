# Configure Diffview & Add Git Conflict Resolution

**Date:** 2026-09-15  
**Context:** Replace shell git delta / manual conflict resolution with an integrated Neovim workflow using `diffview.nvim` and `git-conflict.nvim`, binding `Shift+\` (`|`) to open/toggle the files panel sidebar.

## Implementation

1. **Diffview Configuration ([dot_config/nvim/lua/config/diffview.lua](../dot_config/nvim/lua/config/diffview.lua)):**
   - Configured `enhanced_diff_hl = true` for Treesitter-enhanced character-level diff highlighting.
   - Set default 2-way horizontal diff layout and 3-way mixed merge tool layout (`diff3_mixed`: Ours and Theirs on top, Result on bottom).
   - Configured left file panel (width 35, tree listing style).
   - In-view keymaps: `[c` / `]c` jump hunks, `q` / `<leader>q` close, `[x` / `]x` jump conflicts, `<leader>co` (ours), `<leader>ct` (theirs), `<leader>cb` (base), `<leader>ca` (all), `<leader>c0` (none).
   - File panel keymaps: `<CR>` open file, `-` or `s` toggle staging, `S` stage all, `U` unstage all, `X` restore working tree copy, `R` refresh.

2. **Global Sidebar Toggle ([dot_config/nvim/lua/keybindings.lua](../dot_config/nvim/lua/keybindings.lua)):**
   - Bound `<Bar>` (`Shift+\`):
     - When Diffview is closed: launches `:DiffviewOpen` with the left file panel.
     - When Diffview is open: toggles the file panel sidebar (`:DiffviewToggleFiles`).

3. **In-Buffer Inline Conflict Resolver ([dot_config/nvim/lua/config/git-conflict.lua](../dot_config/nvim/lua/config/git-conflict.lua)):**
   - Installed `akinsho/git-conflict.nvim` for quick inline conflict markers in normal file buffers:
     - `co`: Choose Ours
     - `ct`: Choose Theirs
     - `cb`: Choose Both
     - `c0`: Choose None
     - `]x` / `[x`: Jump to next / previous conflict

4. **Plugin Spec ([dot_config/nvim/lua/plugins/init.lua](../dot_config/nvim/lua/plugins/init.lua)):**
   - Wired `diffview.nvim` to `config.diffview`.
   - Added `akinsho/git-conflict.nvim` on `BufReadPre` / `BufNewFile`.

## Verification

- Verified `nmap <Bar>` resolves to `<Lua ...: keybindings.lua:698>`.
- Verified pressing `|` opens Diffview and toggles the file panel sidebar.
- Verified `:DiffviewClose` cleanly shuts down Diffview splits.
- Verified `git-conflict.nvim` loads cleanly without errors.
- Applied changes via `chezmoi apply`.
