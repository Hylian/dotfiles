# Truncate Git Branch Names in zjstatus Status Bar Widget

**Date:** 2026-09-08  
**Context:** Prevent `zjstatus` status bar from dropping the entire right widget section on narrow terminal widths.

## Problem & Observation

In Zellij layouts configured with `format_hide_on_overlength "true"` and `format_precedence "clr"` ([dot_config/zellij/layouts/default.kdl.tmpl](../dot_config/zellij/layouts/default.kdl.tmpl)), when the total formatted length of left, center, and right sections exceeds the terminal width, `zjstatus` drops the lowest-precedence section (`r`, the right section) entirely rather than clipping individual elements.

The git branch name is the primary variable-width component in the bar. In narrow windows (e.g. 120 columns or split windows) with longer branch names (such as `hylian/latency`), the status bar crossed the width threshold, causing the right widget group (session name, host, etc.) to completely disappear or flash on and off during pane transitions.

## Root Cause Analysis

1. **Precedence Drop Behavior:**
   - `zjstatus` evaluates section lengths against available terminal columns. If over length, sections are hidden in reverse precedence order (`clr` -> `r` dropped first).
2. **Variable Width Branch Names:**
   - Long feature or topic branches easily exceed 15-20 columns, consuming excess margin in the status line.
3. **Zero-Fork Constraint:**
   - [dot_config/zellij/widgets/executable_git-status.sh](../dot_config/zellij/widgets/executable_git-status.sh) runs in the critical render loop of Zellij (~18 invocations per pane switch burst). Any truncation mechanism must be completely fork-free and compatible with `/bin/sh` (`dash` on Debian/Ubuntu and macOS).

## Solution

1. **Pure POSIX Parameter Expansion Truncation:**
   - In [dot_config/zellij/widgets/executable_git-status.sh](../dot_config/zellij/widgets/executable_git-status.sh), immediately after resolving non-empty `$branch`, branches longer than 12 characters are truncated to 11 characters followed by an ellipsis (`…`):
     ```sh
     if [ "${#branch}" -gt 12 ]; then
     	branch="${branch%"${branch#???????????}"}…"
     fi
     ```
   - **Zero Subprocess Overhead:** Pure shell builtins with zero subshells or forks (`cut`, `awk`, `sed`), executing in <1µs.
   - **Shell Portability:** Uses standard POSIX `${#branch}` and `${var#pattern}`/`${var%pattern}` slicing, avoiding non-POSIX Bash substring syntax (`${branch:0:11}`) that errors on `dash`.
   - **Display Column Consistency:** 11 characters plus single-character ellipsis (`…`, U+2026) yields exactly 12 display columns, leaving dirty indicator tracking (` ●`) intact.

## Verification

1. **Short Branch ($\le 12$ Chars):**
   - Verified on `main` (4 chars) -> outputs `main` (or `main ●` if dirty) un-truncated.
   - Verified on `twelve_chars` (12 chars) -> outputs `twelve_chars` un-truncated.
2. **Long Branch ($> 12$ Chars):**
   - Verified on `thirteen_chars` (13 chars) -> outputs `thirteen_ch…` (length 12).
   - Verified on `hylian/latency` (14 chars) -> outputs `hylian/late…` (length 12).
3. **Chezmoi Sync:**
   - Applied via `chezmoi apply` to `~/.config/zellij/widgets/git-status.sh`.
   - Invalidated runtime memos (`/tmp/zjstatus-git-memo.*` and `${XDG_RUNTIME_DIR:-/tmp}/zjstatus-git-memo.*`).
