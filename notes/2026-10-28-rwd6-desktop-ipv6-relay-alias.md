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
2. **Ground Truth Tracking in [SYSTEM.md](SYSTEM.md):**
   - Updated the host-local alias overlay documentation in [SYSTEM.md](SYSTEM.md) to reference `rwd6` alongside `rwd`, `rwc`, and `rwc6`.

## Verification

- Verified syntax via `zsh -n ~/.config/zsh/galiases`.
- Verified alias expansion and resolution in an interactive login shell (`/bin/zsh -lic "which rwd6"`).
