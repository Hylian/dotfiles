# Dynamic SSH Globe Indicator in zjstatus Hostname Widget

**Date:** 2026-09-08  
**Context:** Dynamic status bar indication of client connection type (local desk vs remote SSH) on persistent Zellij sessions.

## Motivation & Behavior

Persistent Zellij multiplexer sessions are accessed both locally at the desk (under Wayland/X11 compositors) and remotely via SSH from laptop clients. Previously, the hostname segment at the right end of the status bar was statically rendered with `{{ .chezmoi.fqdnHostname }}`.

To provide clear, ambient awareness of whether the active session is currently attached via SSH or locally, the hostname widget now dynamically updates:
- **Local desktop:** displays the machine hostname (`shined.cam.corp.google.com`).
- **Remote SSH:** displays a globe emoji following the hostname (`shined.cam.corp.google.com 🌐`).

## Implementation Details

1. **Host Status Widget ([dot_config/zellij/widgets/executable_host-status.sh.tmpl](../dot_config/zellij/widgets/executable_host-status.sh.tmpl)):**
   - Created a zero-fork POSIX `/bin/sh` widget script.
   - Bakes `{{ .chezmoi.fqdnHostname }}` directly into the script at chezmoi template render time (avoiding `hostname` subprocesses).
   - Reads the client descriptor written by `_zellij_sync_client_env` in `${XDG_RUNTIME_DIR:-/tmp}/zellij-env/$ZELLIJ_SESSION_NAME` (falling back to `/client`).
   - Parses `SSH=1` vs `SSH=0` via shell builtins (`read -r k v`).
   - If `SSH=1`, emits `$hostname 🌐`; otherwise emits `$hostname`.
   - Execution time: ~1ms with zero subprocess forks.

2. **Layout Integration ([dot_config/zellij/layouts/default.kdl.tmpl](../dot_config/zellij/layouts/default.kdl.tmpl)):**
   - Replaced static hostname text with `{command_host}` in `format_right` for both light and dark theme configurations.
   - Defined `command_host`:
     ```kdl
     command_host_command    "{{ .chezmoi.homeDir }}/.config/zellij/widgets/host-status.sh"
     command_host_format     "{stdout}"
     command_host_rendermode "static"
     command_host_interval   "2"
     ```
   - In `Hylian/zjstatus`, command results only trigger a repaint if `stdout`, `stderr`, or `exit_code` actually changed (`should_render = false` on steady state), so polling at 2s interval costs zero unnecessary renders or CPU load.

3. **Event-Driven Invalidation ([dot_zshrc.tmpl](../dot_zshrc.tmpl)):**
   - **Outer Attach (`_zellij_sync_client_env`):** When attaching to an existing session from outside Zellij, immediately pipes `zjstatus::rerun::command_host` to the session.
   - **Prompt Hook (`_zellij_sync_client_env_hook`):** When the descriptor's mtime changes (detected via fork-free `zstat`), the inner shell also pipes `zjstatus::rerun::command_host` to ensure instantaneous status bar refresh.

4. **Cleanup:**
   - Removed obsolete, unused `dot_config/zellij/widgets/executable_ssh-status.sh`.

## Verification

1. **Local Mode:** Verified `~/.config/zellij/widgets/host-status.sh` outputs `shined.cam.corp.google.com`.
2. **SSH Mode:** Verified with `SSH=1` descriptor outputs `shined.cam.corp.google.com 🌐`.
3. **Chezmoi Diff & Apply:** Verified `chezmoi diff` and applied cleanly with `chezmoi apply`.
