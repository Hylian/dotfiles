# 2026-07-17: Enable OSC 52 System Clipboard Sync for Zsh Vi Mode ٩(◕‿◕｡)۶

## Problem
When yanking text in Zsh vi mode (`y`, `yy`, `yw`, visual mode `y`, `dd`, `d`, etc.) over an SSH session from a macOS client running Ghostty, the yanked text was not synchronized to the macOS system clipboard.

## Root Cause
`jeffreytse/zsh-vi-mode` had system clipboard integration disabled by default (`ZVM_SYSTEM_CLIPBOARD_ENABLED=false`). In addition, without a custom copy handler, standard Linux clipboard utilities (`wl-copy`/`xclip`) over SSH cannot reach the client pasteboard without ANSI OSC 52 escape sequences.

## Fix
1. **OSC 52 Remote Copy Handler (`zsh_clipboard_copy`):** Configured a custom copy command that reads the yanked buffer, encodes it to base64, and emits an ANSI OSC 52 escape sequence directly to `/dev/tty` (with tmux DCS pass-through when inside tmux). Ghostty intercepts this sequence over SSH and immediately updates the macOS system clipboard. It also updates local display clipboard tools (`wl-copy`, `xclip`, `pbcopy`) when available.
2. **Instant Local Paste Handler (`zsh_clipboard_paste`):** Defined a fast local paste command checking `wl-paste`, `xclip`, `xsel`, and `pbpaste` without blocking on terminal OSC 52 read queries.
3. **Zsh Vi Mode Configuration:** Enabled `ZVM_SYSTEM_CLIPBOARD_ENABLED=true` and wired `zsh_clipboard_copy` / `zsh_clipboard_paste` globally and via `zvm_config()`.
4. Rendered and applied changes cleanly via `chezmoi apply`.
