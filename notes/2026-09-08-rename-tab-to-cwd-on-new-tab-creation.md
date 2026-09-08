# Rename Zellij Tab to Active CWD on New Tab Creation

**Date:** 2026-09-08  
**Context:** Zellij tab lifecycle, tab naming conventions, and shell initialization.

## Problem & Observation

When opening a new tab in Zellij (via `Alt+n`, tab mode `n`, or Neovim's `<A-n>`), the newly created tab appeared with a default title like `Tab #1` or `Tab #2`. While `zellij_tab_name_update` dynamically updated the tab name to match the current working directory whenever changing directories (`cd`), it failed to trigger upon initial tab creation.

## Root Cause Analysis

1. **Zellij Default Tab Naming:**
   - Zellij defaults new tab titles to `Tab #<id>` when created without an explicit name parameter (`Action::NewTab { tab_name: None, ... }`).
2. **Hook Execution Lifecycle in Zsh:**
   - In [dot_zshrc.tmpl](../dot_zshrc.tmpl), `zellij_tab_name_update` was registered exclusively to `chpwd_functions`.
   - When a new tab is created and a new shell spawns, the shell initializes in its inherited working directory without invoking `cd`.
   - Consequently, `chpwd` hooks never executed on shell startup, leaving the tab stuck with Zellij's default numeric name until the user manually changed directories.

## Solution

1. **Trigger `zellij_tab_name_update` on Shell Initialization:**
   - In [dot_zshrc.tmpl](../dot_zshrc.tmpl), invoked `zellij_tab_name_update` directly within the `if [[ -n $ZELLIJ ]]; then` block.
   - Because `zellij_tab_name_update` dispatches asynchronously via `&!` (`command zellij action rename-tab "$current_dir" </dev/null >/dev/null 2>&1 &!`), it adds zero blocking latency to shell startup while immediately setting the tab title to the active directory basename.
   - Added command and environment guards (`[[ -n $ZELLIJ ]] && (( $+commands[zellij] )) || return 0`) and root directory safety (`/` fallback when `${current_dir##*/}` evaluates to empty).
2. **Neovim `<A-n>` Tab Name Parameter:**
   - In [dot_config/nvim/lua/keybindings.lua](../dot_config/nvim/lua/keybindings.lua), updated the `<A-n>` keybinding to pass `--name <dir>` directly to `zellij action new-tab`.
   - This provides instantaneous, zero-latency tab title rendering in the status bar before the child shell process even spawns.
3. **Blank Initial Tab Name in Zellij (`NewTab { name " "; }`):**
   - When opening a new tab directly in Zellij (via `Alt+n` or tab mode `n`), Zellij's server defaults unnamed tabs to `Tab #<id>`. During the brief ~60ms window before the shell finishes loading `.zshrc`, this caused a jarring flash of `Tab #2` before transitioning to the folder name.
   - Updated `NewTab` keybindings in [dot_config/zellij/config.kdl.tmpl](../dot_config/zellij/config.kdl.tmpl) to pass `{ name " "; }`.
   - Zellij initializes the tab with an empty whitespace string, rendering as a clean blank active tab pill in `zjstatus` with zero text flash, which smoothly populates with the directory name once the shell prompt initializes.

## Verification

1. **Neovim Validation:** Ran headless Neovim test (`nvim --headless -c 'quit'`) successfully.
2. **Zsh Script & Syntax Validation:** Verified parameter expansion for both standard directory paths and root `/`.
3. **Zellij Configuration Check:** Validated syntax with `zellij setup --check` (`Config File: Well defined`).
4. **Applied & Verified:** Executed `chezmoi apply` and confirmed clean `chezmoi diff`.
