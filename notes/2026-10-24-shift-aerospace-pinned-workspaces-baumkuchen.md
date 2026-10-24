# Shift AeroSpace Pinned Workspaces on baumkuchen

*Date: 2026-10-24*
*Host: `baumkuchen` (macOS Apple Silicon Client)*

## Context & Goal
On `baumkuchen`, applications were previously configured via AeroSpace window detection rules to automatically pin starting from workspace 2:
- Signal (`org.whispersystems.signal-desktop`) -> workspace 2
- Discord (`com.hnc.Discord`) -> workspace 2
- Bluesky (`jcsalterego.Sky`) -> workspace 3
- Fastmail (`com.fastmail.mac.Fastmail`) -> workspace 4

To free up workspace 2 for general/ad-hoc uses, Rachel requested shifting all pinned application targets up by one workspace.

## Changes & Verification
1. **Updated AeroSpace Rules ([dot_config/aerospace/aerospace.toml.tmpl](../dot_config/aerospace/aerospace.toml.tmpl)):**
   - Shifted Signal from workspace 2 to workspace 3 (`move-node-to-workspace 3`, `resize width 605`).
   - Shifted Discord from workspace 2 to workspace 3 (`move-node-to-workspace 3`, `resize width 907`).
   - Shifted Bluesky from workspace 3 to workspace 4 (`move-node-to-workspace 4`).
   - Shifted Fastmail from workspace 4 to workspace 5 (`move-node-to-workspace 5`).
2. **Applied & Reloaded:**
   - Applied cleanly via `chezmoi apply --no-pager`.
   - Reloaded active AeroSpace configuration via `aerospace reload-config`.
   - Relocated currently running windows to their new target workspaces, confirming workspace 2 is completely unpinned and clear.
