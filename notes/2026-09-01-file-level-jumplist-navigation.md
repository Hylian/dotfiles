# File-Level Jumplist Hopping with `<leader>o` and `<leader>i` (｡•̀ᴗ-)✧

*Date: 2026-09-01*

## Motivation & Problem

Standard Vim jumplist navigation (`<C-o>` / `<C-i>`) steps linearly through every recorded jump. In active development workflows (especially with LSP jumps, definition lookups, and multi-file tracing), a single buffer can accumulate dozens of intra-file line jumps. Stepping back to an earlier file often requires hammering `<C-o>` 10–20 times just to bypass edits or scrolling within the current buffer.

Rachel needed **Pattern 2: File-level hopping** — skipping all intra-buffer jumps and jumping directly to the previous or next *different file* recorded in the window's jumplist.

## Design & Symmetrical Navigation

Inspecting `vim.fn.getjumplist()` returns `[jumps, idx]` where `jumps` is a 1-indexed list of jump records `{ bufnr, lnum, col, ... }` and `idx` is the 0-indexed cursor position within that list.

1. **Backward hopping (`<leader>o` / `;o`):**
   - Scans backwards from `idx` down to 1 for the first valid buffer where `bufnr ~= cur_buf`.
   - Computes `count = idx - (i - 1)` and feeds `<count><C-o>`.
   - Naturally lands on the *most recent* cursor position in that previous file before navigation left it.

2. **Forward hopping (`<leader>i` / `;i`):**
   - Scans forward from `idx + 2` to find the next contiguous block of jumps belonging to the first different buffer `target_buf`.
   - Traverses to the end of that contiguous block so that jumping forward lands on the *latest* position of the next file run.
   - Computes `count = (target_idx - 1) - idx` and feeds `<count><C-i>`.
   - This design ensures backward and forward file hops are mathematically symmetrical and cleanly reversible: hopping back across files `C -> B -> A` and forward `A -> B -> C` restores the exact same file-level positions.

3. **Keybinding ergonomics:**
   - `<leader>o` and `<leader>i` (with `<leader>` configured as `;`) provide intuitive, zero-delay mnemonics matching native `<C-o>` and `<C-i>`.
   - Avoids terminal escape collisions (unlike `g<C-i>`, which sends ASCII `0x09` / `g<Tab>` in non-extended terminal environments).

## Changes

- **[dot_config/nvim/lua/keybindings.lua](../dot_config/nvim/lua/keybindings.lua):**
  - Added `jump_file(direction)` inspecting `vim.fn.getjumplist()`.
  - Mapped normal-mode `<leader>o` (backward) and `<leader>i` (forward).
- **[notes/SYSTEM.md](SYSTEM.md):**
  - Updated Neovim keybindings reference.

## Verification

1. Headless automated test script verified multi-file jump stack:
   - Initialized 3 buffers with multiple intra-file line jumps (`_1.txt`, `_2.txt`, `_3.txt`).
   - Verified `<leader>o` hopped from `_3.txt` (line 4) -> `_2.txt` (line 5) -> `_1.txt` (line 4), skipping intermediate intra-file line entries.
   - Verified `<leader>i` reversed symmetrically from `_1.txt` (line 4) -> `_2.txt` (line 5) -> `_3.txt` (line 4).
2. `chezmoi diff` and `chezmoi apply` applied cleanly.
3. `nvim --headless` loaded configuration without errors or warnings.
