# 2026-07-17: Fix Neovim SSH Clipboard Sync to macOS via OSC 52 ٩(◕‿◕｡)۶

## Problem
When SSH'ing from a macOS client into the Linux machine, yanking text (`y`, `yy`, `d`, etc.) inside Neovim did not update the macOS system clipboard.

## Root Cause
1. In `init.lua.tmpl`, Neovim clipboard had `vim.opt.clipboard = 'unnamedplus'`, but the previous clipboard/OSC 52 configuration block was completely commented out.
2. Without a remote provider, Neovim on Linux auto-detected local system tools (`wl-copy`/`xclip`). Over an SSH connection, these tools either failed (no display) or only updated the local Linux desktop's Wayland/X11 clipboard instead of sending escape sequences back over the SSH TTY.

## Fix
1. Enabled built-in `vim.ui.clipboard.osc52` integration in `dot_config/nvim/init.lua.tmpl`.
2. Added SSH detection (`SSH_TTY`, `SSH_CONNECTION`, `SSH_CLIENT`, `NVIM_SSH_OVERRIDE`) to automatically set `vim.g.clipboard` to OSC 52 when working remotely.
3. Added a `TextYankPost` autocommand that broadcasts yanked text via OSC 52 to the connected terminal emulator (Ghostty) on every yank. Ghostty intercepts the OSC 52 sequence and sets the macOS pasteboard.
4. Rendered and applied changes cleanly via `chezmoi apply`.
