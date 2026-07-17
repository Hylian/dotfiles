# 2026-07-17: Speed up Zellij zjstatus pane switch latency ٩(◕‿◕｡)۶

## Problem
When switching between panes in Zellij (via keyboard or mouse), the git branch status widget took up to 1-2 seconds to update for the newly focused pane.

## Root Causes
1. **Lack of focus event triggers:** Zellij pane focus changes only update `{focused_pane_cwd}` inside the WASM plugin, but `zjstatus` does not immediately re-execute the command until the periodic interval timer ticks (up to 1s latency).
2. **Heavy git subprocess spawning:** The branch command executed `sh -c` with fallback subshells (`symbolic-ref`, `describe`, `rev-parse`) followed by an unconstrained `git status --porcelain` that scanned untracked files across the entire repo tree.

## Optimizations Applied
1. **Zsh Terminal Focus Reporting (`zle-focus-in`):**
   - Enabled terminal focus reporting (`\e[?1004h`) in interactive Zsh sessions inside Zellij.
   - Defined `zle-focus-in()` widget in `.zshrc` to trigger `zellij pipe "zjstatus::rerun::command_git_branch"` asynchronously the exact instant the terminal pane gains focus.
2. **Lightning-fast Git command:**
   - Replaced multi-step fallback queries with `git branch --show-current 2>/dev/null || git rev-parse --short HEAD 2>/dev/null`.
   - Added `-uno` (untracked files = no) and `--ignore-submodules=dirty` to `git status --porcelain=v1` to skip deep worktree index scans.
   - Dropped nested subshell wrappers for cleaner async background piping.
