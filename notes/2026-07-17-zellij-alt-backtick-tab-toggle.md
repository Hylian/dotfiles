# 2026-07-17: Add Alt+\` Keybind to Toggle Between Recent Zellij Tabs ٩(◕‿◕｡)۶

## Request & Behavior
Add a global Zellij keybinding for `Alt + \`` to quickly switch back and forth between the two most recently active tabs.

## Implementation
1. **Global Mode (`shared_except "locked"`):** Bound `"Alt \`"` to `ToggleTab`. This allows instantaneous toggling between the current tab and the previous tab from any unlocked mode (`normal`, `pane`, `tab`, `resize`, `move`, `scroll`, `search`, etc.).
2. **Dedicated Tab Mode (`tab`):** Also bound `"\`"` alongside `"tab"` to `ToggleTab`.
3. Validated via `zellij setup --check` and applied cleanly with `chezmoi apply`.
