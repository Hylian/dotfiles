# Dynamic `SSH_AUTH_SOCK` & Environment Synchronization for Persistent Zellij Sessions ٩(◕‿◕｡)۶

*Date: 2026-08-25*

## Motivation & Problem

When persisting Zellij sessions across local workstation sessions and remote SSH connections (e.g. connecting from macOS laptops `baumkuchen` / `midnight-future` into `shined`):
1. **Stale `SSH_AUTH_SOCK`:** SSH agent forwarding creates an ephemeral UNIX domain socket per SSH login (e.g. `/tmp/ssh-XXXXXX/agent.PID`). When attaching to an existing persistent Zellij session, pre-existing shell panes retain their initial environment (either pointing to a local desktop agent or an expired SSH socket from a prior connection).
2. **`gcert` and SSH Failures:** Running `gcert` or git/SSH operations in open panes failed because the processes attempted to communicate with a dead or unreachable SSH agent socket.
3. **Display Server Leaks:** When switching back to local desk mode from SSH, open panes lacked active `WAYLAND_DISPLAY` / `DISPLAY` variables; when switching from local desk to SSH, stale display variables caused GUI tools to attempt connecting to local hardware sockets.

## Mechanism & Architecture

### 1. Attaching Client Handshake ([dot_zshrc.tmpl](../dot_zshrc.tmpl))
Whenever `zellij` or `zellij attach` runs in an outer shell:
- `_zellij_sync_client_env` inspects the command line arguments to resolve the targeted session name (falling back to `${ZELLIJ_SESSION_NAME}` and the universal `client` descriptor).
- It writes the client's current connection state into `$XDG_RUNTIME_DIR/zellij-env/$SESSION` and `$XDG_RUNTIME_DIR/zellij-env/client`:
  - `SSH=1` vs `SSH=0`
  - `SSH_AUTH_SOCK`
  - `SSH_CLIENT`, `SSH_CONNECTION`, `SSH_TTY`
  - `WAYLAND_DISPLAY`, `DISPLAY`
- If `SSH_AUTH_SOCK` is non-empty, it maintains a stable symlink `$XDG_RUNTIME_DIR/zellij-env/ssh-auth-sock -> $SSH_AUTH_SOCK`.

### 2. Zero-Fork Zsh Prompt Hook ([dot_zshrc.tmpl](../dot_zshrc.tmpl))
Inside Zellij panes (`[[ -n "$ZELLIJ" ]]`):
- `_zellij_sync_client_env_hook` is registered in `precmd_functions` and run on `.zshrc` initialization.
- It queries the descriptor file's mtime using the builtin `zstat` (< 2µs, 0 forks).
- When the mtime changes (upon client attach or host transition):
  - Dynamically updates `export SSH_AUTH_SOCK` (or unsets it if empty).
  - Updates or unsets `SSH_CLIENT`, `SSH_CONNECTION`, and `SSH_TTY`.
  - Updates `WAYLAND_DISPLAY` and `DISPLAY` for local desktop access.
- `_zsh_resolve_clipboard_env` unifies with this hook to keep copy/paste mode switching seamless.

### 3. Neovim Dynamic Environment Resolution ([dot_config/nvim/init.lua.tmpl](../dot_config/nvim/init.lua.tmpl))
- Neovim's `resolve_client_env()` parses `SSH_AUTH_SOCK`, `SSH_CLIENT`, `SSH_CONNECTION`, and `SSH_TTY` from the session descriptor file and sets `vim.env.SSH_AUTH_SOCK` dynamically, ensuring embedded terminal buffers and editor git commands have valid agent access.

## Verification

1. Validated outer SSH attachment recording descriptor files and `ssh-auth-sock` symlink.
2. Verified inner Zsh prompt hook dynamically refreshing `SSH_AUTH_SOCK`, `SSH_CLIENT`, `SSH_CONNECTION`, and `SSH_TTY` when switching from local to SSH and back.
3. Verified Neovim `resolve_client_env()` updating `vim.env.SSH_AUTH_SOCK` under headless test harnesses.
4. Clean `chezmoi diff` and `chezmoi apply`.
