# Intelligent Non-Blocking Swap File Management in Neovim

**Date:** 2026-10-08  
**Context:** Neovim editor configuration enhancement for silent, non-blocking crash recovery backups.

## Problem & Motivation

While Neovim stores swap files cleanly in the XDG state directory (`~/.local/state/nvim/swap//`) without cluttering project trees, default swap conflict handling presents an intrusive modal dialog (`E325: ATTENTION`) whenever an existing swap file is encountered. Conversely, suppressing the dialog globally via the `A` flag in `shortmess` silences the prompt by spawning numbered swap files (`.swo`, `.swn`), leaving stale swap files accumulating on disk and failing to alert the user when genuine unsaved crash recovery data exists.

## Solution

1. **Explicit Directory & Swap State:**
   - Explicitly configured `vim.opt.swapfile = true` and `vim.opt.directory = vim.fn.stdpath('state') .. '/swap//'` in [dot_config/nvim/init.lua.tmpl](../dot_config/nvim/init.lua.tmpl).
   - Removed the suppressive `A` flag from `vim.opt.shortmess` (`'ostTcCWFSI'`) so Neovim triggers the `SwapExists` autocommand.

2. **Automated Swap Lifecycle Handler ([dot_config/nvim/lua/config/swap.lua](../dot_config/nvim/lua/config/swap.lua)):**
   - Intercepts `SwapExists` and inspects `vim.fn.swapinfo(vim.v.swapname)`.
   - **Active Concurrent Process:** If `info.pid` is alive on the current host (`vim.uv.kill(info.pid, 0) == 0`), sets `vim.v.swapchoice = 'o'` to open read-only and notifies non-blockingly via `vim.notify` to avoid conflicting edits.
   - **Orphaned Dirty Swap (Crash/Kill Backup):** If the PID is dead and `info.dirty == 1`, sets `vim.v.swapchoice = 'e'` (edit anyway), preserves the `.swp` file on disk for safety, and schedules a quiet `vim.notify` toast alerting that uncommitted crash changes exist (`:recover`).
   - **Orphaned Clean Swap:** If the PID is dead and `info.dirty == 0`, sets `vim.v.swapchoice = 'd'` to automatically delete the stale swap file and proceed seamlessly.
   - Unconditionally setting `vim.v.swapchoice` guarantees that Neovim never displays the interactive `E325` prompt.

## Verification

1. **Syntax & Rendering:**
   - Validated template diff via `chezmoi diff`.
   - Applied cleanly via `chezmoi apply --no-pager`.
   - Verified headless startup cleanly (`nvim --headless +qa`).
2. **End-to-End Simulation:**
   - Verified clean swap deletion: killed process with saved buffer, confirmed swap file exists before and was deleted upon reopening.
   - Verified dirty swap preservation: killed process with unsaved edits, confirmed swap file was preserved on disk and non-blocking notification was surfaced.
   - Verified live process detection: spawned concurrent Neovim instance in background, verified secondary session opened read-only with a non-blocking toast.
