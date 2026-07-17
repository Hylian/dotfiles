# 2026-07-17: Silence Zsh background job logs for Zellij hooks ٩(◕‿◕｡)۶

## Problem
Zsh's interactive job control was printing background PID and completion logs (`[1] PID` and `[1] + done ...`) on every prompt redraw when running `zellij pipe ... &`.

## Fix
Replaced background operator `&` with Zsh's disowned background operator `&!` in both `zellij_status_update` and `zellij_tab_name_update` in `.zshrc`.
This runs the commands asynchronously in the background while suppressing all job table tracking and completion messages.
