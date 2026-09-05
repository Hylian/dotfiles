# Ubiquitous Zellij and Neovim Tab Keybindings Across All Modes and Popups

**Date:** 2026-09-04  
**Context:** Neovim / Zellij multiplexer integration across normal, insert, visual, and terminal/popup modes.

## Problem & Motivation

Rachel observed that when opening interactive floating popups in Neovim — such as the `fzf-lua` git changed files picker (`<leader>g`), search pickers, or terminal splits — Zellij navigation and tab switching keybindings did not respond.

### Root Cause Analysis

1. **Multiplexer Mode Locking:** In this workspace topology, `zellij-autolock` switches Zellij into `Locked` mode whenever Neovim gains focus so that all Alt-key chords pass directly into the editor rather than being intercepted by Zellij.
2. **Neovim Mode Disparity:** In [dot_config/nvim/lua/keybindings.lua](../dot_config/nvim/lua/keybindings.lua), Zellij actions and Neovim tab commands were originally defined only in normal mode (`map('n', ...)`).
3. **Terminal Mode in Floats:** When `fzf-lua` or `:terminal` opens, Neovim operates in terminal mode (`'t'`). Without terminal-mode (`t`), insert-mode (`i`), and visual-mode (`v`) keymaps, Alt combinations (`<A-Left>`, `<A-Right>`, `<A-1>`..`<A-0>`, `<A-s>`, `<A-n>`, `<A-h/j/k/l>`, etc.) fell through unhandled into the child process pty or did nothing.

## Solution & Architecture

### 1. Ubiquitous Mode Mapping (`zellij_modes = { 'n', 'i', 'v', 't' }`)

All Zellij actions and tab navigation bindings in [dot_config/nvim/lua/keybindings.lua](../dot_config/nvim/lua/keybindings.lua) are mapped across `{'n', 'i', 'v', 't'}`:
* **Tab Switching:** `<A-Left>` / `<A-Right>` (previous/next Zellij tab), `<A-1>` .. `<A-0>` (direct tab jump 1–10), `<A-C-Left>` / `<A-C-Right>` (move tab).
* **Directional Split Navigation:** `<A-h>`, `<A-j>`, `<A-k>`, `<A-l>` via `smart-splits.nvim`. In floating terminal popups, `smart-splits` delegates directly to `zellij action move-focus <dir>`.
* **Directional Resizing:** `<A-C-h>`, `<A-C-j>`, `<A-C-k>`, `<A-C-l>` via `smart-splits.nvim`.
* **Pane Actions & Spawning:** `<A-s>` (new pane in editor CWD), `<A-n>` (new tab in editor CWD), `<A-f>` (toggle fullscreen).
* **Pane Layouts & Movement:** `<A-S-h/j/k/l>` (move pane), `<A-S-[>` / `<A-S-]>` / `<A-{>` / `<A-}>` (swap layouts), `<A-[>` / `<A-]>` (break pane left/right), `<A-+>` / `<A-=>` / `<A-->` (resize increase/decrease), `<A-z>` (switch Zellij to normal mode).

### 2. Dynamic Zellij Tab Tracking & Toggle (`<A-`>`)

Zellij CLI lacks a dedicated `toggle-tab` action, but Neovim tracks the active and previous tab indices in memory:
* `update_zellij_tab()` queries `zellij action current-tab-info` asynchronously via `vim.system`.
* Autocommands on `FocusGained` and `VimEnter` sync the current tab index.
* `zellij_goto_tab(idx)` updates `zellij_last_tab = zellij_curr_tab` and switches to the destination tab.
* `<A-`>` toggles back and forth between the two most recent Zellij tabs seamlessly.

### 3. Smart Terminal-Mode Close Handling (`<A-d>` / `<A-q>`)

In terminal mode, pressing `<A-d>` or `<A-q>` checks whether the active window is a floating window:
```lua
map('t', '<A-d>', function()
  if vim.api.nvim_win_get_config(0).relative ~= "" then
    vim.api.nvim_win_close(0, true)
  else
    zellij('close-pane')
  end
end)
```
* **In floating popups (e.g. `fzf-lua`):** Closes the float immediately without closing the editor or Zellij pane.
* **In split terminal panes:** Dispatches `zellij action close-pane` or `:q`.

### 4. Neovim Tab Management (`<cmd>...<CR>`)

Neovim's internal tab switching keybindings are also mapped across `{'n', 'i', 'v', 't'}` using atomic `<cmd>...<CR>` syntax:
* `<A-S-Left>` / `<A-S-Right>`: `<cmd>tabp<CR>` / `<cmd>tabn<CR>`
* `<A-S-1>` .. `<A-S-0>` / `<A-!>` .. `<A-)>`: `<cmd>1gt<CR>` .. `<cmd>10gt<CR>`
* `<A-S-`>` / `<A-~>`: `<cmd>tabnext #<CR>`
* `<C-A-S-Left>` / `<C-A-S-Right>`: `<cmd>-tabmove<CR>` / `<cmd>+tabmove<CR>`
* `<A-S-n>`: `<cmd>$tabnew<CR>`
* `<A-S-d>`: `<cmd>NvimTreeClose<CR><cmd>tabclose<CR>`

## Verification

* `nvim --headless -c "lua require('keybindings')" -c "q"` verified clean syntax without errors or warnings.
* `chezmoi diff ~/.config/nvim/lua/keybindings.lua` verified clean application of dotfile changes.
