# Reclaim `<Tab>` / `<C-i>` for Jumplist Forward Navigation ٩(◕‿◕｡)۶

*Date: 2026-09-01*

## Motivation & Context

In Neovim, `<C-o>` steps backward through the jumplist (`:jumps`) to previous cursor positions across definition jumps (`gd`, `gD`), searches, and file switches.
The complementary forward navigation command in standard Vim is `<C-i>` (or `<Tab>`). However, in terminal environments without Kitty keyboard protocol (e.g. inside Zellij where `support_kitty_keyboard_protocol false` is set for SSH repeat stability), `<C-i>` and `<Tab>` emit the identical ASCII byte `0x09` (`\t`).
Because `<Tab>` was previously mapped to `:ToggleDiag`, pressing `<C-i>` hijacked the forward jump and toggled diagnostic virtual text instead.

## Key Changes

1. **Unmap `<Tab>` in Neovim Keybindings ([dot_config/nvim/lua/keybindings.lua](../dot_config/nvim/lua/keybindings.lua)):**
   - Removed `map('n', '<TAB>', "<cmd>:ToggleDiag<CR>")`.
   - Restores native Vim behavior: `<C-i>` and `<Tab>` now step forward in `:jumps` as the natural counterpart to `<C-o>`.
   - The `:ToggleDiag` Ex command remains available via command line if needed.

2. **Living Ground Truth ([notes/SYSTEM.md](SYSTEM.md)):**
   - Documented `<C-o>` and `<C-i>` (and `<Tab>`) under Neovim keybindings.

## Verification

1. Verified `maparg('<Tab>', 'n')` and `maparg('<C-i>', 'n')` are both unmapped.
2. Verified jumplist jump sequence: jumped to line 5, stepped back with `<C-o>` (line 1), stepped forward with `<C-i>` (line 5), stepped back with `<C-o>` (line 1), and stepped forward with `<Tab>` (line 5).
3. `chezmoi diff` and `chezmoi apply` applied cleanly.
4. `nvim --headless` executed cleanly with exit code 0.
