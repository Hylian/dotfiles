# Universal Clipboard & Shared Cache Sync (Headless SSH + Display) ٩(◕‿◕｡)۶

*Date: 2026-07-21*

## Issue
When yanking a line in Neovim (`yy`) on a headless Linux workstation (`shined`), returning to the shell prompt and pressing `Esc` followed by `p` in `zsh-vi-mode` (`zvm`) normal mode did not paste what was yanked, even when `~/.cache/clipboard` was updated.

## Root Cause
1. **zvm Default `p` Keybinding:** In `zsh-vi-mode`, standard `p` and `P` in `vicmd` normal mode are bound by default to `zvm_vi_put_after` and `zvm_vi_put_before`. These widgets exclusively paste from Zsh's internal in-memory `CUTBUFFER` (which is only updated by yanks performed directly inside Zsh). Only `gp` was bound to `zvm_paste_clipboard_after`.
2. **Absence of Working Display Server:** On headless SSH sessions, GUI clipboard tools (`wl-copy`/`wl-paste`, `xclip`) fail or are unavailable.

## Fix
1. **Rebind zvm `p` and `P` in Normal & Visual Modes:**
   Added bindings in `zvm_after_init_commands` in `dot_zshrc.tmpl`:
   - `vicmd 'p'` -> `zvm_paste_clipboard_after`
   - `vicmd 'P'` -> `zvm_paste_clipboard_before`
   - `visual 'p'` / `'P'` -> `zvm_visual_paste_clipboard`
   This ensures standard `p` in normal mode always invokes the system/shared clipboard paste pipeline (`zsh_clipboard_paste`).
2. **Shared Workstation Cache + OSC 52 + GUI Display Sync:**
   - **Neovim ([dot_config/nvim/init.lua.tmpl](../dot_config/nvim/init.lua.tmpl)):** `local_copy` and `TextYankPost` pipe yanked lines to local display utilities (`wl-copy`, `pbcopy`, `xclip`, `xsel`) if available, write to the workstation cache `~/.cache/clipboard`, and broadcast ANSI OSC 52 sequences to `/dev/tty`. `local_paste()` queries display utilities, falls back to `~/.cache/clipboard`, and then to unnamed register (`"`).
   - **Zsh Vi Mode ([dot_zshrc.tmpl](../dot_zshrc.tmpl)):** `zsh_clipboard_copy()` and `zsh_clipboard_paste()` write to and read from `~/.cache/clipboard` with direct fallbacks for display tools and OSC 52 broadcasting.
3. **Verified:** Validated end-to-end with Neovim headless yanks and Zsh paste commands. Yanking in Neovim is immediately pasteable in Zsh with standard `p` in `vicmd` mode.
