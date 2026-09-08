# Move zjstatus Tabs to Left Side

**Date:** 2026-09-08  
**Context:** Zellij status bar layout refinement in `dot_config/zellij/layouts/default.kdl.tmpl`.

## Motivation & Behavior

Previously, Zellij tabs were rendered in `format_center "{tabs}"`. On wide monitors, centered tabs floated in the middle of the screen away from the mode indicator, while on narrower windows or splits, centered elements created artificial collision points around the screen midpoint.

Moving tabs to the left side directly after `{mode}` aligns Zellij with conventional browser and terminal multiplexer layouts, grouping active workflow context (mode + open tabs) together.

## Implementation Details

1. **Layout Update (`default.kdl.tmpl`):**
   - In [dot_config/zellij/layouts/default.kdl.tmpl](../dot_config/zellij/layouts/default.kdl.tmpl), updated both light (`ne .theme "dark"`) and dark theme blocks:
     - `format_left "{mode} {tabs}"`
     - Removed `format_center "{tabs}"`
   - Spacing: `{mode} {tabs}` introduces a single space on the base background (`#FFFBEF` in light, `#272E33` in dark) between the mode arrow and the first tab, matching the 1-space separation between subsequent tabs (`tab_normal` and `tab_active` trailing spaces).

2. **Precedence Adjustment (`format_precedence`):**
   - Changed `format_precedence` from `"clr"` to `"lrc"`.
   - In `zjstatus`, overlength detection pairs elements based on precedence. Under `"clr"`, `(Left, Center)` checks whether `Left` text width exceeds `center_pos - (Center_width / 2)`. With `Center` empty, any `Left` section wider than half the terminal width (`cols / 2`) would cause `zjstatus` to drop `Left` entirely.
   - Setting `format_precedence "lrc"` (Left > Right > Center) ensures:
     - Left (mode + tabs) is never dropped when crossing the screen midpoint.
     - Center (empty) is the first dropped in collision pairs (a complete no-op).
     - Right status widgets hide only when `Left + Right > cols`.

## Verification

1. **Diff & Apply:** Verified `chezmoi diff` and deployed via `chezmoi apply` to `~/.config/zellij/layouts/default.kdl`.
2. **Spacing & Alignment:** Verified terminal powerline arrow alignment and spacing between mode and active/normal tabs.
