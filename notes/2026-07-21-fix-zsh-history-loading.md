# Fix Zsh History Loading & Persisting for FZF ^R ٩(◕‿◕｡)۶

*Date: 2026-07-21*

## Problem Diagnosis
When invoking `^R` (`fzf-history-widget`), only commands typed in the current shell session were displayed, despite `~/.zsh_history` existing on disk with complete historical logs.

Investigation revealed:
1. `HISTFILE`, `HISTSIZE`, and `SAVEHIST` were unset in `dot_zshrc.tmpl`.
2. In vanilla Zsh without explicit history variables, `HISTFILE` remains empty (`""`), `HISTSIZE=30`, and `SAVEHIST=0`.
3. Because `HISTFILE` was empty on startup, Zsh initialized an empty in-memory event buffer and never read `~/.zsh_history`.
4. `fzf-history-widget` queries Zsh's in-memory history table via `fc -l 1`. Since only the current session's commands were in memory, `^R` only displayed current session commands.
5. On shell exit, commands typed during the session were discarded because `SAVEHIST=0`.

## Resolutions Applied
- **Explicit History Configuration (`dot_zshrc.tmpl`):**
  - Set `HISTFILE="${HISTFILE:-$HOME/.zsh_history}"`.
  - Configured `HISTSIZE=50000` and `SAVEHIST=50000`.
  - Added robust history options:
    - `EXTENDED_HISTORY`: Retains timestamps and elapsed time.
    - `SHARE_HISTORY`: Shares command history across active sessions in real time.
    - `HIST_EXPIRE_DUPS_FIRST`, `HIST_IGNORE_DUPS`, `HIST_IGNORE_ALL_DUPS`, `HIST_FIND_NO_DUPS`, `HIST_SAVE_NO_DUPS`, `HIST_REDUCE_BLANKS`, `HIST_IGNORE_SPACE`, and `HIST_VERIFY`.
  - Added startup history read `[[ -f "$HISTFILE" ]] && fc -R "$HISTFILE" 2>/dev/null` to immediately populate in-memory history table for interactive widgets.
