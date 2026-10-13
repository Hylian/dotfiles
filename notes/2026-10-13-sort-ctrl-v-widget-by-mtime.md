# Sort Zsh Ctrl+V (`vim-fzf`) File List by Modification Time (｡•̀ᴗ-)✧

**Date:** 2026-10-13  
**Context:** Zsh CLI / fzf / Neovim workflow enhancement for the `Ctrl+V` (`vim-fzf`) picker.

## Motivation

Previously, `vim-fzf` in [dot_config/zsh/widgets.tmpl](../dot_config/zsh/widgets.tmpl) invoked `${FD_COMMAND:-fd} --type f` to feed the file list to `fzf`. Because `fd` traverses directories concurrently without sorting, the default file list appeared in non-deterministic filesystem order. Opening the picker (`Ctrl+V`) required manual typing or scrolling to locate recently edited or created files.

## Solution

1. **Sort by Modification Time (`mtime`):**
   - Updated `vim-fzf` in [dot_config/zsh/widgets.tmpl](../dot_config/zsh/widgets.tmpl) to batch `fd` results into `ls -1td --` via `fd -X`:
     ```zsh
     QUOTING_STYLE=literal ${FD_COMMAND:-fd} --type f --strip-cwd-prefix -X ls -1td --
     ```
   - `fd -X` passes all discovered files to `ls -1td --`, sorting the stream globally by modification time (most recent first).
   - `--strip-cwd-prefix` strips `./` so paths match standard relative paths.
   - `QUOTING_STYLE=literal` prevents GNU coreutils `ls` from wrapping filenames containing spaces in single quotes on Linux, while remaining a safe no-op on BSD/macOS `ls`.
   - `--` terminates `ls` flag parsing so files starting with a dash are not mistaken for options.

2. **Immediate Selection of the Most Recent File:**
   - In `fzf`, the first stream item corresponds to the most recently modified file.
   - When `Ctrl+V` opens with an empty query, the most recently modified file is selected by default, allowing immediate `<CR>` to open it in Neovim.

## Verification

1. **Template & Syntax Verification:**
   - Validated template diff via `chezmoi diff`.
   - Applied cleanly via `chezmoi apply --no-pager`.
   - Recompiled `~/.config/zsh/widgets.zwc` via `zsh -c "zcompile ~/.config/zsh/widgets"`.
   - Verified `chezmoi cat ~/.config/zsh/widgets | zsh -n` and `nvim --headless +qa`.
2. **Behavioral Check:**
   - Verified `QUOTING_STYLE=literal ${FD_COMMAND:-fd} --type f --strip-cwd-prefix -X ls -1td --` returns the most recently modified files first without quotes or `./` prefix.
   - Confirmed `fzf` selects the newest file first on launch.
