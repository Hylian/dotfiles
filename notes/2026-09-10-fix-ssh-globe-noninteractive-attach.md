# Fix Dynamic SSH Globe Indicator for Non-Interactive & Unnamed Zellij Attaches

**Date:** 2026-09-10  
**Context:** Ensure the status bar globe emoji (`🌐`) updates reliably when starting a session locally and later attaching over SSH (including via `rw` or `ssh host 'zellij a -c persist ...'`).

## Root Cause Analysis

When starting a persistent session (`persist`) locally on `shined` and later attaching over SSH, the globe emoji failed to appear due to two independent gaps in how `_zellij_sync_client_env` and `host-status.sh` handled session descriptors:

1. **Non-Interactive Remote SSH Commands Bypassed `.zshrc`:**
   - Connecting via remote wrapper aliases (such as `rw -r desktop -i 'zellij a -c persist options --on-force-close detach'` or `ssh host -t 'zellij a -c persist ...'`) spawns a non-interactive Zsh command shell (`zsh -c '...'`).
   - Zsh only sources `~/.zshrc` for interactive shells; non-interactive command shells read `~/.zshenv` exclusively.
   - Because `_zellij_sync_client_env` and the `zellij()` wrapper function were only defined in [dot_zshrc.tmpl](../dot_zshrc.tmpl), `zsh -c` executed the `zellij` binary directly without running the client handshake, leaving `$XDG_RUNTIME_DIR/zellij-env/persist` and `/client` at `SSH=0`.

2. **Unnamed Attaches (`zellij a` / `zellij attach`) Left Per-Session Descriptors Stale:**
   - When attaching without an explicit session name argument (`zellij a`, `zellij attach -c`), or when `_zellij_sync_client_env` ran at `.zshrc` startup, `$session` resolved to `""`.
   - `_zellij_sync_client_env` wrote `SSH=1` only to `$env_dir/client`, leaving `$env_dir/persist` untouched at `SSH=0`.
   - Meanwhile, [dot_config/zellij/widgets/executable_host-status.sh.tmpl](../dot_config/zellij/widgets/executable_host-status.sh.tmpl) and `_zellij_sync_client_env_hook` checked `[ -f "$env_dir/$session" ]` first—seeing that `$env_dir/persist` existed, they read `SSH=0` from `$env_dir/persist` and ignored the newer `$env_dir/client`.
   - Additionally, `zellij pipe` outside a Zellij session without `--session <name>` failed to notify the active `persist` session.

## Solution

1. **Manage `~/.zshenv` via [dot_zshenv.tmpl](../dot_zshenv.tmpl):**
   - Defined `_zellij_sync_client_env` and the `zellij()` wrapper function in `~/.zshenv` so non-interactive `zsh -c 'zellij ...'` SSH attach commands execute the client handshake before attaching.
2. **Update All Active Session Descriptors & Pipe to Running Sessions ([dot_zshrc.tmpl](../dot_zshrc.tmpl), [dot_zshenv.tmpl](../dot_zshenv.tmpl)):**
   - `_zellij_sync_client_env` now writes the updated client descriptor to `$env_dir/client`, `$env_dir/$session`, and every existing regular session descriptor file in `$env_dir/*(N.)`.
   - When `$session` is omitted, `_zellij_sync_client_env` iterates through `$(command zellij list-sessions -s 2>/dev/null)` and pipes `zjstatus::rerun::command_host` to each running session.
3. **Prefer Newer Descriptor by Modification Time ([dot_config/zellij/widgets/executable_host-status.sh.tmpl](../dot_config/zellij/widgets/executable_host-status.sh.tmpl), [dot_zshrc.tmpl](../dot_zshrc.tmpl)):**
   - Updated both `host-status.sh` and `_zellij_sync_client_env_hook` to prefer `$env_dir/client` whenever its mtime (`-nt`) is newer than `$env_dir/$session`:
     ```sh
     if [ ! -f "$env_file" ] || { [ -f "$env_dir/client" ] && [ "$env_dir/client" -nt "$env_file" ]; }; then
     	env_file="$env_dir/client"
     fi
     ```

## Verification

- Verified `SSH_CONNECTION="10.0.0.1 1234 10.0.0.2 22" zsh -c '_zellij_sync_client_env a'` updates `$env_dir/persist` and `$env_dir/client` to `SSH=1`, causing `ZELLIJ_SESSION_NAME=persist host-status.sh` to output `shined.cam.corp.google.com 🌐`.
- Verified `SSH_CONNECTION="" WAYLAND_DISPLAY="wayland-1" zsh -c '_zellij_sync_client_env a'` reverts `$env_dir/persist` and `$env_dir/client` to `SSH=0`, causing `ZELLIJ_SESSION_NAME=persist host-status.sh` to output `shined.cam.corp.google.com`.
