# Debouncing `zellij-autolock` Trailing `PaneUpdate` Events on Tab Switches (｡•̀ᴗ-)✧

*Date: 2026-08-24*

## Motivation & Diagnosis

When switching from an active Neovim tab (where Zellij is in `locked` mode) to another Zellij tab (such as a standard Zsh shell tab in `normal` mode), the status bar mode indicator would flicker from Locked to Normal twice.

### Root Cause
During a tab transition in Zellij, the server does not emit a single atomic update. Instead, it dispatches an asynchronous sequence of `TabUpdate` and `PaneUpdate` events to WASM plugins:
1. **Initial switch (`TabUpdate` / first `PaneUpdate`):** `zellij-autolock.wasm` evaluates the newly active tab/pane, sees that `nvim` is no longer focused, and sends `SwitchToMode "normal"` to Zellij.
2. **Trailing event race (`PaneUpdate`):** As the tab layout settles and PTY focus detaches/reattaches across panes, Zellij emits subsequent `PaneUpdate` events. With the previous configuration of `reaction_seconds "0.1"` (100ms), the throttle timer would expire just as trailing events arrived, causing `autolock` to re-evaluate and trigger a second mode transition or re-assertion, resulting in a visible double-repaint of the status bar.

## Resolution

In [dot_config/zellij/config.kdl.tmpl](../dot_config/zellij/config.kdl.tmpl), we bumped `reaction_seconds` in the `autolock` plugin configuration from `"0.1"` to `"0.2"` (200ms):

```kdl
    autolock location="file:~/.config/zellij/plugins/zellij-autolock.wasm" {
        is_enabled true
        print_to_log false
        reaction_seconds "0.2"
        triggers "nvim"
    }
```

This 200ms debounce window smoothly absorbs trailing `PaneUpdate` events emitted during tab transitions without impacting the perceived instant mode lock/unlock when entering or leaving Neovim panes.
