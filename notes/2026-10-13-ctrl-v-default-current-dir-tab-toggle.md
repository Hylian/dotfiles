# Default Ctrl+V (`vim-fzf`) to Current Directory with Tab Recursive Toggle (｡•̀ᴗ-)✧

**Date:** 2026-10-13  
**Context:** Zsh CLI / fzf / Neovim workflow enhancement for the `Ctrl+V` (`vim-fzf`) picker.

## Motivation

While sorting files by modification time (`mtime`) prioritized recent files, running a recursive search across the entire project tree on every `Ctrl+V` invocation could be noisy when the user only intended to open or edit a file in the immediate working directory.

## Solution

1. **Scoped Depth 1 Default:**
   - In [dot_config/zsh/widgets.tmpl](../dot_config/zsh/widgets.tmpl), updated `vim-fzf` to stream only immediate files in the current working directory by default (`--max-depth 1`):
     ```zsh
     cmd_local="QUOTING_STYLE=literal ${FD_COMMAND:-fd} --type f --max-depth 1 --strip-cwd-prefix -X ls -1td --"
     ```
   - Retained global `mtime` sorting via `ls -1td --` and initial cursor placement on the newest file.
   - Set initial prompt to `nvim> ` and header to `<Tab>: all files`.

2. **Interactive Tab Toggle via FZF Transform:**
   - Bound `tab` and `btab` (Shift-Tab) to an atomic `transform` action that toggles between local files and recursive tree files:
     ```zsh
     --bind "tab:transform:[ -f '$state_file' ] && { rm -f '$state_file'; echo 'change-prompt(nvim> )+change-header(<Tab>: all files)+reload($cmd_local)'; } || { touch '$state_file'; echo 'change-prompt(nvim [all]> )+change-header(<Tab>: current dir)+reload($cmd_all)'; }"
     ```
   - Pressing `Tab` dynamically switches the prompt to `nvim [all]> `, updates the header to `<Tab>: current dir`, and reloads the stream to all files across the tree recursively.
   - Pressing `Tab` again cleanly toggles back to local directory scope.
   - Uses an ephemeral state file (`mktemp`) quarantined to `/tmp/` and cleaned up on widget exit via `{ ... } always { rm -f "$state_file"; zle reset-prompt }`.

## Verification

1. **Template & Syntax Verification:**
   - Validated template diff via `chezmoi diff`.
   - Applied cleanly via `chezmoi apply --no-pager`.
   - Recompiled `~/.config/zsh/widgets.zwc` via `zsh -c "zcompile ~/.config/zsh/widgets"`.
   - Verified `chezmoi cat ~/.config/zsh/widgets | zsh -n` and `nvim --headless +qa`.
2. **Behavioral Check:**
   - Confirmed initial open lists only 5 files in the root of the dotfiles repo with header `<Tab>: all files` and prompt `nvim> `.
   - Verified `trigger(tab)` expands candidates to 2,130 files with header `<Tab>: current dir` and prompt `nvim [all]> `.
   - Verified a second `trigger(tab)` contracts candidates back to 5 files with header `<Tab>: all files`.
