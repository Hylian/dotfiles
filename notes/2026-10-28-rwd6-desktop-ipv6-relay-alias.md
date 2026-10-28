# Remote Workstation IPv6 Relay Alias (`rwd6`)

*Date: 2026-10-28*

## Context & Goal

We previously experimented with IPv6 relay routing for the cloudtop remote workstation workflow (`rwc` / `rwc6`) in `~/.config/zsh/galiases` to test whether the IPv6 relay route improved latency from macOS clients.

We wanted an analogous alias for the desktop remote workstation workflow (`rwd6`) that applies the same IPv6 relay routing configuration while attaching to (or creating) the remote `persist` Zellij session.

## Solution

1. **`rwd6` in `~/.config/zsh/galiases`:**
   - Defined `rwd6` matching `rwd` with the IPv6 relay environment overrides and auth control socket configuration:
     - Connects to desktop workstation.
     - Runs `zellij a -c persist options --on-force-close detach`.
     - Maintained in local untracked `~/.config/zsh/galiases` to adhere to zero-secrets and work-boundary separation policies.
2. **AeroSpace Default Launcher on `shined-mac` ([dot_config/aerospace/aerospace.toml.tmpl](../dot_config/aerospace/aerospace.toml.tmpl)):**
   - Switched `cmd-shift-enter` to launch Ghostty directly into `rwd6`:
     ```toml
     cmd-shift-enter = "exec-and-forget open -n /Applications/Ghostty.app --env ZELLIJ_NO_AUTOSTART=1 --args -e /bin/zsh -lic rwd6"
     ```
   - Applied via `chezmoi apply --no-pager` and reloaded live via `aerospace reload-config`.
3. **Ground Truth Tracking in [SYSTEM.md](SYSTEM.md):**
   - Updated the host-local alias overlay and AeroSpace launcher documentation in [SYSTEM.md](SYSTEM.md) to reference `rwd6`.

## Verification & Benchmarks

- Verified syntax via `zsh -n ~/.config/zsh/galiases`.
- Verified alias expansion and resolution in an interactive login shell (`/bin/zsh -lic "which rwd6"`).
- Verified live AeroSpace binding reload via `aerospace reload-config`.
- Conducted latency benchmark comparing `rwd` (default relay) and `rwd6` (`sup-ssh-relay` + IPv6 destination):
  - **Edge Ping to Relay:** `17.4ms` avg on `rwd6` vs `21.4ms` avg on `rwd` (-4.0ms / -18.7%).
  - **TCP Handshake:** `18.1ms` median on `rwd6` vs `23.8ms` median on `rwd` (-5.6ms / -23.7%, no tail latency spikes).
  - **Interactive Keystroke RTT:** `30.6ms` minimum floor on `rwd6` vs `33.8ms` on `rwd` (~35ms median on both).
