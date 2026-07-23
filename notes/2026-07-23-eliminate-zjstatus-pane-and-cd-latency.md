# Eliminate zjstatus Git Branch Latency Across Panes and CD ٩(◕‿◕｡)۶

*Date: 2026-07-23*

## Problem

`zjstatus` git branch updates were instant on tab switches because Zellij fires native `TabUpdate` events to plugins. However, pane switches (`Alt+h/j/k/l`) and direct directory changes (`cd`) relied on the periodic interval timer (`command_git_branch_interval "1"`), causing up to 1 second of lag.

## Solution

1. **Instant Pane Focus Refresh (Zellij Config):**
   Updated `dot_config/zellij/config.kdl.tmpl` pane focus keybindings (`Alt h`, `Alt j`, `Alt k`, `Alt l`, and arrow keys) to issue `MessagePlugin { name "zjstatus::rerun::command_git_branch"; };` alongside `MoveFocus`. When switching panes, Zellij immediately notifies `zjstatus` to re-run the git branch command for the newly focused pane.

2. **Instant Directory Switch Refresh (Zsh `chpwd`):**
   Updated `zellij_tab_name_update()` in `dot_zshrc.tmpl` to dispatch `command zellij pipe "zjstatus::rerun::command_git_branch" >/dev/null 2>&1 &!` as a disowned background job upon every `chpwd` event.

## Verification

`chezmoi execute-template` passed `zsh -n` validation and `chezmoi apply` completed with zero errors.
