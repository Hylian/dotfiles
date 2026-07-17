# 2026-07-17: Zellij Prompt Scrollback Navigation with Neovim <C-k> / <C-j> ٩(◕‿◕｡)۶

## Goal
Provide a seamless, 1-key workflow to navigate and scroll Zellij pane scrollback per-prompt / command output, since Zellij 0.44.x lacks native OSC 133 semantic prompt indexing.

## Implementation
1. **1-Key Scrollback Export (`Alt e`):**
   - In `dot_config/zellij/config.kdl.tmpl`, bound `Alt e` under `shared_except "locked"` to `EditScrollback; SwitchToMode "normal";`.
   - Pressing `Alt e` (or `Ctrl s` -> `e`) instantly opens the current pane's scrollback in `$EDITOR` (`nvim`).

2. **Neovim Prompt Jump Motions (`<C-k>` / `<C-j>`):**
   - In `dot_config/nvim/lua/keybindings.lua`, mapped `<C-k>` (previous prompt) and `<C-j>` (next prompt) across normal, visual, and operator-pending modes.
   - Motions search for Starship prompt character `❯` (with fallback regex for standard `$`/`#`/`%` prompts).
   - Allows instant prompt-to-prompt jumping, visual block selection, and `yy` yanking directly to macOS clipboard via OSC 52.

3. Applied via `chezmoi apply`.
