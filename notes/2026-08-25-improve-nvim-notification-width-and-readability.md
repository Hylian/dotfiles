# Improve Neovim Notification Popup Width & Readability ٩(◕‿◕｡)۶

*Date: 2026-08-25*

## Summary

Updated `nvim-notify` and `noice.nvim` configurations to eliminate overly narrow, clamped popup notification windows and ensure notification messages are easily readable across varied terminal widths.

## Key Changes

1. **Lazy Loading & Config Centralization ([dot_config/nvim/lua/plugins/init.lua](../dot_config/nvim/lua/plugins/init.lua)):**
   - Refactored `rcarriga/nvim-notify` and `folke/noice.nvim` specs to delegate to `config = function() require('config.notify') end` and `config = function() require('config.noice') end`.
   - Removed legacy inline `opts` table from `plugins/init.lua` that was clamping `max_width = 20`.

2. **Responsive Notification Dimensions ([dot_config/nvim/lua/config/notify.lua](../dot_config/nvim/lua/config/notify.lua)):**
   - Configured dynamic `max_width`:
     ```lua
     max_width = function()
       return math.max(60, math.floor(vim.o.columns * 0.75))
     end
     ```
     This scales with window dimensions (at least 60 columns or 75% of terminal width) so paths, diagnostics, and status messages don't awkwardly wrap.
   - Set `minimum_width = 15` for compact single-word messages without forced artificial padding.
   - Set `timeout = 3000` (3 seconds) to allow comfortable reading before auto-fade.

3. **Ground Truth Update ([notes/SYSTEM.md](SYSTEM.md)):**
   - Documented `nvim-notify` / `noice.nvim` configuration in Neovim stack documentation.

## Verification

1. `chezmoi diff` verified template rendering and lua changes.
2. `chezmoi apply` deployed configurations to `~/.config/nvim/`.
3. Headless verification confirmed evaluated `max_width: 60` (in 80-col headless) and `min_width: 15`.
4. `nvim --headless` executed `vim.notify` without warnings or errors.
