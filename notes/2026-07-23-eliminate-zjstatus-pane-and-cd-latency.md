# Eliminate zjstatus Git Branch Latency Across Panes and CD ٩(◕‿◕｡)۶

*Date: 2026-07-23*

## Problem

`zjstatus` git branch updates were instant on tab switches because Zellij fires native `TabUpdate` events to plugins. However, pane switches (`Alt+h/j/k/l`) and direct directory changes (`cd`) relied on the periodic interval timer (`command_git_branch_interval "1"`), causing up to 1 second of lag.

## Solution & Root Cause Analysis

1. **OSC 7 CWD Terminal Sync (`_zellij_osc7_cwd`):**
   Deep inspection of `zjstatus` Rust source (`/tmp/zjstatus-v0.24.0`) revealed why pane switching had random variable latency (0 to 1,000ms):
   When switching panes (`Alt+h/j/k/l`), `Event::PaneUpdate` calls `get_pane_cwd(pane_id)`. If Zellij has no cached CWD for that pane, `get_pane_cwd` returns an error, setting `focused_pane_cwd = None`. `CommandWidget::process` skips `git_branch` when `focused_pane_cwd` is `None`. `zjstatus` was then forced to wait for Zellij's background CWD polling thread to emit `Event::CwdChanged` (0–1s variable latency).
   
   Added `_zellij_osc7_cwd()` to `chpwd_functions` and `precmd_functions` in `dot_zshrc.tmpl` when `$ZELLIJ` is present:
   ```zsh
   _zellij_osc7_cwd() {
       local url_path="$(printf '%s' "${PWD}" | sed 's/ /%20/g')"
       printf '\e]7;file://%s\a' "${url_path}"
   }
   ```
   Emitting ANSI OSC 7 (`\e]7;file://...`) forces Zellij's PTY parser to update the pane's CWD in server memory synchronously.

2. **Terminal Focus Event Hooks & Silent Focus-Loss (`zle-focus-in` / `zle-focus-out`):**
   When switching to an idle pane, no `precmd` or `chpwd` hooks execute because Zsh is sitting idle at the prompt.
   Enabled terminal focus reporting (`printf '\e[?1004h'`) and bound `^[[I` (`zle-focus-in`) and `^[[O` (`zle-focus-out`) across all Zsh and `zsh-vi-mode` (`zvm`) keymaps (`main`, `viins`, `vicmd`, `visual`, `emacs`):
   ```zsh
   _zellij_focus_in() {
       _zellij_osc7_cwd
       command zellij pipe "zjstatus::rerun::git_branch" >/dev/null 2>&1 &!
       return 0
   }

   _zellij_focus_out() {
       return 0
   }
   ```
   Explicitly bound `^[[O` (`zle-focus-out`) and added `unsetopt BEEP` to prevent ZLE from treating focus-out escape sequences as unhandled keypresses, completely eliminating terminal bell (`BEL` / `[!]`) alerts on the pane being left.
3. **Instant Directory Switch Refresh (Zsh `chpwd` & Widgets):**
   Targeted internal widget identifier `git_branch`. Updated `zellij_tab_name_update()` in `dot_zshrc.tmpl` and `_zellij_refresh_git_branch()` in `dot_config/zsh/widgets.tmpl` to send `command zellij pipe "zjstatus::rerun::git_branch" >/dev/null 2>&1 &!`, giving instant `^j`, `^k`, and `cd` branch updates.
