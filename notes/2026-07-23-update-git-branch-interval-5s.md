# Update zjstatus Git Branch Interval to 5 Seconds ٩(◕‿◕｡)۶

*Date: 2026-07-23*

## Change

Updated `command_git_branch_interval` from `"60"` to `"5"` seconds in `dot_config/zellij/layouts/default.kdl.tmpl`.

## Purpose

With focus-in hooks removed, a 5-second polling interval ensures `zjstatus` automatically refreshes git status across idle background panes within 5 seconds without needing focus-switch hooks or manual Zsh commands.

## Verification

1. `chezmoi diff` verified change in `.config/zellij/layouts/default.kdl`.
2. `chezmoi apply` completed successfully.
