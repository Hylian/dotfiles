# 2026-07-17: Fix Zsh Widget Keybindings Overridden by zsh-vi-mode ٩(◕‿◕｡)۶

## Problem
Interactive Zsh widget keybindings (such as `^k` for `zoxide-fzf-curdir`, `^f` for `rg-fzf`, etc.) defined in `~/.config/zsh/widgets` were broken and inactive in interactive Zsh sessions.

## Root Cause
1. In `.zshrc`, `source "$HOME/.config/zsh/widgets"` was executed during initial sourcing before `jeffreytse/zsh-vi-mode` initialized.
2. When `zsh-vi-mode` (`zvm_init`) initialized during shell startup, it reset and populated its own default keymaps for `viins` and `vicmd` modes. This clobbered custom `bindkey -M viins` mappings (specifically overwriting `^k` with `zvm_forward_kill_line` and `^f` with `forward-char`).
3. Additionally, `widgets` contained legacy calls to `zellij_status_update`, which had previously been removed from `.zshrc` when decoupling Zsh from Zellij IPC pipes.

## Fix
1. **Deferred Widget Keymap Registration (`zvm_after_init_commands`):** Appended `source "$HOME/.config/zsh/widgets"` to `zvm_after_init_commands` in `.zshrc`. This guarantees that whenever `zsh-vi-mode` completes its mode and keymap setup, all custom interactive widgets (`^g`, `^j`, `^k`, `^f`, `^v`, `^l`) are immediately re-bound across `viins`, `vicmd`, and `emacs` keymaps.
2. **Clean Widget Execution:** Removed obsolete `zellij_status_update` calls from `cd-fzf`, `zoxide-fzf`, and `zoxide-fzf-curdir` in `dot_config/zsh/widgets`.
3. Applied cleanly via `chezmoi apply` and verified keymap persistence across all modes.
