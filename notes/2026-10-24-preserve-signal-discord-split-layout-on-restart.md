# Preserve Signal and Discord Split Layout on Restart in AeroSpace

*Date: 2026-10-24*
*Host: `baumkuchen` (macOS Apple Silicon Client)*

## Context & Problem
On `baumkuchen`, workspace 3 hosts a horizontal split between Signal (left side, width 605) and Discord (right side, width 907). When Signal restarts (due to an app update, crash, or manual restart):
1. Signal's previous window closes, leaving Discord as the sole window on workspace 3. Discord automatically expands to fill the full container width.
2. Signal re-opens and triggers `[[on-window-detected]]`.
3. Previously, Signal's callback executed `run = ['move-node-to-workspace 3', 'resize width 605']`. Because AeroSpace appends new windows to the end of the container by default, Signal was inserted to the *right* of Discord rather than the left.
4. Signal was resized to 605px on the far right while Discord occupied the left side, inverting the layout and leaving Signal squished against the right edge of the display.

## Solution & Implementation
1. **Enforce Directional Placement in [dot_config/aerospace/aerospace.toml.tmpl](../dot_config/aerospace/aerospace.toml.tmpl):**
   - Added `'move left'` to Signal's `on-window-detected` callback sequence:
     ```toml
     [[on-window-detected]]
         if.app-id = 'org.whispersystems.signal-desktop'
         run = ['move-node-to-workspace 3', 'move left', 'resize width 605']
     ```
   - Added `'move right'` to Discord's `on-window-detected` callback sequence:
     ```toml
     [[on-window-detected]]
         if.app-id = 'com.hnc.Discord'
         run = ['move-node-to-workspace 3', 'move right', 'resize width 907']
     ```
   - When Signal restarts while Discord is active, Signal is moved to workspace 3, immediately shifted to the left of Discord via `move left`, and resized to width 605, restoring the intended split. If either app launches first in an empty workspace, the directional move stops gracefully at the container boundary.

2. **Validation:**
   - Applied via `chezmoi apply --no-pager` and reloaded live via `aerospace reload-config`.
   - Verified callback command registration via `aerospace debug-windows`.
   - Simulated restart placement and confirmed window order and widths (Signal 605px on left, Discord 907px on right).
