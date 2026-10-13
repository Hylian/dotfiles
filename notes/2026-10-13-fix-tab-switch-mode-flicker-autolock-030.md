# Fix Zellij Tab Switch Mode Indicator Flicker via Autolock 0.3.0 (｡•̀ᴗ-)✧

**Date:** 2026-10-13  
**Context:** Zellij multiplexer / `zellij-autolock` plugin / `zjstatus` mode indicator stability.

## Problem & Diagnosis

When switching between an active Neovim tab and a non-Neovim tab (e.g. Zsh shell) via `Alt + <number>`, the `zjstatus` mode indicator (`NORMAL` vs `LOCKED`) flashed back and forth multiple times before finally settling.

### Root Causes

1. **Redundant `SwitchToMode "normal"` in Tab Keybindings:**
   In [dot_config/zellij/config.kdl.tmpl](../dot_config/zellij/config.kdl.tmpl), `shared_except "locked"` bound `Alt 1` through `Alt 9` with an explicit `SwitchToMode "normal"` command (inherited from stock `tab` sub-mode defaults). When navigating to a tab running Neovim, this forcibly injected an artificial `NORMAL` mode state before `autolock` could evaluate the tab.

2. **`zellij-autolock` v0.2.2 Polling & Query Race:**
   The tracked `zellij-autolock.wasm` was an older v0.2.2 build (compiled against Zellij 0.41). In v0.2.2:
   - Zellij server emits `Event::PaneUpdate` before `Event::TabUpdate` during tab switches. In v0.2.2, `PaneUpdate` queried the old tab position, while `TabUpdate` cleared the cached pane ID without triggering a new check.
   - Command discovery relied on asynchronous `list_clients()` calls. During initial tab transition, `client.running_command` temporarily returns `"N/A"` while PTY process info resolves. Because `"N/A"` did not match triggers, v0.2.2 prematurely switched from `LOCKED` to `NORMAL`, only to switch back to `LOCKED` a fraction of a second later when PTY data returned `nvim`.
   - `Event::ModeUpdate` and `Event::InputReceived` restarted debounce timers (`reaction_seconds`), causing repeated rounds of `list_clients()` re-polling that multiplied the visible flashes.

## Solution

1. **Clean Up `GoToTab` Keybindings:**
   Removed `SwitchToMode "normal"` from `Alt 1`..`Alt 9` (and added `Alt 0` for Tab 10) in [dot_config/zellij/config.kdl.tmpl](../dot_config/zellij/config.kdl.tmpl):
   ```kdl
   bind "Alt 1" { GoToTab 1; }
   ...
   bind "Alt 9" { GoToTab 9; }
   bind "Alt 0" { GoToTab 10; }
   ```
   Matches existing clean bindings for `Alt left`, `Alt right`, `Alt \``, and `Alt ~`.

2. **Upgrade `zellij-autolock.wasm` to v0.3.0:**
   Updated [dot_config/zellij/plugins/zellij-autolock.wasm](../dot_config/zellij/plugins/zellij-autolock.wasm) to the official v0.3.0 release (built natively against Zellij 0.45.1):
   - Replaced asynchronous `list_clients()` polling with synchronous `host.focused_pane()` (`get_focused_pane_info`) and `host.pane_command()` (`get_pane_running_command`, backed by our fast `/proc` Linux reader).
   - If process resolution is pending, v0.3.0 preserves the current mode rather than falsely falling back to `NORMAL`.
   - Tracks tabs by tab ID rather than position.
   - Replaced `triggers` with modern regex matching (`lock_regex "^(nvim|vim)$"`) and silenced debug output with `log_level "warn"`.

## Verification

1. **Configuration & Template Verification:**
   - Validated template diff via `chezmoi diff`.
   - Applied cleanly via `chezmoi apply --no-pager`.
   - Verified `zellij setup --check` reports `[CONFIG FILE]: Well defined.`
2. **Binary Verification:**
   - Confirmed `zellij-autolock.wasm` matches official 0.3.0 release (`217e071...`, compiled against `zellij-tile-0.45.1`).
