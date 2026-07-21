# Bind Ctrl+B to Git Branch Picker Widget ٩(◕‿◕｡)۶

*Date: 2026-07-21*

## Request
Bind `^b` (Ctrl+B) to an interactive git branch picker that displays a pretty git short log in the preview window and appends the selected branch name directly onto the current prompt line.

## Implementation Details
1. **Pretty Git Short Log Preview:** Enhanced `fzf-git-branch` in `dot_config/zsh/aliases.tmpl` to render an informative, colorful short graph log in the preview window:
   `git log --graph --date=relative --pretty="format:%C(yellow)%h%C(reset) %C(auto)%d%C(reset) %s %C(green)(%cr)%C(reset) %C(bold blue)<%an>%C(reset)"`
2. **Buffer Appending Widget (`git-branch-fzf`):** Created the `git-branch-fzf` widget in `dot_config/zsh/widgets.tmpl` which appends the selected branch name (`LBUFFER+="$branch "`) at the cursor's current position and resets the prompt cleanly.
3. **Keymap Bindings:** Bound `^b` and Ghostty/Kitty CSI-u sequence `^[[98;5u` across `emacs`, `vicmd`, and `viins` keymaps.
4. **Validated & Applied:** Applied via `chezmoi apply` and verified keybindings in active Zsh sessions.
