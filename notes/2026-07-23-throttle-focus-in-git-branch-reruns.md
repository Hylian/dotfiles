# Throttle Focus-In Git Branch Reruns to Prevent Process Flooding ٩(◕‿◕｡)۶

*Date: 2026-07-23*

## Problem

When holding navigation keys (`Alt+h/j/k/l`) to jump across multiple Zellij panes rapidly, each pane focus event triggered `zle-focus-in` in Zsh. `_zellij_focus_in` executed `command zellij pipe "zjstatus::rerun::git_branch" &!`, invalidating `zjstatus`'s 60s cache and spawning a background `git status` process for every intermediate pane. Rapid pane navigation resulted in concurrent process thrashing, filesystem lock contention on `.git/index`, and status bar lag.

## Architectural Design Pattern: Event Categorization & Throttling

To decouple lightweight terminal synchronization from heavy background command execution, focus events are categorized into two tiers:

1. **Lightweight Sync Tier (Zero Fork, Unthrottled):**
   ANSI OSC 7 (`_zellij_osc7_cwd`) is emitted on every single focus-in event. This is a pure terminal stdout PTY escape sequence (`\e]7;file://...`) with 0 subprocess overhead. Zellij's server memory updates the focused pane's CWD instantly, allowing `zjstatus` to display the existing cached git branch for that directory immediately.

2. **Heavy Invalidating Tier (Throttled Focus, Instant User Actions):**
   - **Focus Traversal (`_zellij_focus_in`):** Rate-limited to at most once per 2 seconds via `$SECONDS` timestamp tracking (`now - _ZELLIJ_LAST_FOCUS_RERUN >= 2`). Rapid pane traversal skips invalidation pipe calls (`zellij pipe`), avoiding process bursts.
   - **Explicit User Actions (`precmd`, `chpwd`, Zoxide widgets `^j`/`^k`):** Unthrottled. Prompt updates and directory navigation trigger immediate `_zellij_refresh_git_branch`.

## Verification

1. `chezmoi execute-template < dot_zshrc.tmpl | zsh -n` passed syntax check cleanly.
2. `chezmoi diff` verified exact delta in `.zshrc`.
3. `chezmoi apply` completed without errors.
