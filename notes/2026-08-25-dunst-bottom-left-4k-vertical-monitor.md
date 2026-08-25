# Move Dunst Notifications to Bottom-Left of 4K Vertical Monitor ٩(◕‿◕｡)۶

*Date: 2026-08-25*

## Summary

Updated dunst configuration ([dot_config/dunst/dunstrc.tmpl](../dot_config/dunst/dunstrc.tmpl)) to position desktop notifications in the bottom-left corner of the rightmost 4K vertical monitor on `shined`.

## Key Changes

1. **Monitor Mapping:**
   - Unified `natura` and `shined` under `monitor = DP-2`, explicitly targeting the 4K vertical monitor (`DP-2`, position `3360,0`, `3840x2160` rotated 270) rather than relying on index-based monitor numbers.

2. **Notification Origin:**
   - Changed `origin` from `bottom-right` to `bottom-left` with `offset = 4x4`.

## Verification

1. `chezmoi diff` verified template rendering.
2. `chezmoi apply` rendered clean `~/.config/dunst/dunstrc`.
3. `dunstctl reload` reloaded the active dunst daemon.
4. `notify-send` verified notification placement in the bottom-left corner of the 4K vertical monitor.
