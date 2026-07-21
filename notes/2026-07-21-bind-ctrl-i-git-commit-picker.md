# Bind Ctrl+I to Git Commit Picker Widget ٩(◕‿◕｡)۶

*Date: 2026-07-21*

## Request
Bind `^i` (Ctrl+I) to an interactive git commit picker (similar to `gshow` / `fzf-git-pick-commit` / `fzf` `^t`), allowing the user to search commits and paste/append the selected commit SHA(s) directly into the current command line prompt.

## Implementation Details
1. **ZLE Keymap Bindings:** Updated `dot_config/zsh/widgets.tmpl` to bind `^i`, `^[[105;5u` (Kitty/Ghostty CSI-u sequence for Ctrl+i), and `^[[9;5u` (Ctrl+Tab/Ctrl+I sequence) to `git-pick-fzf` across `emacs`, `vicmd`, and `viins` keymaps while preserving `^l`.
2. **Buffer Appending Behavior:** `git-pick-fzf` retrieves the chosen commit hash from `fzf-git-pick-commit` and appends `$commit ` directly to `LBUFFER`, cleanly inserting the commit SHA at the cursor without clobbering any existing text on the command line.
3. **Multi-Select Enhancement:** Updated `fzf-git-pick-commit` in `dot_config/zsh/aliases.tmpl` to support multi-selection (`-m`) and cleanly extract commit hashes via `awk '{print $1}'`.
4. **Validated & Applied:** Applied via `chezmoi apply` and verified keybindings in active Zsh sessions.
