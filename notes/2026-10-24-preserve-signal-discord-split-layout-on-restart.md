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
         run = ['move-node-to-workspace 3', 'move left', 'balance-sizes --workspace 3', 'resize smart -143']
     ```
   - Added `'move right'` and `'balance-sizes --workspace 3'` to Discord's `on-window-detected` callback sequence:
     ```toml
     [[on-window-detected]]
         if.app-id = 'com.hnc.Discord'
         run = ['move-node-to-workspace 3', 'move right', 'balance-sizes --workspace 3', 'resize smart +143']
     ```
   - In AeroSpace, `resize` arguments are parsed as signed relative adjustments (`[+|-]<number>`). Passing unsigned `605` was treated as `+605`, which added 605px onto the balanced 748px partition (yielding 1353px) and pushed Discord off-screen.
   - To achieve a target width of ~605px for Signal from a balanced 748px split (on a 1512px display with 16px gaps, usable width 1496px), Signal needs a relative decrease of 143px: `resize smart -143` (748 - 143 = 605px). Discord symmetrically receives `resize smart +143` (748 + 143 = 891px), perfectly distributing the container width without pushing windows off-screen.
2. **Validation:**
   - Applied via `chezmoi apply --no-pager` and reloaded live via `aerospace reload-config`.
   - Verified callback command registration via `aerospace debug-windows`.
   - Simulated restart placement and confirmed window order and widths (Signal 605px on left, Discord 907px on right).
