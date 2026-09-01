# Robust `Alt-Shift-number` Neovim Tab Switching ٩(◕‿◕｡)۶

*Date: 2026-09-01*

## Motivation & Problem

While `<A-1>` through `<A-0>` seamlessly switch Zellij tabs, switching Neovim tabs with `Alt-Shift-number` (`1gt` .. `9gt`) was previously bound only via `<A-S-1>` through `<A-S-9>`:
1. **Terminal Byte Representation:** In terminals where Kitty keyboard protocol negotiation is disabled (such as Zellij where `support_kitty_keyboard_protocol false` is enforced for SSH repeat stability) or in classic xterm/Ghostty mode, pressing `Alt + Shift + number` emits raw ASCII escape sequences: `\x1b!` (`Alt-!`), `\x1b@` (`Alt-@`), `\x1b#` (`Alt-#`), etc., instead of CSI modifier packets (`<A-S-1>`).
2. **Missing Mappings:** In Neovim, `<A-S-1>` maps to internal termcode `<M-S-1>`, which does not match `<M-!>`. Consequently, pressing `Alt + Shift + 1` in standard terminals arrived as `<M-!>` and failed to trigger `1gt`.
3. **Missing 10th Tab & Toggle:** `<A-S-0>` (for tab 10) was missing, and `<A-S-`>` (`g<Tab>`) similarly lacked its ASCII `<A-~>` counterpart.

## Key Changes

1. **Keybindings ([dot_config/nvim/lua/keybindings.lua](../dot_config/nvim/lua/keybindings.lua)):**
   - Added `<A-S-0>` -> `"10gt"` to complete tabs 1 through 10.
   - Bound ASCII escape sequence equivalents for all numbers:
     - `<A-!>` -> `"1gt"`
     - `<A-@>` -> `"2gt"`
     - `<A-#>` -> `"3gt"`
     - `<A-$>` -> `"4gt"`
     - `<A-%>` -> `"5gt"`
     - `<A-^>` -> `"6gt"`
     - `<A-&>` -> `"7gt"`
     - `<A-*>` -> `"8gt"`
     - `<A-(>` -> `"9gt"`
     - `<A-)>` -> `"10gt"`
   - Added `<A-~>` -> `"g<Tab>"` alongside `<A-S-`>` for tab toggling.
   - Preserves compatibility across both Kitty protocol clients and legacy/escaped TTY clients.

2. **Living Ground Truth ([notes/SYSTEM.md](SYSTEM.md)):**
   - Documented `Alt-Shift-number` and `Alt-Shift-` ` tab navigation in the system profile.

## Verification

1. Headless Neovim test confirmed both `<A-S-N>` and `<A-symbol>` mappings resolve to `Ngt`.
2. Verified functional multi-tab switching with synthetic key events (`<A-!>` -> tab 1, `<A-@>` -> tab 2, `<A-S-3>` -> tab 3, `<A-~>` -> tab toggle).
3. `chezmoi diff` and `chezmoi apply` applied cleanly.
4. `nvim --headless` executed cleanly with exit code 0.
