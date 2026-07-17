# 2026-07-17: Fix Neovim SSH Clipboard Sync to macOS via OSC 52 ٩(◕‿◕｡)۶

## Problem
1. When SSH'ing from a macOS client into the Linux machine, yanking text (`y`, `yy`, `d`, etc.) inside Neovim did not update the macOS system clipboard.
2. Conversely, pasting (`p`, `P`, `pp`) with bidirectional OSC 52 (`osc52.paste`) blocked and timed out waiting for the terminal's OSC 52 read response over the SSH link.

## Root Cause
1. In `init.lua.tmpl`, Neovim clipboard had `vim.opt.clipboard = 'unnamedplus'`, but the previous clipboard/OSC 52 configuration block was completely commented out.
2. Without a remote provider, Neovim on Linux auto-detected local system tools (`wl-copy`/`xclip`). Over an SSH connection, these tools either failed (no display) or only updated the local Linux desktop's Wayland/X11 clipboard instead of sending escape sequences back over the SSH TTY.
3. When `osc52.paste` was configured for pasting, Neovim sent an OSC 52 query (`\e]52;c;?\a`) and hung waiting for terminal response.

## Fix
1. **OSC 52 Yanks (Copy):** Configured `vim.g.clipboard.copy` and a `TextYankPost` autocommand to broadcast yanked text via `vim.ui.clipboard.osc52.copy('+')` directly to the client terminal (Ghostty). Ghostty intercepts the sequence and updates macOS system pasteboard.
2. **Instant Local Paste:** Decoupled paste from OSC 52 queries by defining a local paste handler for `vim.g.clipboard.paste`. It checks for available local system clipboard utilities (`wl-paste`, `pbpaste`, `xclip`, `xsel`) and falls back immediately to Neovim's unnamed register (`"`) if no display server is attached.
3. Rendered and applied changes cleanly via `chezmoi apply`.
