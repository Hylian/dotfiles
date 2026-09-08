# Bind Alt+~ to Zellij Tab Toggle in Zellij and Neovim

**Date:** 2026-09-08  
**Context:** Multiplexer and editor tab switching harmonization across keyboard physical chords.

## Problem & Motivation

On standard keyboards, the backtick (`` ` ``) and tilde (`~`) share the same physical key (with `~` requiring Shift). When navigating Zellij tabs via `Alt + ``, pressing `Alt + ~` (or Shift-modified `Alt + Shift + ``) failed to toggle tabs in Zellij because Zellij only had `"Alt `"` bound.

Furthermore, inside Neovim (where `zellij-autolock` locks Zellij and passes Alt keys through), `<A-~>` and `<A-S-`>` were mapped to `<cmd>tabnext #<CR>` (toggling Neovim tabs rather than Zellij tabs). This caused unexpected tab behavior when muscle memory triggered `Alt + ~` while focused on an editor buffer.

## Solution

1. **Zellij Configuration ([dot_config/zellij/config.kdl.tmpl](../dot_config/zellij/config.kdl.tmpl)):**
   - Added `bind "Alt ~"` and `bind "Alt Shift `"` to `shared_except "locked"` to invoke `ToggleTab`.
   - Added `bind "~"` alongside `bind "`"` in `tab` mode to invoke `ToggleTab`.
2. **Neovim Zellij Integration ([dot_config/nvim/lua/keybindings.lua](../dot_config/nvim/lua/keybindings.lua)):**
   - Mapped `<A-~>` and `<A-S-`>` to `zellij_toggle_tab` across all modes (`{'n', 'i', 'v', 't'}`).
   - Removed superseded `<cmd>tabnext #<CR>` bindings from `<A-~>` and `<A-S-`>` so they do not shadow Zellij tab toggling.

## Verification

1. **Zellij Config Validation:** Verified with `zellij setup --check` returning `Well defined.`.
2. **Neovim Validation:** Verified with `nvim --headless +qa` exiting 0 without warnings or errors.
3. **Chezmoi Apply:** Applied cleanly to `~/.config/zellij/config.kdl` and `~/.config/nvim/lua/keybindings.lua` with zero drift.
