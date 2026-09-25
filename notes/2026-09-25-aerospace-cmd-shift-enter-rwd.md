# AeroSpace `cmd-shift-enter` Remote Workstation Launcher (`rwd`) without Local Zellij Autostart

*Date: 2026-09-25*

## Context & Goal

On `shined-mac`, `cmd-enter` in AeroSpace launches a fresh Ghostty window (`open -n /Applications/Ghostty.app`), which starts an interactive login shell and automatically attaches/spawns a local Zellij session via `$ZSH_CACHE_DIR/zellij.zsh` in [dot_zshrc.tmpl](../dot_zshrc.tmpl).

We wanted `cmd-shift-enter` on `shined-mac` to launch Ghostty directly into the `rwd` workflow (connecting to the remote workstation and attaching to the remote `persist` Zellij session) without autolaunching a local Zellij instance on `shined-mac`.

## Solution

1. **`ZELLIJ_NO_AUTOSTART` Guard in [dot_zshrc.tmpl](../dot_zshrc.tmpl):**
   - Guarded `source "$ZSH_CACHE_DIR/zellij.zsh"` behind `if [[ -z "$ZELLIJ_NO_AUTOSTART" ]]; then`.
   - When `ZELLIJ_NO_AUTOSTART=1` is set in the environment, interactive Zsh shells load the full user environment and alias definitions (including `~/.config/zsh/galiases` where `rwd` is defined) without autolaunching a local Zellij session before `-c <cmd>` executes—and without autolaunching local Zellij if additional tabs/surfaces are opened inside that Ghostty instance.
2. **Login Shell (`-lic`) & `launchd` `PATH` Initialization ([dot_config/aerospace/aerospace.toml.tmpl](../dot_config/aerospace/aerospace.toml.tmpl) & [dot_zshenv.tmpl](../dot_zshenv.tmpl)):**
   - GUI apps spawned by macOS `launchd` (like AeroSpace -> `open -n /Applications/Ghostty.app`) inherit a minimal `PATH` (`/usr/bin:/bin:/usr/sbin:/sbin`) that omits `/usr/local/bin` (where `rw` lives) and `/opt/homebrew/bin` unless `/etc/zprofile` (`path_helper`) runs in a login shell (`-l`).
   - Prepended `/usr/local/bin`, `/opt/homebrew/bin`, and `$HOME/.local/bin` in [dot_zshenv.tmpl](../dot_zshenv.tmpl) *after* sourcing `$HOME/.cargo/env` so `$HOME/.local/bin` (where `zellij 0.45.1` lives) is guaranteed to sit at the very front of `PATH` ahead of `$HOME/.cargo/bin` in non-interactive `ssh host 'zellij ...'` (`rwd`) connections, and pruned stale `~/.cargo/bin/zellij` (`0.44.3`) via `manage-forks.sh`.
   - Configured `cmd-shift-enter` under `{{ if eq .chezmoi.hostname "shined-mac" -}}` with `-lic` (login + interactive + command):
     ```toml
     cmd-shift-enter = "exec-and-forget open -n /Applications/Ghostty.app --env ZELLIJ_NO_AUTOSTART=1 --args -e /bin/zsh -lic rwd"
     ```
   - Applied via `chezmoi apply` and reloaded live via `aerospace reload-config`.
