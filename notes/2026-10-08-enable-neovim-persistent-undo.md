# Enable Persistent Undo Buffers in Neovim

**Date:** 2026-10-08  
**Context:** Neovim editor configuration enhancement.

## Problem & Motivation

Previously, [dot_config/nvim/init.lua.tmpl](../dot_config/nvim/init.lua.tmpl) configured `vim.opt.undolevels = 1000`, but did not set `vim.opt.undofile = true`. Without `undofile`, buffer undo histories were held solely in volatile process memory and discarded upon exiting Neovim or closing a buffer.

## Solution

1. **Persistent Undo Configuration (`vim.opt.undofile = true`):**
   - Added `vim.opt.undofile = true` to [dot_config/nvim/init.lua.tmpl](../dot_config/nvim/init.lua.tmpl).
   - Pairs with Neovim's native `undodir` default (`$XDG_STATE_HOME/nvim/undo//` -> `~/.local/state/nvim/undo//`), which uses trailing path delimiters (`//`) to prevent file collisions across different directories while auto-creating the state directory upon buffer writes.
   - Retains `vim.opt.undolevels = 1000` for deep undo tree history per buffer across editor sessions.

## Verification

1. **Syntax & Rendering:**
   - Validated template diff via `chezmoi diff`.
   - Applied configuration cleanly via `chezmoi apply --no-pager`.
2. **End-to-End Functional Test:**
   - Verified `vim.opt.undofile:get() == true` in headless Neovim.
   - Performed an end-to-end multi-session test creating a file across two separate headless Neovim invocations, then opening in a third session and issuing `undo` to confirm file content cleanly reverted to its initial state across process lifetimes.
