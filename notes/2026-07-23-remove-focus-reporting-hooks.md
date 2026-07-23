# Remove Focus Reporting & Focus-Switching Hooks ٩(◕‿◕｡)۶

*Date: 2026-07-23*

## Context

To keep the system lightweight and avoid any extra overhead during rapid pane navigation (`Alt+h/j/k/l`), all terminal focus reporting (`\e[?1004h`), focus ZLE hooks (`zle-focus-in`, `zle-focus-out`), and focus escape keybindings (`^[[I`, `^[[O`) have been completely removed from Zsh configuration.

## Retained Optimizations

1. **60-Second Polling Interval (`interval 60`):** `zjstatus` maintains `command_git_branch_interval "60"`, reducing periodic background CPU polling by 98%.
2. **Event-Driven Prompt Reruns:** `_zellij_refresh_git_branch` remains active on `precmd` (command completion), `chpwd` (`cd`), and Zoxide interactive widgets (`^j`/`^k`).
3. **ANSI OSC 7 CWD Sync (`_zellij_osc7_cwd`):** Emitted synchronously in `precmd` and `chpwd` to keep Zellij server memory informed of active pane directories.

## Verification

1. `chezmoi execute-template < dot_zshrc.tmpl | zsh -n` passed syntax validation.
2. `chezmoi diff` verified complete removal of focus hooks.
3. `chezmoi apply` completed without error.
