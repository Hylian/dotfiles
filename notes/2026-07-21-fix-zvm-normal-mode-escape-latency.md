# Fix ZVM Normal Mode Escape Sequence Latency (Alt+Left/Alt+Right) ٩(◕‿◕｡)۶

*Date: 2026-07-21*

## Issue
When pressing `Alt+Left` or `Alt+Right` in Zellij to switch tabs while the active pane was at a Zsh prompt in `zsh-vi-mode` (`zvm`) normal mode (`vicmd`), switching tabs required multiple rapid keypresses or experienced perceptible latency.

## Root Cause
`zsh-vi-mode` defaults to its beta `NEX` readkey engine (`ZVM_READKEY_ENGINE=nex`), which intercepts terminal key events in normal mode with a custom `read -k` loop. When multi-byte escape sequences like `Alt+Left` (`\e[1;3D`) or `Alt+Right` (`\e[1;3C`) arrived starting with `\e`, `NEX` treated `\e` as a leader/standalone key and waited up to 400ms (`ZVM_KEYTIMEOUT=0.4`) or choked on trailing sequence bytes, causing missed or delayed tab switches in Zellij.

## Fix
1. **Switch to Native ZLE Engine:** Set `ZVM_READKEY_ENGINE=zle` in `.zshrc` and `zvm_config()`. This directs `zsh-vi-mode` to use Zsh's built-in ZLE event loop rather than the custom blocking `read` loop.
2. **Ultra-fast Key Timeout:** Configured `ZVM_KEYTIMEOUT=0.01`, `ZVM_ESCAPE_KEYTIMEOUT=0.01`, and `KEYTIMEOUT=1` (10ms) in `.zshrc`.
3. **Validated & Applied:** Applied via `chezmoi apply`. Sourcing `.zshrc` and passing escape sequences in `vicmd` normal mode is now instantaneous with zero buffering or dropped keypresses.
