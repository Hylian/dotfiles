# Dynamic Persistent Zellij Client Handshake & Clipboard Mode Switching ٩(◕‿◕｡)۶

*Date: 2026-08-05*

## Motivation

When starting a persistent Zellij session locally on a Linux workstation (`shined`), all child processes (Neovim, Zsh) inherit `WAYLAND_DISPLAY=wayland-1` and empty SSH environment variables.

When attaching to that persistent session later from a remote client (e.g. macOS laptop `baumkuchen` running Ghostty over SSH):
1. Existing child processes inside Zellij retained their initial local environment variables.
2. In Neovim and Zsh, pasting (`p`) attempted to query `wl-paste` against the local workstation Wayland socket. If the local desktop was idle, suspended, or locked, `wl-paste` returned stale workstation data or failed, ignoring new session yanks and cross-pane copies.
3. Conversely, if a session was started over SSH and attached locally later, open panes lacked `WAYLAND_DISPLAY` and failed to sync clipboard with local Linux GUI applications.

## Mechanism & Architecture

1. **Outer Shell Client Handshake ([dot_zshrc.tmpl](../dot_zshrc.tmpl)):**
   Whenever `zellij`, `zellij attach`, or auto-start runs in an outer shell, `_zellij_sync_client_env` publishes the attaching client's connection state into `$XDG_RUNTIME_DIR/zellij-env/$ZELLIJ_SESSION_NAME` (and `$XDG_RUNTIME_DIR/zellij-env/client`):
   - **Remote SSH Client:** Writes `SSH=1\nWAYLAND_DISPLAY=\nDISPLAY=\n`.
   - **Local Desktop Client:** Writes `SSH=0\nWAYLAND_DISPLAY=${WAYLAND_DISPLAY}\nDISPLAY=${DISPLAY}\n`.

2. **Dynamic Neovim Clipboard ([dot_config/nvim/init.lua.tmpl](../dot_config/nvim/init.lua.tmpl)):**
   - In `resolve_client_env()`, dynamically checks the session's client descriptor file on every copy and paste operation.
   - **Remote SSH Mode (`is_ssh == true`):**
     - `local_paste()` directly reads from `~/.cache/clipboard` (and unnamed register fallback), ensuring instant cross-pane pastes without touching stale local workstation Wayland sockets.
     - `local_copy()` updates `~/.cache/clipboard` and broadcasts ANSI OSC 52 sequences to `/dev/tty` for Ghostty macOS pasteboard synchronization.
   - **Local Mode (`is_ssh == false`):**
     - Resolves active `WAYLAND_DISPLAY` / `DISPLAY` sockets dynamically.
     - `local_copy()` executes `wl-copy` asynchronously via `vim.system`.
     - `local_paste()` queries `wl-paste --no-newline` to sync with local GUI applications.

3. **Dynamic Zsh Vi-Mode ([dot_zshrc.tmpl](../dot_zshrc.tmpl)):**
   - `_zsh_resolve_clipboard_env` dynamically checks the client descriptor.
   - `zsh_clipboard_copy()` and `zsh_clipboard_paste()` automatically switch between local display server sync and SSH `~/.cache/clipboard` + OSC 52 mode.

## Verification

1. `chezmoi diff` and `chezmoi apply` completed cleanly.
2. Verified Neovim mode switching:
   - Under `SSH=0` / local descriptor: `local_paste` queries `wl-paste`, `local_copy` updates Wayland + cache + OSC 52.
   - Under `SSH=1` / SSH descriptor: `local_paste` reads `~/.cache/clipboard` directly, `local_copy` updates cache + OSC 52 without touching Wayland.
3. Verified Zsh `zsh_clipboard_copy` and `zsh_clipboard_paste` mode switching under both local and SSH descriptors.
