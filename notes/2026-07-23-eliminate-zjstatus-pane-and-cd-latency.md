# Eliminate zjstatus Git Branch Latency Across Panes and CD ٩(◕‿◕｡)۶

*Date: 2026-07-23*

## Problem

`zjstatus` git branch updates were instant on tab switches because Zellij fires native `TabUpdate` events to plugins. However, pane switches (`Alt+h/j/k/l`) and direct directory changes (`cd`) relied on the periodic interval timer (`command_git_branch_interval "1"`), causing up to 1 second of lag.

## Solution

1. **Native Pane Focus Invalidations:**
   Inspected `zjstatus` source (`/tmp/zjstatus-v0.24.0`). `Event::PaneUpdate` natively calls `update_focused_pane()` -> `set_focused_pane_cwd()`, which invalidates focus-CWD commands (like `git_branch`) whenever the CWD changes between panes.
   Binding `MessagePlugin` directly to pane focus keys (`Alt+h/j/k/l`) created a lock collision: `MessagePlugin` spawned a command on the *old* CWD and created a `/tmp/<uuid>.git_branch.lock` file, which blocked `Event::PaneUpdate` from running `git_branch` on the *new* CWD.
   Restored clean pane keybindings (`MoveFocus`) in `dot_config/zellij/config.kdl.tmpl`, eliminating lock file contention.

2. **Instant Directory Switch Refresh (Zsh `chpwd` & Widgets):**
   Targeted the exact internal widget identifier `git_branch` (stripped of `command_` prefix by `zjstatus`). Updated `zellij_tab_name_update()` in `dot_zshrc.tmpl` and `_zellij_refresh_git_branch()` in `dot_config/zsh/widgets.tmpl` to send `command zellij pipe "zjstatus::rerun::git_branch" >/dev/null 2>&1 &!`, giving instant `^j`, `^k`, and `cd` branch updates without lock conflicts.
## Verification

`chezmoi execute-template` passed `zsh -n` validation and `chezmoi apply` completed with zero errors.
