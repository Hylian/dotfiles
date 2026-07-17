# 2026-07-17: Fix Zellij zjstatus git branch updates ٩(◕‿◕｡)۶

## Problem
The git branch / status widget in `zjstatus` would frequently stop updating and appear stuck when switching branches or making commits.

## Root Cause
1. **Zsh hook limitation:** `zellij_status_update` was only registered under `chpwd_functions` in `.zshrc`. `chpwd` only triggers when changing directories (e.g. `cd`). Actions in the same directory (`git checkout`, `git switch`, `git commit`, `git add`) never fired `chpwd`, leaving `zjstatus` relying entirely on background polling.
2. **Interval discrepancy:** In `default.kdl.tmpl`, the light theme configured `command_git_branch_interval "10"` (10 seconds), causing sluggish or delayed fallback polling compared to the 1s interval in dark mode.

## Fix Applied
- Added `precmd_functions+=(zellij_status_update)` in `.zshrc` when `$ZELLIJ` is present. This forces `zjstatus::rerun::command_git_branch` to run asynchronously right before every command prompt redraw.
- Aligned `command_git_branch_interval` in light theme to `"1"` second in `default.kdl.tmpl`.
- Applied changes via `chezmoi apply`.
