# 2026-07-17: Add Alt+q (:q) and Alt+Shift+q (:q!) in Neovim ٩(◕‿◕｡)۶

## Changes
- In `dot_config/nvim/lua/keybindings.lua`, added normal mode mappings:
  - `Alt + q` (`<A-q>`): `:q<CR>` (close current window/buffer)
  - `Alt + Shift + q` (`<A-S-q>` / `<A-Q>`): `:q!<CR>` (force quit current window/buffer)
- Applied via `chezmoi apply`.
