# Disable Ctrl+Z Process Suspension Across TTY, Zsh, FZF, and Neovim

**Date:** 2026-09-10  
**Context:** Prevent accidental process suspension (`SIGTSTP`) when pressing `Ctrl+Z` across terminal foreground jobs, interactive Zsh prompts, `fzf` pickers, and Neovim.

## Root Cause & Layers Affected

In a standard Unix terminal environment, `Ctrl+Z` triggers process backgrounding at multiple independent layers:
1. **Kernel TTY Line Discipline (`stty susp ^Z`):** When a foreground process is executing, pressing `Ctrl+Z` causes the kernel terminal driver to send `SIGTSTP` to the foreground process group.
2. **Zsh Line Editor (ZLE):** Once `stty susp undef` disables kernel interception, `Ctrl+Z` (`\x1a`) is passed directly to ZLE at the shell prompt. Because Zsh's `viins` and `emacs` keymaps bind `^Z` to `self-insert` by default, pressing `Ctrl+Z` inserts a literal `^Z` control character into the command line.
3. **FZF Interactive Pickers:** `fzf` reads raw terminal input directly unless `ctrl-z:ignore` is specified in `--bind`.
4. **Neovim Raw Mode (`<C-z>`):** Neovim operates in raw terminal mode (`ISIG` disabled) and maps `<C-z>` in Normal and Visual modes to `:suspend` (`:stop`), which explicitly sends `SIGTSTP` to Neovim itself.

## Solution

1. **Terminal Line Discipline ([dot_zshrc.tmpl](../dot_zshrc.tmpl)):**
   - Unbind `susp` and freeze terminal state with `ttyctl -f` so Zsh preserves `susp = <undef>` across command executions and tty resets:
     ```zsh
     if [[ -t 0 ]]; then
       stty susp undef 2>/dev/null
       ttyctl -f 2>/dev/null
     fi
     ```
2. **Zsh ZLE Keymaps ([dot_config/zsh/widgets.tmpl](../dot_config/zsh/widgets.tmpl)):**
   - Define a silent no-op widget (`_zsh_noop`) and bind `^z` across `emacs`, `viins`, `vicmd`, and `visual` keymaps (re-applied inside `zvm_after_init_commands` after `zsh-vi-mode` initializes):
     ```zsh
     _zsh_noop() {}
     zle -N _zsh_noop
     bindkey -M emacs '^z' _zsh_noop
     bindkey -M viins '^z' _zsh_noop
     bindkey -M vicmd '^z' _zsh_noop
     bindkey -M visual '^z' _zsh_noop
     ```
3. **Global FZF Options ([dot_zshrc.tmpl](../dot_zshrc.tmpl)):**
   - Added `--bind=ctrl-z:ignore` to `FZF_DEFAULT_OPTS` for both light and dark themes.
4. **Neovim Keybindings ([dot_config/nvim/lua/keybindings.lua](../dot_config/nvim/lua/keybindings.lua)):**
   - Mapped `<C-z>` to `<Nop>` across all modes (`{'n', 'i', 'v', 'x', 's', 'o', 't', 'c'}`).

## Verification

- Verified `stty -a` in interactive Zsh reports `susp = <undef>;`.
- Verified `bindkey -M viins "^Z"` and `bindkey -M vicmd "^Z"` report `"^Z" _zsh_noop`.
- Verified `nvim --headless -c 'verbose map <C-z>' -c 'q'` maps `<C-Z>` to `<Nop>` across all modes.
