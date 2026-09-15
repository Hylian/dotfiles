# Migrate nvim-treesitter to Main Branch & Neovim 0.12 Native Engine

**Date:** 2026-09-15  
**Context:** Resolve tree-sitter Lua runtime errors (`attempt to call method 'range' (a nil value)`) when opening markdown files with fenced code blocks (`OVERVIEW.md`), modernizing from the archived `master` branch to `main`.

## Root Cause

- Neovim was upgraded by Homebrew to **`v0.12.5`**.
- In Neovim 0.12, the internal query engine (`Query:_apply_directives` and `Query:iter_matches`) changed the signature for query directives and predicates: `match` is delivered as `table<integer, TSNode[]>` (an array of nodes per capture ID to support query quantifiers) rather than a single `TSNode`.
- The legacy `master` branch of `nvim-treesitter` (archived, Neovim ≤ 0.11 only) in `query_predicates.lua` passed `match[capture_id]` directly into `vim.treesitter.get_node_text(node)`. Because `node` was `{ [1] = <TSNode> }`, calling `node:range(true)` crashed with a nil method call.

## Solution

1. **Install `tree-sitter-cli`:**
   - Installed `tree-sitter-cli` 0.27.0 via Homebrew (`/opt/homebrew/bin/tree-sitter`) as required by `nvim-treesitter` `main` for parser compilation. Added to [resources/mac_brew.sh](../resources/mac_brew.sh).
2. **Switch to `main` Branch ([dot_config/nvim/lua/plugins/init.lua](../dot_config/nvim/lua/plugins/init.lua)):**
   - Updated `nvim-treesitter` plugin spec to `branch = 'main'`.
3. **Modernize Treesitter Config ([dot_config/nvim/lua/config/treesitter.lua](../dot_config/nvim/lua/config/treesitter.lua)):**
   - Configured `require('nvim-treesitter').setup` with `install_dir = stdpath('data') .. '/site'`.
   - Uses `require('nvim-treesitter').install` for baseline parsers (`c`, `lua`, `vim`, `vimdoc`, `query`, `markdown`, `markdown_inline`).
   - Retained backward-compatible fallback to `nvim-treesitter.configs` for legacy hosts running Neovim ≤ 0.11.
   - Preserved 100 KB buffer size limit via a native `FileType` autocmd stopping treesitter highlighting on oversized buffers (`vim.treesitter.stop(buf)`).
4. **Living Ground Truth Update ([SYSTEM.md](SYSTEM.md)):**
   - Updated treesitter section in `notes/SYSTEM.md`.

## Verification

- Ran `:checkhealth nvim-treesitter`: All requirements OK (Neovim ABI 15, `tree-sitter-cli` 0.27.0, tar, curl).
- Parsers installed and verified for `c`, `lua`, `markdown`, `markdown_inline`, `query`, `vim`, `vimdoc`.
- Tested opening `~/dev/homelab/fresh/OVERVIEW.md` headlessly: buffer parsed cleanly with 0 errors and 0 warnings.
- Tested `treesitter-context` integration: verified functional without errors.
- Ran `chezmoi diff` and applied with `chezmoi apply`.
