# Preserve Signal and Discord Split Layout on Restart in AeroSpace

*Date: 2026-10-24*
*Host: `baumkuchen` (macOS Apple Silicon Client)*

## Context & Problem
On `baumkuchen`, workspace 3 hosts a horizontal split between Signal (left side, width 605) and Discord (right side, width 907). When Signal restarts (due to an app update, crash, or manual restart):
1. Signal's previous window closes, leaving Discord as the sole window on workspace 3. Discord automatically expands to fill the full container width.
2. Signal re-opens and triggers `[[on-window-detected]]`.
3. While Signal was closed, Discord occupied the entire container at full screen width (1500px).
4. When Signal re-opened, `move left` moved Signal to the left of Discord, but `resize width 605` only targeted Signal without contracting Discord from its full-width single-window state. Because Discord remained at 1500px, Signal was forced to render at its minimum width (or default launch width) on top of Discord, creating an unintended overlap.
## Solution & Implementation
1. **Enforce Directional Placement & Container Balancing in [dot_config/aerospace/aerospace.toml.tmpl](../dot_config/aerospace/aerospace.toml.tmpl):**
   - Added `'move left'` and `'balance-sizes --workspace 3'` to Signal's `on-window-detected` callback sequence:
     ```toml
     [[on-window-detected]]
         if.app-id = 'org.whispersystems.signal-desktop'
         run = ['move-node-to-workspace 3', 'move left', 'balance-sizes --workspace 3', 'resize width 605']
     ```
   - Added `'move right'` and `'balance-sizes --workspace 3'` to Discord's `on-window-detected` callback sequence:
     ```toml
     [[on-window-detected]]
         if.app-id = 'com.hnc.Discord'
         run = ['move-node-to-workspace 3', 'move right', 'balance-sizes --workspace 3', 'resize width 907']
     ```
   - Running `balance-sizes --workspace 3` before `resize width` resets the workspace container partitions, shrinking Discord from its full-screen 1500px footprint to a balanced 50/50 partition (~748px each). Then `resize width 605` adjusts Signal to 605px while Discord expands cleanly into the remaining 907px, preventing window overlap.
2. **Validation:**
   - Applied via `chezmoi apply --no-pager` and reloaded live via `aerospace reload-config`.
   - Verified callback command registration via `aerospace debug-windows`.
   - Simulated restart placement and confirmed window order and widths (Signal 605px on left, Discord 907px on right).
