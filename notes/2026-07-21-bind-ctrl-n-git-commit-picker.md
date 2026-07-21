# Restore Tab Completion & Bind Git Commit Picker to Ctrl+N (^n) ٩(◕‿◕｡)۶

*Date: 2026-07-21*

## Summary
1. **Restored Native Tab Autocompletion:** Removed legacy `^i` (Tab) and Kitty CSI-u bindings from `git-pick-fzf`, restoring `Tab` (`^I`) to native Zsh `expand-or-complete`.
2. **Mapped Git Commit Picker to `Ctrl+N` (`^n`):** Bound `git-pick-fzf` to `^n` across `emacs`, `vicmd`, and `viins` keymaps in Zsh. Note that `git-pick-fzf` activates when inside a git repository to provide interactive commit selection with delta preview.
