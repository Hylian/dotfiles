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

## Solution & Investigation

1. **Neovim `<A-n>` Tab Name Parameter:**
   - In [dot_config/nvim/lua/keybindings.lua](../dot_config/nvim/lua/keybindings.lua), updated the `<A-n>` keybinding to pass `--name <dir>` directly to `zellij action new-tab`.
   - This provides instantaneous, zero-latency tab title rendering in the status bar on frame 0 before the child shell process even spawns.
2. **Investigation of Shell-Level Renaming & Blank Flashes:**
   - Attempting to rename tabs on shell initialization via `command zellij action rename-tab "$current_dir"` in [dot_zshrc.tmpl](../dot_zshrc.tmpl) revealed fundamental multiplexer overhead:
     - `CliAction::RenameTab` (without `--tab-id`) in `zellij-utils/src/input/actions.rs` emits two actions: `TabNameInput { input: vec![0] }` followed by `TabNameInput { input: name }`.
     - The null byte `\0` explicitly wipes the active tab name to an empty string (`active_tab.name = String::new()`) and calls `log_and_report_session_state()`, broadcasting an empty tab name `TabUpdate` event to `zjstatus` before the second action sets the real name. This caused `zjstatus` to flash blank!
     - Spawning `zellij` CLI client processes on shell startup also competed for CPU and socket IPC during session boot, making initial prompt rendering feel sluggish.
   - Binding `NewTab { name " "; }` in [dot_config/zellij/config.kdl.tmpl](../dot_config/zellij/config.kdl.tmpl) also forced the Zellij client to read `default.kdl` from disk and parse the full KDL layout AST instead of taking the in-memory fast path (`tiled_layout: None`).
3. **Restoring Clean Baseline:**
   - Reverted `dot_config/zellij/config.kdl.tmpl` to bare `NewTab;` to preserve fast in-memory layout instantiation.
   - Removed `zellij_tab_name_update` from shell startup in `dot_zshrc.tmpl`, keeping it strictly within `chpwd_functions` for directory changes.
   - Hardened `zellij_tab_name_update` with command existence guards and `/` root directory handling.

## Verification

1. **Neovim Validation:** Ran headless Neovim test (`nvim --headless -c 'quit'`) successfully.
2. **Zsh Script & Syntax Validation:** Verified parameter expansion for both standard directory paths and root `/`.
3. **Zellij Configuration Check:** Validated syntax with `zellij setup --check` (`Config File: Well defined`).
4. **Applied & Verified:** Executed `chezmoi apply` and confirmed clean `chezmoi diff`.
